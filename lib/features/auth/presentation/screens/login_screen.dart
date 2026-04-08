import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/nav/mealmorph_messenger.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/firebase_auth_repository.dart';

/// Sign-in with Firebase (email/password, Google). Copy from app strings.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.auth});

  /// Override for tests; defaults to [FirebaseAuthRepository].
  final FirebaseAuthRepository? auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _registerMode = false;
  late final FirebaseAuthRepository _auth;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? FirebaseAuthRepository();
  }

  void _onSignedIn(String? email) {
    if (!mounted) return;
    final s = AppStringsScope.of(context).login;
    final msg = email != null && email.isNotEmpty
        ? s.signedInAs.replaceAll('{email}', email)
        : 'Signed in';
    mealMorphMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(msg)),
    );
    // Root [_AuthGate] rebuilds to [MyFridgeScreen] once Firebase auth updates.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).login;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final wide = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: _WatermarkBackground()),
          Positioned(
            top: -MediaQuery.sizeOf(context).height * 0.1,
            right: -MediaQuery.sizeOf(context).width * 0.05,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryContainer.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.sizeOf(context).height * 0.1,
            left: -MediaQuery.sizeOf(context).width * 0.05,
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
          if (wide && s.cornerImageUrl.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.25,
              height: MediaQuery.sizeOf(context).height * 0.33,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
                    child: Image.network(
                      s.cornerImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          _BrandBlock(
                            headlineLine1: s.headlineLine1,
                            headlineAccent: s.headlineAccent,
                            subtitle: _registerMode ? s.subtitleRegister : s.subtitle,
                          ),
                          const SizedBox(height: 48),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [AppColors.editorialShadow],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: wide ? 40 : 32,
                                vertical: wide ? 40 : 32,
                              ),
                              child: _LoginFormCard(
                                strings: s,
                                auth: _auth,
                                registerMode: _registerMode,
                                onSignedIn: _onSignedIn,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                      _AuthFooterRow(
                        registerMode: _registerMode,
                        strings: s,
                        onToggleMode: () =>
                            setState(() => _registerMode = !_registerMode),
                      ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 4,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.onSurface,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WatermarkBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black,
                Colors.black.withValues(alpha: 0.5),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Opacity(
            opacity: 0.03,
            child: Text(
              'MealMorph',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: MediaQuery.sizeOf(context).width * 0.4,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -4,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({
    required this.headlineLine1,
    required this.headlineAccent,
    required this.subtitle,
  });

  final String headlineLine1;
  final String headlineAccent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            style: GoogleFonts.plusJakartaSans(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5,
              color: AppColors.onSurface,
            ),
            children: [
              TextSpan(text: headlineLine1),
              TextSpan(
                text: headlineAccent,
                style: const TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  const _LoginFormCard({
    required this.strings,
    required this.auth,
    required this.registerMode,
    required this.onSignedIn,
  });

  final LoginScreenStrings strings;
  final FirebaseAuthRepository auth;
  final bool registerMode;
  final void Function(String? email) onSignedIn;

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode()..addListener(_onFocusChange);
    _passwordFocus = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _emailFocus
      ..removeListener(_onFocusChange)
      ..dispose();
    _passwordFocus
      ..removeListener(_onFocusChange)
      ..dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submitEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _toast(widget.strings.enterCredentials);
      return;
    }
    setState(() => _busy = true);
    try {
      final cred = widget.registerMode
          ? await widget.auth.createUserWithEmail(
              email: email,
              password: password,
            )
          : await widget.auth.signInWithEmail(
              email: email,
              password: password,
            );
      widget.onSignedIn(cred.user?.email ?? email);
    } catch (e) {
      _toast(firebaseAuthErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _toast(widget.strings.enterCredentials);
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.auth.sendPasswordResetEmail(email);
      _toast(widget.strings.resetEmailSent);
    } catch (e) {
      _toast(firebaseAuthErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() => _busy = true);
    try {
      final cred = await widget.auth.signInWithGoogle();
      if (cred != null && mounted) {
        widget.onSignedIn(
          cred.user?.email ?? cred.user?.displayName,
        );
      }
    } catch (e) {
      if (mounted) _toast(firebaseAuthErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  InputDecoration _fieldDecoration({required String hint, required bool focused}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.beVietnamPro(
        color: AppColors.outline,
        fontSize: 16,
      ),
      filled: true,
      fillColor: focused
          ? AppColors.surfaceContainerLowest
          : AppColors.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final register = widget.registerMode;
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: _busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.emailLabel,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
                decoration: _fieldDecoration(
                  hint: s.emailPlaceholder,
                  focused: _emailFocus.hasFocus,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      s.passwordLabel,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (!register)
                    TextButton(
                      onPressed: _busy ? null : _forgotPassword,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        s.forgotPassword,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
                decoration: _fieldDecoration(
                  hint: '••••••••',
                  focused: _passwordFocus.hasFocus,
                ),
              ),
              const SizedBox(height: 24),
              _LoginGradientButton(
                label: register ? s.signUpCta : s.login,
                onPressed: _submitEmailPassword,
              ),
              const SizedBox(height: 16),
              _OrDivider(label: s.orContinueWith),
              const SizedBox(height: 16),
              _GoogleSignInButton(
                label: s.googleSignIn,
                enabled: !_busy,
                onPressed: _google,
              ),
            ],
          ),
        ),
        if (_busy)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.white.withValues(alpha: 0.55),
              child: const Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoginGradientButton extends StatefulWidget {
  const _LoginGradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_LoginGradientButton> createState() => _LoginGradientButtonState();
}

class _LoginGradientButtonState extends State<_LoginGradientButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: AppColors.outlineVariant.withValues(alpha: 0.3),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.outline,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(999),
          hoverColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          splashColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GoogleGMark(size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Four-path “G” mark (24×24 viewBox), drawn in Dart.
class _GoogleGMark extends StatelessWidget {
  const _GoogleGMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGMarkPainter()),
    );
  }
}

class _GoogleGMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    void fillPath(Path path, Color color) {
      final paint = Paint()..color = color;
      canvas.drawPath(path, paint);
    }

    final blue = Path()
      ..moveTo(22.56, 12.25)
      ..relativeCubicTo(0, -0.78, -0.07, -1.53, -0.2, -2.25)
      ..lineTo(12, 10)
      ..relativeLineTo(0, 4.26)
      ..relativeLineTo(5.92, 0)
      ..relativeCubicTo(-0.26, 1.37, -1.04, 2.53, -2.21, 3.31)
      ..relativeLineTo(0, 2.77)
      ..relativeLineTo(3.57, 0)
      ..relativeCubicTo(2.08, -1.92, 3.28, -4.74, 3.28, -8.09)
      ..close();
    fillPath(blue, const Color(0xFF4285F4));

    final green = Path()
      ..moveTo(12, 23)
      ..relativeCubicTo(2.97, 0, 5.46, -0.98, 7.28, -2.66)
      ..relativeLineTo(-3.57, -2.77)
      ..relativeCubicTo(-0.98, 0.66, -2.23, 1.06, -3.71, 1.06)
      ..relativeCubicTo(-2.86, 0, -5.29, -1.93, -6.16, -4.53)
      ..lineTo(2.18, 14.09)
      ..relativeLineTo(0, 2.84)
      ..cubicTo(3.99, 20.53, 7.7, 23, 12, 23)
      ..close();
    fillPath(green, const Color(0xFF34A853));

    final yellow = Path()
      ..moveTo(5.84, 14.09)
      ..relativeCubicTo(-0.22, -0.66, -0.35, -1.36, -0.35, -2.09)
      ..relativeCubicTo(0, -0.73, 0.13, -1.43, 0.35, -2.09)
      ..lineTo(2.18, 7.07)
      ..cubicTo(1.43, 8.55, 1, 10.22, 1, 12)
      ..relativeCubicTo(0, 1.78, 0.43, 3.45, 1.18, 4.93)
      ..lineTo(5.84, 14.09)
      ..close();
    fillPath(yellow, const Color(0xFFFBBC05));

    final red = Path()
      ..moveTo(12, 5.38)
      ..relativeCubicTo(1.62, 0, 3.06, 0.56, 4.21, 1.64)
      ..lineTo(19.36, 3.87)
      ..cubicTo(17.45, 2.09, 14.97, 1, 12, 1)
      ..cubicTo(7.7, 1, 3.99, 3.47, 2.18, 7.07)
      ..lineTo(5.84, 9.91)
      ..cubicTo(6.71, 7.31, 9.14, 5.38, 12, 5.38)
      ..close();
    fillPath(red, const Color(0xFFEA4335));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthFooterRow extends StatelessWidget {
  const _AuthFooterRow({
    required this.registerMode,
    required this.strings,
    required this.onToggleMode,
  });

  final bool registerMode;
  final LoginScreenStrings strings;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.beVietnamPro(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    );
    final link = GoogleFonts.beVietnamPro(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );
    final prompt =
        registerMode ? strings.alreadyHaveAccountPrompt : strings.noAccountPrompt;
    final action = registerMode ? strings.signInLink : strings.createAccount;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(prompt, style: base, textAlign: TextAlign.center),
        InkWell(
          onTap: onToggleMode,
          borderRadius: BorderRadius.circular(4),
          child: Text(action, style: link),
        ),
      ],
    );
  }
}
