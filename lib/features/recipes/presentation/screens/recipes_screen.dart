import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../fridge/data/fridge_repository.dart';
import '../../../fridge/domain/fridge_item.dart';
import '../../../shell/presentation/widgets/blurred_app_bar.dart';
import '../../../shell/presentation/widgets/main_bottom_nav.dart';
import '../../data/recipes_repository.dart';
import '../../domain/recipe.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({
    super.key,
    this.onNavigateTab,
    RecipesRepository? repository,
  }) : _repository = repository;

  final ValueChanged<MainTab>? onNavigateTab;
  final RecipesRepository? _repository;

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  late final RecipesRepository _repo;
  final FridgeRepository _fridge = FridgeRepository.instance;

  List<Recipe> _recipes = const [];
  Object? _error;
  bool _loading = false;
  String? _filter;
  String _mode = 'idle';

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? RecipesRepository();
    _fridge.items.addListener(_onFridgeChanged);
    if (_fridge.items.value.isNotEmpty) {
      _generate();
    }
  }

  @override
  void dispose() {
    _fridge.items.removeListener(_onFridgeChanged);
    super.dispose();
  }

  void _onFridgeChanged() {
    if (_fridge.items.value.isEmpty) {
      setState(() {
        _recipes = const [];
        _error = null;
        _mode = 'idle';
      });
    }
  }

  Future<void> _generate() async {
    final ingredients = _fridge.items.value
        .map((e) => e.toIngredientString())
        .toList(growable: false);
    if (ingredients.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await _repo.generate(ingredients: ingredients, count: 6);
      if (!mounted) return;
      setState(() {
        _recipes = res.recipes;
        _mode = res.mode;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(MainTab tab) => widget.onNavigateTab?.call(tab);

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).recipes;
    final appTitle = AppStringsScope.of(context).app.title;
    final bottomInset = MediaQuery.paddingOf(context).bottom + 140;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _generate,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.paddingOf(context).top + 72),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
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
                    const SizedBox(height: 24),
                    _IngredientChipsRow(
                      items: _fridge.items.value,
                      selected: _filter,
                      allLabel: s.chipAll,
                      onSelect: (name) =>
                          setState(() => _filter = _filter == name ? null : name),
                    ),
                    const SizedBox(height: 24),
                    if (_loading && _recipes.isEmpty)
                      _LoadingBlock(strings: s)
                    else if (_error != null && _recipes.isEmpty)
                      _ErrorBlock(
                        strings: s,
                        error: _error!,
                        onRetry: _generate,
                      )
                    else if (_recipes.isEmpty)
                      _EmptyBlock(
                        strings: s,
                        onMorph: _fridge.items.value.isEmpty ? null : _generate,
                      )
                    else ...[
                      if (_mode != 'idle')
                        _ModeBadge(mode: _mode, label: s.morphActiveLabel),
                      const SizedBox(height: 16),
                      for (final r in _visibleRecipes())
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: _RecipeCard(recipe: r, strings: s),
                        ),
                    ],
                    const SizedBox(height: 24),
                    _ScanReceiptBanner(
                      strings: s,
                      onTap: () => _select(MainTab.scan),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlurredAppBar(
            title: appTitle,
            onLeadingTap: () => _select(MainTab.home),
          ),
        ),
      ],
    );
  }

  Iterable<Recipe> _visibleRecipes() {
    if (_filter == null) return _recipes;
    return _recipes.where(
      (r) => r.usesIngredients.any(
        (i) => i.toLowerCase().contains(_filter!.toLowerCase()),
      ),
    );
  }
}

class _IngredientChipsRow extends StatelessWidget {
  const _IngredientChipsRow({
    required this.items,
    required this.selected,
    required this.allLabel,
    required this.onSelect,
  });

  final List<FridgeItem> items;
  final String? selected;
  final String allLabel;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            icon: Icons.filter_list_rounded,
            label: allLabel,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _Chip(
                label: it.name ?? 'Ingredient',
                selected: selected == it.name,
                onTap: () => onSelect(it.name),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.primary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.mode, required this.label});

  final String mode;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            '$label · ${mode.toUpperCase()}',
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.strings});

  final Recipe recipe;
  final RecipesScreenStrings strings;

  String _difficultyLabel() {
    switch (recipe.difficulty) {
      case RecipeDifficulty.beginner:
        return strings.difficultyBeginner;
      case RecipeDifficulty.intermediate:
        return strings.difficultyIntermediate;
      case RecipeDifficulty.pro:
        return strings.difficultyPro;
      case RecipeDifficulty.unknown:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final coveragePct = (recipe.coverage * 100).clamp(0, 100).toInt();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(48),
        bottomRight: Radius.circular(48),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: Container(
        color: AppColors.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipeImageUrl(recipe),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primary.withValues(alpha: 0.35),
                        size: 64,
                      ),
                    ),
                  ),
                  if (recipe.featured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _Badge(
                        label: strings.featuredLabel.toUpperCase(),
                        icon: Icons.bookmark_rounded,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MetaPill(
                        icon: Icons.schedule_rounded,
                        label: '${recipe.minutes} ${strings.minutesSuffix}',
                      ),
                      const SizedBox(width: 8),
                      if (_difficultyLabel().isNotEmpty)
                        _MetaPill(
                          icon: Icons.local_fire_department_rounded,
                          label: _difficultyLabel().toUpperCase(),
                          accent: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (recipe.tagline.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      recipe.tagline,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        height: 1.45,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (recipe.coverage > 0)
                    Text(
                      '${strings.usesPrefix} $coveragePct% ${strings.usesSuffix}',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  const SizedBox(height: 12),
                  _StartCookingButton(label: strings.startCookingCta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final bg = accent
        ? AppColors.secondaryContainer.withValues(alpha: 0.3)
        : AppColors.surfaceContainerLow;
    final fg = accent ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartCookingButton extends StatelessWidget {
  const _StartCookingButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.strings});

  final RecipesScreenStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            strings.loadingTitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            strings.loadingSubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({
    required this.strings,
    required this.error,
    required this.onRetry,
  });

  final RecipesScreenStrings strings;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            strings.errorTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: Text(strings.errorRetry),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock({required this.strings, required this.onMorph});

  final RecipesScreenStrings strings;
  final VoidCallback? onMorph;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 56,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            strings.emptyTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.emptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 14,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          if (onMorph != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onMorph,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(strings.generateCta),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScanReceiptBanner extends StatelessWidget {
  const _ScanReceiptBanner({required this.strings, required this.onTap});

  final RecipesScreenStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            strings.scanReceiptBanner,
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: 13,
              height: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.center_focus_strong_rounded),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            label: Text(strings.scanReceiptCta),
          ),
        ],
      ),
    );
  }
}
