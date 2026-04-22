import 'package:flutter/material.dart';

import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../fridge/presentation/screens/my_fridge_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../recipes/presentation/screens/recipes_screen.dart';
import '../../../scan/presentation/screens/scan_screen.dart';
import '../widgets/main_bottom_nav.dart';

/// Top-level chrome: owns the selected tab and swaps the visible page.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.signedInMessage});

  final String? signedInMessage;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  MainTab _tab = MainTab.home;

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).fridge;

    final Widget body = switch (_tab) {
      MainTab.home => MyFridgeScreen(
        signedInMessage: widget.signedInMessage,
        onNavigateTab: _select,
      ),
      MainTab.recipes => RecipesScreen(onNavigateTab: _select),
      MainTab.scan => ScanScreen(onNavigateTab: _select),
      MainTab.profile => ProfileScreen(onNavigateTab: _select),
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MainBottomNav(
              selected: _tab,
              strings: s,
              onTap: _select,
            ),
          ),
        ],
      ),
    );
  }

  void _select(MainTab tab) {
    if (_tab == tab) return;
    setState(() => _tab = tab);
  }
}
