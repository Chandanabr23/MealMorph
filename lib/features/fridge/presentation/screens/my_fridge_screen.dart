import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/widgets/blurred_app_bar.dart';
import '../../../shell/presentation/widgets/main_bottom_nav.dart';
import '../../data/fridge_repository.dart';
import '../../domain/fridge_item.dart';
import '../widgets/fridge_thumbnail.dart';
import 'add_to_fridge_screen.dart';

/// Fridge overview: stats + ingredient rows, hydrated from [FridgeRepository].
class MyFridgeScreen extends StatefulWidget {
  const MyFridgeScreen({super.key, this.signedInMessage, this.onNavigateTab});

  final String? signedInMessage;
  final ValueChanged<MainTab>? onNavigateTab;

  @override
  State<MyFridgeScreen> createState() => _MyFridgeScreenState();
}

class _MyFridgeScreenState extends State<MyFridgeScreen> {
  static const BorderRadius _leaf = BorderRadius.only(
    topLeft: Radius.circular(48),
    bottomRight: Radius.circular(48),
    topRight: Radius.circular(16),
    bottomLeft: Radius.circular(16),
  );

  final ImagePicker _picker = ImagePicker();
  final FridgeRepository _repo = FridgeRepository.instance;

  @override
  void initState() {
    super.initState();
    final msg = widget.signedInMessage;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      });
    }
  }

  Future<void> _captureFromCamera() async {
    final s = AppStringsScope.of(context).fridge;
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (x == null || !mounted) return;

      final details = await _describeCaptureDialog(s);
      if (!mounted || details == null) return;

      final trimmedName = details.name?.trim();
      final trimmedDetail = details.detail?.trim();
      _repo.add(
        FridgeItem(
          id: 'cam-${DateTime.now().microsecondsSinceEpoch}',
          imagePath: x.path,
          name: trimmedName?.isEmpty ?? true ? null : trimmedName,
          detail: trimmedDetail?.isEmpty ?? true ? null : trimmedDetail,
          expiringSoon: details.expiringSoon,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(s.cameraUnavailable)));
      }
    }
  }

  Future<_CaptureDetails?> _describeCaptureDialog(FridgeScreenStrings s) {
    final nameC = TextEditingController();
    final detailC = TextEditingController();
    var expiring = false;

    return showDialog<_CaptureDetails>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(
                s.captureDialogTitle,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameC,
                      decoration: InputDecoration(
                        hintText: s.nameOptionalHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: detailC,
                      decoration: InputDecoration(
                        hintText: s.detailOptionalHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.markExpiringSoon,
                        style: GoogleFonts.beVietnamPro(fontSize: 14),
                      ),
                      value: expiring,
                      onChanged: (v) =>
                          setLocal(() => expiring = v ?? false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      ctx,
                      _CaptureDetails(
                        name: nameC.text,
                        detail: detailC.text,
                        expiringSoon: expiring,
                      ),
                    );
                  },
                  child: Text(s.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _morph() {
    final s = AppStringsScope.of(context).fridge;
    if (_repo.items.value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.addItemsFromCameraFirst)));
      return;
    }
    widget.onNavigateTab?.call(MainTab.recipes);
  }

  Future<void> _openManualEntry() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const AddToFridgeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).fridge;
    final appTitle = AppStringsScope.of(context).app.title;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        ValueListenableBuilder<List<FridgeItem>>(
          valueListenable: _repo.items,
          builder: (context, items, _) {
            final stored = items.length;
            final expiring = items.where((e) => e.expiringSoon).length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.paddingOf(context).top + 72,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        s.pageTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.pageSubtitle,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _StatLeafCard(
                                icon: Icons.inventory_2_rounded,
                                iconColor: AppColors.primary,
                                value: '$stored',
                                label: s.itemsStoredLabel,
                                background: AppColors.primaryContainer
                                    .withValues(alpha: 0.2),
                                valueColor: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _StatRoundedCard(
                                icon: Icons.timer_outlined,
                                iconColor: AppColors.secondary,
                                value: '$expiring',
                                label: s.expiringSoonLabel,
                                background: AppColors.secondaryContainer
                                    .withValues(alpha: 0.2),
                                valueColor: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              borderColor: AppColors.primary.withValues(
                                alpha: 0.3,
                              ),
                              background: AppColors.primary.withValues(
                                alpha: 0.05,
                              ),
                              hoverBackground: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              iconLeaf: true,
                              icon: Icons.receipt_long_rounded,
                              iconColor: AppColors.primary,
                              title: s.scanReceiptTitle,
                              subtitle: s.scanReceiptSubtitle,
                              onTap: () =>
                                  widget.onNavigateTab?.call(MainTab.scan),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionCard(
                              borderColor: AppColors.secondaryContainer
                                  .withValues(alpha: 0.3),
                              background: AppColors.secondaryContainer
                                  .withValues(alpha: 0.05),
                              hoverBackground: AppColors.secondaryContainer
                                  .withValues(alpha: 0.1),
                              iconLeaf: false,
                              icon: Icons.edit_note_rounded,
                              iconColor: AppColors.secondary,
                              title: s.manualEntryTitle,
                              subtitle: s.manualEntrySubtitle,
                              onTap: _openManualEntry,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 2,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.identifiedIngredients,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            s.emptyListHint,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 15,
                              height: 1.45,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _IngredientRow(
                              item: item,
                              strings: s,
                              leafShape: _leaf,
                              onRemove: () => _repo.remove(item.id),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlurredAppBar(title: appTitle),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 100 + bottomInset,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _MorphFab(
                label: s.morphIngredients,
                onPressed: _morph,
                onLongPress: _captureFromCamera,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CaptureDetails {
  const _CaptureDetails({
    this.name,
    this.detail,
    required this.expiringSoon,
  });

  final String? name;
  final String? detail;
  final bool expiringSoon;
}

class _StatLeafCard extends StatelessWidget {
  const _StatLeafCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRoundedCard extends StatelessWidget {
  const _StatRoundedCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: iconColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: valueColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({
    required this.borderColor,
    required this.background,
    required this.hoverBackground,
    required this.iconLeaf,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color borderColor;
  final Color background;
  final Color hoverBackground;
  final bool iconLeaf;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? widget.hoverBackground : widget.background;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.borderColor, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: widget.iconLeaf
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(48),
                            bottomRight: Radius.circular(48),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          )
                        : BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.iconColor.withValues(alpha: 0.75),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.iconColor,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          height: 1.2,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: widget.iconColor.withValues(alpha: 0.4),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.item,
    required this.strings,
    required this.leafShape,
    required this.onRemove,
  });

  final FridgeItem item;
  final FridgeScreenStrings strings;
  final BorderRadius leafShape;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final title = item.name?.isNotEmpty == true
        ? item.name!
        : strings.unnamedItem;
    final detailFromItem = item.detail?.trim();
    final quantityStr =
        item.quantity != null && item.unit != null && item.unit!.isNotEmpty
        ? '${item.quantity} ${item.unit}'
        : null;
    final subtitle = (detailFromItem != null && detailFromItem.isNotEmpty)
        ? detailFromItem
        : (quantityStr ?? strings.fromCameraNote);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: leafShape,
            child: SizedBox(
              width: 96,
              height: 96,
              child: item.imagePath != null
                  ? FridgeThumbnail(path: item.imagePath!)
                  : ColoredBox(
                      color: AppColors.surfaceContainerHigh,
                      child: Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary.withValues(alpha: 0.5),
                        size: 36,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.expiringSoon) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        strings.expiringSoonLabel.toUpperCase(),
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            child: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            onSelected: (v) {
              if (v == 'remove') onRemove();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'remove',
                child: Text(strings.removeItem),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MorphFab extends StatelessWidget {
  const _MorphFab({
    required this.label,
    required this.onPressed,
    this.onLongPress,
  });

  final String label;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
