import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/catalog_repository.dart';
import '../../data/fridge_repository.dart';
import '../../domain/fridge_item.dart';

enum _UnitType { pieces, weight, volume }

extension on _UnitType {
  String get defaultUnit => switch (this) {
    _UnitType.pieces => 'pcs',
    _UnitType.weight => 'kg',
    _UnitType.volume => 'L',
  };
}

/// Manual-entry flow, opened as a full-screen page from MyFridge.
class AddToFridgeScreen extends StatefulWidget {
  const AddToFridgeScreen({
    super.key,
    CatalogRepository? catalog,
  }) : _catalog = catalog;

  final CatalogRepository? _catalog;

  @override
  State<AddToFridgeScreen> createState() => _AddToFridgeScreenState();
}

class _AddToFridgeScreenState extends State<AddToFridgeScreen> {
  late final CatalogRepository _catalog;
  final FridgeRepository _fridge = FridgeRepository.instance;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: '1');

  List<IngredientCategory>? _categories;
  List<CommonIngredient>? _commonly;
  Object? _catalogError;
  bool _loading = true;

  IngredientCategory? _selectedCategory;
  _UnitType _unit = _UnitType.weight;
  int _expiryDays = 3;

  @override
  void initState() {
    super.initState();
    _catalog = widget._catalog ?? CatalogRepository();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _catalogError = null;
    });
    try {
      final results = await Future.wait([
        _catalog.categories(),
        _catalog.commonlyAdded(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<IngredientCategory>;
        _commonly = results[1] as List<CommonIngredient>;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _catalogError = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _searchController.clear();
      _qtyController.text = '1';
      _selectedCategory = null;
      _unit = _UnitType.weight;
      _expiryDays = 3;
    });
  }

  void _prefill(CommonIngredient item) {
    setState(() {
      _searchController.text = item.name;
      _expiryDays = item.shelfLifeDays > 0 ? item.shelfLifeDays : _expiryDays;
      final match = (_categories ?? const [])
          .where((c) => c.id == item.category)
          .toList();
      if (match.isNotEmpty) _selectedCategory = match.first;
    });
  }

  void _confirm() {
    final s = AppStringsScope.of(context).addToFridge;
    final name = _searchController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.missingName)));
      return;
    }
    final qty = double.tryParse(_qtyController.text.trim());
    final expiresOn = DateTime.now().add(Duration(days: _expiryDays));
    final item = FridgeItem(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      category: _selectedCategory?.id,
      quantity: qty,
      unit: qty != null ? _unit.defaultUnit : null,
      expiringSoon: _expiryDays <= 3,
      expiresOn: expiresOn,
    );
    _fridge.add(item);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(s.savedSnack)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).addToFridge;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final expiresOn = DateTime.now().add(Duration(days: _expiryDays));

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
        ),
        title: Text(
          AppStringsScope.of(context).app.title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: s.quickCategoriesTitle, trailing: s.viewAll),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                )
              else if (_catalogError != null)
                _InlineError(error: _catalogError!, onRetry: _load)
              else
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in _categories ?? const <IngredientCategory>[])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            category: c,
                            selected: _selectedCategory?.id == c.id,
                            onTap: () =>
                                setState(() => _selectedCategory = c),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              _SectionLabel(label: s.quantityLabel),
              const SizedBox(height: 12),
              _QuantityRow(controller: _qtyController),
              const SizedBox(height: 16),
              _UnitPicker(
                unit: _unit,
                onChanged: (u) => setState(() => _unit = u),
                piecesLabel: s.unitPieces,
                weightLabel: s.unitWeight,
                volumeLabel: s.unitVolume,
              ),
              const SizedBox(height: 32),
              _SectionLabel(label: s.expiryTitle),
              const SizedBox(height: 12),
              _ExpiryCard(label: s.bestBefore, date: expiresOn),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ExpiryOption(
                      days: 3,
                      label: s.shortLife,
                      sub: s.shortLifeLabel,
                      selected: _expiryDays == 3,
                      onTap: () => setState(() => _expiryDays = 3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExpiryOption(
                      days: 10,
                      label: s.longLife,
                      sub: s.longLifeLabel,
                      selected: _expiryDays == 10,
                      onTap: () => setState(() => _expiryDays = 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _SectionHeader(title: s.commonlyAddedTitle),
              const SizedBox(height: 12),
              if ((_commonly ?? const []).isEmpty && !_loading)
                Text(
                  s.commonlyAddedEmpty,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                )
              else
                for (final c in _commonly ?? const <CommonIngredient>[])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CommonlyAddedTile(
                      item: c,
                      onTap: () => _prefill(c),
                    ),
                  ),
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: _confirm,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(s.confirmCta),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _clear,
                  child: Text(s.clearCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: GoogleFonts.beVietnamPro(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final IngredientCategory category;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    switch (category.icon) {
      case 'dairy':
        return Icons.local_drink_rounded;
      case 'protein':
        return Icons.egg_alt_rounded;
      case 'fruit':
        return Icons.apple_rounded;
      case 'grain':
        return Icons.grain_rounded;
      case 'sauce':
        return Icons.soup_kitchen_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icon,
                size: 16,
                color: selected
                    ? AppColors.onPrimaryContainer
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                category.label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({required this.controller});

  final TextEditingController controller;

  double get _value => double.tryParse(controller.text) ?? 0;

  void _adjust(double delta) {
    final next = (_value + delta).clamp(0, 9999);
    controller.text = next % 1 == 0 ? '${next.toInt()}' : next.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _adjust(-0.5),
            icon: const Icon(Icons.remove_rounded),
            color: AppColors.primary,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _adjust(0.5),
            icon: const Icon(Icons.add_rounded),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _UnitPicker extends StatelessWidget {
  const _UnitPicker({
    required this.unit,
    required this.onChanged,
    required this.piecesLabel,
    required this.weightLabel,
    required this.volumeLabel,
  });

  final _UnitType unit;
  final ValueChanged<_UnitType> onChanged;
  final String piecesLabel;
  final String weightLabel;
  final String volumeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UnitButton(
          label: piecesLabel,
          selected: unit == _UnitType.pieces,
          onTap: () => onChanged(_UnitType.pieces),
        ),
        const SizedBox(width: 8),
        _UnitButton(
          label: weightLabel,
          selected: unit == _UnitType.weight,
          onTap: () => onChanged(_UnitType.weight),
        ),
        const SizedBox(width: 8),
        _UnitButton(
          label: volumeLabel,
          selected: unit == _UnitType.volume,
          onTap: () => onChanged(_UnitType.volume),
        ),
      ],
    );
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  const _ExpiryCard({required this.label, required this.date});

  final String label;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            DateFormat('MMM d, yyyy').format(date),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryOption extends StatelessWidget {
  const _ExpiryOption({
    required this.days,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });

  final int days;
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryContainer.withValues(alpha: 0.2)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommonlyAddedTile extends StatelessWidget {
  const _CommonlyAddedTile({required this.item, required this.onTap});

  final CommonIngredient item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${item.category} · shelf ${item.shelfLifeDays}d',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.toString(),
              style: GoogleFonts.beVietnamPro(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
