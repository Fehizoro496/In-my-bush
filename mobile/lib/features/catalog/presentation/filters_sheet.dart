import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../catalog_providers.dart';
import '../data/models/models.dart';

/// M-Filters — bottom sheet (`/filtres`) editing a draft of the catalogue
/// query; "Afficher N produits" applies it.
class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key});

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  static const double _priceMax = 20000;
  late ProductQuery _draft;

  static const _distances = <String, int?>{
    'Moins de 5 km': 5,
    'Moins de 15 km': 15,
    'Moins de 50 km': 50,
    'Toute l’île': null,
  };
  static const _ratings = <String, double>{'4,5 et +': 4.5, '4 et +': 4, '3 et +': 3};
  static const _types = ['Frais', 'Transformé', 'Artisanal', 'Panier composé'];
  static const _sellerOptions = <String, IconData>{
    'Vendeur vérifié': AppIcons.shield,
    'Retrait sur place': AppIcons.store,
    'Livraison aujourd’hui': AppIcons.truck,
  };

  @override
  void initState() {
    super.initState();
    _draft = ref.read(catalogQueryProvider);
  }

  double _clampPrice(double v) => v < 0 ? 0 : (v > _priceMax ? _priceMax : v);

  void _update(ProductQuery query) => setState(() => _draft = query);

  Set<String> _toggle(Set<String> set, String value) {
    final copy = Set<String>.of(set);
    if (!copy.remove(value)) copy.add(value);
    return copy;
  }

  Widget _group(String title, List<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTypography.body(size: 16, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(productCountProvider(_draft));
    final min = (_draft.minPrice ?? 1000).toDouble();
    final max = (_draft.maxPrice ?? 10000).toDouble();

    return AppSheetScaffold(
      title: 'Filtres',
      actionLabel: 'Réinitialiser',
      onAction: () => _update(const ProductQuery()),
      footer: AppButton(
        label: count.when(
          data: (n) => 'Afficher ${plural(n, 'produit')}',
          loading: () => 'Afficher les produits',
          error: (_, __) => 'Afficher les produits',
        ),
        expand: true,
        onPressed: () {
          ref.read(catalogQueryProvider.notifier).set(_draft);
          Navigator.of(context).maybePop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(child: Text('Prix', style: AppTypography.body(size: 16, weight: FontWeight.w700))),
              Text('par unité', style: AppTypography.body(size: 13, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.pomme500,
              inactiveTrackColor: AppColors.lineStrong,
              thumbColor: Colors.white,
              overlayColor: const Color(0x478CC63F),
              rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
            ),
            child: RangeSlider(
              min: 0,
              max: _priceMax,
              divisions: 40,
              values: RangeValues(_clampPrice(min), _clampPrice(max)),
              onChanged: (v) => _update(_draft.copyWith(minPrice: v.start.round(), maxPrice: v.end.round())),
            ),
          ),
          Row(
            children: [
              Expanded(child: _PriceBox(label: 'Min', value: formatAriary(min))),
              const SizedBox(width: 10),
              Expanded(child: _PriceBox(label: 'Max', value: formatAriary(max))),
            ],
          ),
          const SizedBox(height: 22),
          _group('Distance', [
            for (final entry in _distances.entries)
              AppChoiceChip(
                label: entry.key,
                selected: _draft.maxDistanceKm == entry.value,
                onTap: () => _update(entry.value == null
                    ? _draft.copyWith(clearDistance: true)
                    : _draft.copyWith(maxDistanceKm: entry.value)),
              ),
          ]),
          const SizedBox(height: 22),
          _group('Note minimale', [
            for (final entry in _ratings.entries)
              AppChoiceChip(
                label: entry.key,
                icon: AppIcons.star,
                selected: _draft.minRating == entry.value,
                onTap: () => _update(_draft.minRating == entry.value
                    ? _draft.copyWith(clearRating: true)
                    : _draft.copyWith(minRating: entry.value)),
              ),
          ]),
          const SizedBox(height: 22),
          _group('Type de produit', [
            for (final t in _types)
              AppChoiceChip(
                label: t,
                selected: _draft.productTypes.contains(t),
                onTap: () => _update(_draft.copyWith(productTypes: _toggle(_draft.productTypes, t))),
              ),
          ]),
          const SizedBox(height: 22),
          _group('Vendeur', [
            for (final entry in _sellerOptions.entries)
              AppChoiceChip(
                label: entry.key,
                icon: entry.value,
                selected: _draft.sellerOptions.contains(entry.key),
                onTap: () => _update(_draft.copyWith(sellerOptions: _toggle(_draft.sellerOptions, entry.key))),
              ),
          ]),
          const SizedBox(height: 22),
          Text('Disponibilité', style: AppTypography.body(size: 16, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          SwitchRow(
            title: 'En stock uniquement',
            value: _draft.inStockOnly,
            onChanged: (v) => _update(_draft.copyWith(inStockOnly: v)),
          ),
          SwitchRow(
            title: 'Livraison aujourd’hui',
            value: _draft.deliveryToday,
            onChanged: (v) => _update(_draft.copyWith(deliveryToday: v)),
          ),
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTypography.body(size: 12, weight: FontWeight.w600, color: AppColors.muted)),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lineStrong, width: 1.5),
          ),
          child: Text(value, style: AppTypography.body(size: 15, weight: FontWeight.w500)),
        ),
      ],
    );
  }
}
