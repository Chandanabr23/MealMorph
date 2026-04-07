import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';

/// Onboarding — “Expiry Priority” (Stitch). Full page scroll; copy from [text.json].
class ExpiryPriorityOnboardingScreen extends StatelessWidget {
  const ExpiryPriorityOnboardingScreen({super.key, this.onNext, this.onSkip});

  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).expiryPriorityOnboarding;
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 768;
    final heroH = wide ? (size.height * 0.52).clamp(340.0, 580.0) : 486.0;
    final bottomPad = MediaQuery.paddingOf(context).bottom + 24.0;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: -32,
            right: -32,
            child: IgnorePointer(
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -48,
            left: -48,
            child: IgnorePointer(
              child: Container(
                width: 384,
                height: 384,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad),
              child: wide
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: SizedBox(
                                height: heroH,
                                child: _HeroSection(
                                  compactGlass: false,
                                  strings: s,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                32,
                                48,
                                64,
                                48,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.brand,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 448,
                                    ),
                                    child: _CopyAndActions(
                                      strings: s,
                                      onNext: onNext,
                                      onSkip: onSkip,
                                      wide: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: heroH,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: _HeroSection(compactGlass: true, strings: s),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              s.brand,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                          child: _CopyAndActions(
                            strings: s,
                            onNext: onNext,
                            onSkip: onSkip,
                            wide: false,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.compactGlass, required this.strings});

  final bool compactGlass;
  final ExpiryPriorityOnboardingStrings strings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: -0.035,
                child: Transform.scale(
                  scale: 1.05,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 512,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(48),
                              bottomRight: Radius.circular(48),
                            ),
                            boxShadow: [AppColors.editorialShadow],
                            color: AppColors.surfaceContainerLow,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            strings.heroImageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, _, _) => Container(
                              color: AppColors.surfaceContainerLow,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 64,
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 48,
                          left: -16,
                          child: Transform.rotate(
                            angle: -0.05,
                            child: _FloatChip(
                              icon: Icons.timer_rounded,
                              label: strings.chipExpiringSoon,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          right: -16,
                          child: Transform.rotate(
                            angle: 0.035,
                            child: _FloatChip(
                              icon: Icons.priority_high_rounded,
                              label: strings.chipUseWithin,
                            ),
                          ),
                        ),
                        if (!compactGlass)
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 24,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(
                                      alpha: 0.7,
                                    ),
                                    boxShadow: [AppColors.editorialShadow],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              strings.smartScanTitle,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.primary,
                                                    letterSpacing: 1.2,
                                                  ),
                                            ),
                                            Text(
                                              strings.smartScanSubtitle,
                                              style: GoogleFonts.beVietnamPro(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FloatChip extends StatelessWidget {
  const _FloatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [AppColors.editorialShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.onSecondaryContainer),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyAndActions extends StatelessWidget {
  const _CopyAndActions({
    required this.strings,
    required this.wide,
    this.onNext,
    this.onSkip,
  });

  final ExpiryPriorityOnboardingStrings strings;
  final bool wide;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final inlineDesktopActions = wide && constraints.maxWidth >= 300;

        Widget skipButton() => TextButton(
          onPressed: onSkip ?? () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.onSurfaceVariant,
            textStyle: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(strings.skip),
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.kicker,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
                letterSpacing: 3.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              strings.headline,
              style: GoogleFonts.plusJakartaSans(
                fontSize: wide ? 40 : 32,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              strings.body,
              style: GoogleFonts.beVietnamPro(
                fontSize: 17,
                height: 1.5,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                for (var i = 0; i < 2; i++) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < 1) const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 40),
            if (inlineDesktopActions)
              Row(
                children: [
                  _GradientNextButton(
                    label: strings.next,
                    onPressed: onNext ?? () {},
                    fixedWidth: 200,
                  ),
                  const SizedBox(width: 24),
                  skipButton(),
                ],
              )
            else if (wide)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GradientNextButton(
                    label: strings.next,
                    onPressed: onNext ?? () {},
                    fixedWidth: null,
                  ),
                  skipButton(),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _GradientNextButton(
                      label: strings.next,
                      onPressed: onNext ?? () {},
                      fixedWidth: null,
                    ),
                  ),
                  skipButton(),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _GradientNextButton extends StatefulWidget {
  const _GradientNextButton({
    required this.label,
    required this.onPressed,
    this.fixedWidth,
  });

  final String label;
  final VoidCallback onPressed;
  final double? fixedWidth;

  @override
  State<_GradientNextButton> createState() => _GradientNextButtonState();
}

class _GradientNextButtonState extends State<_GradientNextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.fixedWidth ?? double.infinity;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: w,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                boxShadow: [AppColors.editorialShadow],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 22,
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
