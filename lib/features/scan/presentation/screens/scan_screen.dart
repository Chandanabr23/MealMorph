import 'dart:async' show unawaited;
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/widgets/main_bottom_nav.dart';
import '../../data/scan_controller.dart';
import '../../data/scan_repository.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.onNavigateTab,
    ScanController? controller,
    ImagePicker? picker,
  }) : _controller = controller,
       _picker = picker;

  final ValueChanged<MainTab>? onNavigateTab;
  final ScanController? _controller;
  final ImagePicker? _picker;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final ScanController _controller;
  late final ImagePicker _picker;

  ScanMode _mode = ScanMode.fridge;

  @override
  void initState() {
    super.initState();
    _controller = widget._controller ?? ScanController.instance;
    _picker = widget._picker ?? ImagePicker();
  }

  Future<void> _capture() async {
    final s = AppStringsScope.of(context).scan;
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (x == null || !mounted) return;
      // Fire-and-forget: analysis keeps running after we leave this screen.
      unawaited(_controller.analyze(image: File(x.path), mode: _mode));
      widget.onNavigateTab?.call(MainTab.recipes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.cameraUnavailable)));
    }
  }

  void _select(MainTab tab) => widget.onNavigateTab?.call(tab);

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).scan;
    final appTitle = AppStringsScope.of(context).app.title;
    final top = MediaQuery.paddingOf(context).top;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    // Bottom nav height ≈ 12 (top pad) + 60 (content) + safeBottom + 20.
    final navClearance = safeBottom + 92;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(color: AppColors.onSurface),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: _CameraPlaceholder(strings: s, mode: _mode),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.onSurface.withValues(alpha: 0.55),
                    Colors.transparent,
                    AppColors.onSurface.withValues(alpha: 0.88),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _DarkBlurAppBar(
            title: appTitle,
            onClose: () => _select(MainTab.home),
          ),
        ),
        Positioned(
          top: top + 80,
          left: 24,
          right: 24,
          child: _ModeToggle(
            mode: _mode,
            fridgeLabel: s.fridgeMode,
            receiptLabel: s.receiptMode,
            onChange: (mode) {
              if (_mode == mode) return;
              setState(() => _mode = mode);
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: navClearance + 140,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _InstructionsBlock(strings: s, mode: _mode),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: navClearance + 20,
          child: Center(child: _CaptureFab(onTap: _capture)),
        ),
      ],
    );
  }
}

class _DarkBlurAppBar extends StatelessWidget {
  const _DarkBlurAppBar({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, top + 8, 24, 12),
          color: AppColors.onSurface.withValues(alpha: 0.4),
          child: Row(
            children: [
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.fridgeLabel,
    required this.receiptLabel,
    required this.onChange,
  });

  final ScanMode mode;
  final String fridgeLabel;
  final String receiptLabel;
  final ValueChanged<ScanMode> onChange;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SegmentButton(
                  icon: Icons.kitchen_rounded,
                  label: fridgeLabel,
                  selected: mode == ScanMode.fridge,
                  onTap: () => onChange(ScanMode.fridge),
                ),
                _SegmentButton(
                  icon: Icons.receipt_long_rounded,
                  label: receiptLabel,
                  selected: mode == ScanMode.receipt,
                  onTap: () => onChange(ScanMode.receipt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({required this.strings, required this.mode});

  final ScanScreenStrings strings;
  final ScanMode mode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 240,
        height: 320,
        decoration: BoxDecoration(
          color: AppColors.onSurface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.primaryFixed, width: 2),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode == ScanMode.receipt
                    ? Icons.receipt_long_rounded
                    : Icons.kitchen_rounded,
                color: AppColors.primaryFixed,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                mode == ScanMode.receipt
                    ? strings.alignReceiptInstruction
                    : strings.modeInstructionsFridge,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionsBlock extends StatelessWidget {
  const _InstructionsBlock({required this.strings, required this.mode});

  final ScanScreenStrings strings;
  final ScanMode mode;

  @override
  Widget build(BuildContext context) {
    return Text(
      mode == ScanMode.receipt
          ? strings.modeInstructionsReceipt
          : strings.modeInstructionsFridge,
      textAlign: TextAlign.center,
      style: GoogleFonts.beVietnamPro(
        fontSize: 13,
        height: 1.5,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }
}

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}
