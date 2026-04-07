import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';

/// Second onboarding step: fridge photo and CTAs. Strings from [text.json].
class SnapFridgeOnboardingScreen extends StatelessWidget {
  const SnapFridgeOnboardingScreen({
    super.key,
    this.onGetStarted,
    this.onSignIn,
  });

  final VoidCallback? onGetStarted;
  final VoidCallback? onSignIn;

  static const double _lgFloat = 1024;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).snapFridgeOnboarding;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 768;
    final showFloats = size.width >= _lgFloat;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.onSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              s.heroImageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => ColoredBox(
                color: AppColors.primary.withValues(alpha: 0.35),
                child: const Center(
                  child: Icon(
                    Icons.kitchen_outlined,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.onSurface.withValues(alpha: 0.9),
                    AppColors.onSurface.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),
          if (showFloats) ...[
            Positioned(
              top: size.height * 0.22,
              right: -48,
              child: Transform.rotate(
                angle: 0.21,
                child: _FloatScanCard(strings: s),
              ),
            ),
            Positioned(
              bottom: size.height * 0.32,
              left: -32,
              child: Transform.rotate(
                angle: -0.1,
                child: _FloatEcoCard(strings: s),
              ),
            ),
          ],
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 672),
                          child: Column(
                            crossAxisAlignment: wide
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Center(child: _BrandPill(brand: s.brand)),
                              const SizedBox(height: 48),
                              Align(
                                alignment: wide
                                    ? Alignment.centerLeft
                                    : Alignment.center,
                                child: _KickerChip(label: s.kicker),
                              ),
                              const SizedBox(height: 12),
                              _HeadlineBlock(
                                line1: s.headlineLine1,
                                accent: s.headlineAccent,
                                textAlign: wide
                                    ? TextAlign.left
                                    : TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                s.body,
                                textAlign: wide
                                    ? TextAlign.left
                                    : TextAlign.center,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: wide ? 20 : 18,
                                  height: 1.5,
                                  color: AppColors.surfaceContainerHighest,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _ProgressRow(),
                              const SizedBox(height: 32),
                              _ActionRow(
                                getStartedLabel: s.getStarted,
                                signInLabel: s.signIn,
                                wide: wide,
                                onGetStarted: onGetStarted ?? () {},
                                onSignIn: onSignIn ?? () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.brand});

  final String brand;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primaryFixed,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                brand,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KickerChip extends StatelessWidget {
  const _KickerChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
          color: AppColors.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock({
    required this.line1,
    required this.accent,
    required this.textAlign,
  });

  final String line1;
  final String accent;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.plusJakartaSans(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      height: 1.1,
      color: Colors.white,
      letterSpacing: -0.5,
    );
    final wide = MediaQuery.sizeOf(context).width >= 768;
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          line1,
          textAlign: textAlign,
          style: base.copyWith(fontSize: wide ? 56 : 48),
        ),
        Text(
          accent,
          textAlign: textAlign,
          style: base.copyWith(
            fontSize: wide ? 56 : 48,
            color: AppColors.primaryFixed,
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 768;
    return Row(
      mainAxisAlignment: wide
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primaryFixed,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 12),
        for (var i = 0; i < 3; i++) ...[
          Container(
            width: 16,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          if (i < 2) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.getStartedLabel,
    required this.signInLabel,
    required this.wide,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final String getStartedLabel;
  final String signInLabel;
  final bool wide;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final cta = _PrimaryCta(label: getStartedLabel, onPressed: onGetStarted);
    final signIn = _GlassSecondaryButton(
      label: signInLabel,
      onPressed: onSignIn,
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: cta),
          const SizedBox(width: 16),
          Expanded(child: signIn),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [cta, const SizedBox(height: 16), signIn],
    );
  }
}

class _PrimaryCta extends StatefulWidget {
  const _PrimaryCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<_PrimaryCta> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSecondaryButton extends StatelessWidget {
  const _GlassSecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
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

class _FloatScanCard extends StatelessWidget {
  const _FloatScanCard({required this.strings});

  final SnapFridgeOnboardingStrings strings;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.floatAiTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      strings.floatAiSubtitle,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatEcoCard extends StatelessWidget {
  const _FloatEcoCard({required this.strings});

  final SnapFridgeOnboardingStrings strings;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.onPrimaryFixed,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.floatEcoTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      strings.floatEcoSubtitle,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: AppColors.primaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
