import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

enum MainTab { home, recipes, scan, profile }

class MainBottomNav extends StatelessWidget {
  const MainBottomNav({
    super.key,
    required this.selected,
    required this.strings,
    required this.onTap,
  });

  final MainTab selected;
  final FridgeScreenStrings strings;
  final ValueChanged<MainTab> onTap;

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
                selected: selected == MainTab.home,
                filled: true,
                onTap: () => onTap(MainTab.home),
              ),
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: strings.navRecipes,
                selected: selected == MainTab.recipes,
                filled: selected == MainTab.recipes,
                onTap: () => onTap(MainTab.recipes),
              ),
              _NavItem(
                icon: Icons.center_focus_strong_rounded,
                label: strings.navScan,
                selected: selected == MainTab.scan,
                filled: selected == MainTab.scan,
                onTap: () => onTap(MainTab.scan),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: strings.navProfile,
                selected: selected == MainTab.profile,
                filled: selected == MainTab.profile,
                onTap: () => onTap(MainTab.profile),
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
            if (!active) ...[
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
