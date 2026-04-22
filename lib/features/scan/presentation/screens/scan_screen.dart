import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../fridge/data/fridge_repository.dart';
import '../../../fridge/domain/fridge_item.dart';
import '../../../shell/presentation/widgets/main_bottom_nav.dart';
import '../../data/scan_repository.dart';
import '../../domain/scan_result.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    super.key,
    this.onNavigateTab,
    ScanRepository? repository,
    ImagePicker? picker,
  }) : _repository = repository,
       _picker = picker;

  final ValueChanged<MainTab>? onNavigateTab;
  final ScanRepository? _repository;
  final ImagePicker? _picker;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final ScanRepository _repo;
  late final ImagePicker _picker;
  final FridgeRepository _fridge = FridgeRepository.instance;

  ScanMode _mode = ScanMode.fridge;
  File? _captured;
  ScanResponse? _result;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? ScanRepository();
    _picker = widget._picker ?? ImagePicker();
  }

  Future<void> _capture() async {
    final s = AppStringsScope.of(context).scan;
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 82,
      );
      if (x == null || !mounted) return;
      setState(() {
        _captured = File(x.path);
        _result = null;
        _error = null;
      });
      await _analyse();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.cameraUnavailable)));
    }
  }

  Future<void> _analyse() async {
    final file = _captured;
    if (file == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final res = await _repo.analyse(image: file, mode: _mode);
      if (!mounted) return;
      setState(() => _result = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _retake() {
    setState(() {
      _captured = null;
      _result = null;
      _error = null;
    });
  }

  void _addAll() {
    final detected = _result?.items ?? const <DetectedIngredient>[];
    if (detected.isEmpty) return;
    final now = DateTime.now().microsecondsSinceEpoch;
    final items = detected.asMap().entries.map((e) {
      final d = e.value;
      return FridgeItem(
        id: 'scan-$now-${e.key}',
        name: d.name,
        detail: d.quantity,
        category: d.category,
        imagePath: _captured?.path,
      );
    });
    _fridge.addAll(items);
    if (!mounted) return;
    final s = AppStringsScope.of(context).scan;
    final snack = s.addedSnack.replaceAll('{count}', '${detected.length}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(snack)));
    widget.onNavigateTab?.call(MainTab.home);
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
            child: _captured == null
                ? _CameraPlaceholder(strings: s, mode: _mode)
                : _CapturedPreview(file: _captured!),
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
              setState(() {
                _mode = mode;
                _captured = null;
                _result = null;
              });
            },
          ),
        ),
        if (_captured == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: navClearance + 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _InstructionsBlock(strings: s, mode: _mode),
            ),
          ),
        if (_captured == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: navClearance + 20,
            child: Center(
              child: _CaptureFab(busy: _busy, onTap: _capture),
            ),
          )
        else
          Positioned(
            left: 16,
            right: 16,
            bottom: navClearance + 16,
            child: _ResultsPanel(
              strings: s,
              busy: _busy,
              result: _result,
              error: _error,
              onRetake: _retake,
              onAdd: _addAll,
              onRetry: _analyse,
            ),
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

class _CapturedPreview extends StatelessWidget {
  const _CapturedPreview({required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Image.file(file, fit: BoxFit.cover);
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

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.strings,
    required this.busy,
    required this.result,
    required this.error,
    required this.onRetake,
    required this.onAdd,
    required this.onRetry,
  });

  final ScanScreenStrings strings;
  final bool busy;
  final ScanResponse? result;
  final Object? error;
  final VoidCallback onRetake;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.55;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
          ),
          child: busy
              ? _BusyBlock(strings: strings)
              : error != null
              ? _ErrorState(
                  error: error!,
                  retryLabel: strings.retake,
                  onRetry: onRetry,
                  retakeLabel: strings.retake,
                  onRetake: onRetake,
                )
              : _Results(
                  strings: strings,
                  result: result,
                  onRetake: onRetake,
                  onAdd: onAdd,
                ),
        ),
      ),
    );
  }
}

class _BusyBlock extends StatelessWidget {
  const _BusyBlock({required this.strings});

  final ScanScreenStrings strings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            strings.analysing,
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.retryLabel,
    required this.onRetry,
    required this.retakeLabel,
    required this.onRetake,
  });

  final Object error;
  final String retryLabel;
  final VoidCallback onRetry;
  final String retakeLabel;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.toString(),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRetake,
                child: Text(retakeLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.strings,
    required this.result,
    required this.onRetake,
    required this.onAdd,
  });

  final ScanScreenStrings strings;
  final ScanResponse? result;
  final VoidCallback onRetake;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final items = result?.items ?? const <DetectedIngredient>[];
    final mode = result?.mode ?? 'unknown';
    final header = strings.itemsFound.replaceAll('{count}', '${items.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.scanningProgress,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            _ModePill(
              mode: mode,
              liveLabel: strings.liveBadge,
              mockLabel: strings.mockBadge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          header,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            strings.noItemsFound,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _DetectedRow(item: items[i]),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRetake,
                child: Text(strings.retake),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: items.isEmpty ? null : onAdd,
                child: Text(strings.addAll),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.mode,
    required this.liveLabel,
    required this.mockLabel,
  });

  final String mode;
  final String liveLabel;
  final String mockLabel;

  @override
  Widget build(BuildContext context) {
    final live = mode == 'live';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: live
            ? AppColors.primaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        live ? liveLabel : mockLabel,
        style: GoogleFonts.beVietnamPro(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: live ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DetectedRow extends StatelessWidget {
  const _DetectedRow({required this.item});

  final DetectedIngredient item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.name,
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (item.quantity != null && item.quantity!.isNotEmpty)
          Text(
            item.quantity!,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _CaptureFab extends StatelessWidget {
  const _CaptureFab({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
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
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(22),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 36,
                ),
        ),
      ),
    );
  }
}
