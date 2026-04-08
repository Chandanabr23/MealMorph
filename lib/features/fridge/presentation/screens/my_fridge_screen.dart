import 'dart:ui' show ImageFilter;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/fridge_item.dart';
import '../widgets/fridge_thumbnail.dart';

/// Fridge overview: stats and ingredient rows from camera captures only.
class MyFridgeScreen extends StatefulWidget {
  const MyFridgeScreen({super.key, this.signedInMessage});

  final String? signedInMessage;

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
  final List<FridgeItem> _items = [];
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    final msg = widget.signedInMessage;
    if (msg != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      setState(() {
        _items.add(
          FridgeItem(
            id: '${DateTime.now().microsecondsSinceEpoch}',
            imagePath: x.path,
            name: trimmedName?.isEmpty ?? true ? null : trimmedName,
            detail: trimmedDetail?.isEmpty ?? true ? null : trimmedDetail,
            expiringSoon: details.expiringSoon,
          ),
        );
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.cameraUnavailable)),
        );
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

  void _onNavTap(int i) {
    final s = AppStringsScope.of(context).fridge;
    if (i == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    if (i == 2) {
      setState(() => _navIndex = 0);
      _captureFromCamera();
      return;
    }
    setState(() => _navIndex = i);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.comingSoon)),
    );
  }

  void _morph() {
    final s = AppStringsScope.of(context).fridge;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.addItemsFromCameraFirst)),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.morphPlaceholder)),
    );
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).fridge;
    final appTitle = AppStringsScope.of(context).app.title;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final stored = _items.length;
    final expiring = _items.where((e) => e.expiringSoon).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.paddingOf(context).top + 72),
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
                            borderColor: AppColors.primary.withValues(alpha: 0.3),
                            background: AppColors.primary.withValues(alpha: 0.05),
                            hoverBackground:
                                AppColors.primary.withValues(alpha: 0.1),
                            iconLeaf: true,
                            icon: Icons.receipt_long_rounded,
                            iconColor: AppColors.primary,
                            title: s.scanReceiptTitle,
                            subtitle: s.scanReceiptSubtitle,
                            onTap: _captureFromCamera,
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
                            onTap: _captureFromCamera,
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
                    if (_items.isEmpty)
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
                      ..._items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _IngredientRow(
                            item: item,
                            strings: s,
                            leafShape: _leaf,
                            onRemove: () => _removeItem(item.id),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _BlurredAppBar(title: appTitle),
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
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavBar(
              selectedIndex: _navIndex,
              strings: s,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
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

class _BlurredAppBar extends StatelessWidget {
  const _BlurredAppBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final user = FirebaseAuth.instance.currentUser;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, top + 8, 24, 12),
          color: AppColors.surface.withValues(alpha: 0.82),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              _UserAvatar(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final url = user?.photoURL;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _AvatarFallback(),
            )
          : const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainerHigh,
      child: Icon(
        Icons.person_rounded,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
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
    final title = item.name?.isNotEmpty == true ? item.name! : strings.unnamedItem;
    final subtitle = item.detail?.isNotEmpty == true
        ? item.detail!
        : strings.fromCameraNote;

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
              child: FridgeThumbnail(path: item.imagePath),
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
            child: Icon(
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
  const _MorphFab({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
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

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.strings,
    required this.onTap,
  });

  final int selectedIndex;
  final FridgeScreenStrings strings;
  final void Function(int index) onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: strings.navHome,
                selected: selectedIndex == 0,
                filled: true,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: strings.navRecipes,
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.center_focus_strong_rounded,
                label: strings.navScan,
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: strings.navProfile,
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected && filled;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (active)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  color: const Color(0xFFA8A29E),
                  size: 26,
                ),
              ),
            if (!active || !filled) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.primary
                      : const Color(0xFFA8A29E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
