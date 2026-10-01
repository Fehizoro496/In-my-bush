import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../catalog_providers.dart';
import '../data/catalog_mock_data.dart';
import '../data/catalog_models.dart';
import 'widgets/product_tile.dart';

/// M-Search — suggestions, producers, recent searches, trends, results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery ?? 'miel');
  late String _query = _controller.text;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    _controller.value = TextEditingValue(text: value, selection: TextSelection.collapsed(offset: value.length));
    setState(() => _query = value);
  }

  void _submit(String value) {
    ref.read(recentSearchesProvider.notifier).add(value);
    setState(() => _query = value);
  }

  void _openCatalogue({String? categorySlug}) {
    final notifier = ref.read(catalogQueryProvider.notifier);
    if (categorySlug != null) {
      notifier.selectCategory(categorySlug);
    } else {
      notifier.set(ProductQuery(q: _query));
    }
    ref.read(recentSearchesProvider.notifier).add(_query);
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            titleWidget: SearchInput(
              controller: _controller,
              hint: 'Rechercher un produit, un producteur…',
              autofocus: widget.initialQuery == null && q.isEmpty,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: _submit,
              onClear: () => _setQuery(''),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 40),
              children: [
                if (q.isNotEmpty) _Suggestions(query: q, onCategory: (slug) => _openCatalogue(categorySlug: slug), onText: _openCatalogue),
                if (q.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Producers(query: q),
                ],
                const SizedBox(height: 20),
                if (recents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SubTitle(
                          'Recherches récentes',
                          size: 15,
                          trailing: AppTextLink(
                            label: 'Effacer',
                            fontSize: 13,
                            color: AppColors.muted,
                            onTap: () => ref.read(recentSearchesProvider.notifier).clear(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final r in recents)
                              GestureDetector(
                                onTap: () => _setQuery(r),
                                child: RemovableChip(
                                  label: r,
                                  height: 36,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  leadingIcon: AppIcons.clock,
                                  background: AppColors.surface,
                                  foreground: AppColors.ink,
                                  border: AppColors.lineStrong,
                                  onRemove: () => ref.read(recentSearchesProvider.notifier).remove(r),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(AppIcons.trend, size: 17, color: AppColors.orange600),
                          const SizedBox(width: 6),
                          Text('Tendances cette semaine', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in CatalogMockData.trends)
                            Material(
                              color: AppColors.pomme100,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => _setQuery(t),
                                child: Container(
                                  height: 36,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  alignment: Alignment.center,
                                  child: Text(t, style: AppTypography.body(size: 14, weight: FontWeight.w600, color: AppColors.pomme800)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (q.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Results(query: q),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestions extends ConsumerWidget {
  const _Suggestions({required this.query, required this.onCategory, required this.onText});

  final String query;
  final ValueChanged<String> onCategory;
  final VoidCallback onText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(searchSuggestionsProvider(query)).valueOrNull ?? const <SearchSuggestion>[];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (final s in suggestions)
            InkWell(
              onTap: () => s.categorySlug != null ? onCategory(s.categorySlug!) : onText(),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
                child: Row(
                  children: [
                    Icon(AppIcons.byKey(s.icon), size: 18, color: AppColors.disabled),
                    const SizedBox(width: 12),
                    Expanded(child: _Highlighted(text: s.text, query: query)),
                    Text(s.meta, style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bold matching prefix ("**Miel** de litchi").
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final index = text.toLowerCase().indexOf(query.toLowerCase());
    final base = AppTypography.body(size: 15);
    if (index < 0) return Text(text, style: base);
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(text: text.substring(index, index + query.length), style: AppTypography.body(size: 15, weight: FontWeight.w700)),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}

class _Producers extends ConsumerWidget {
  const _Producers({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(searchShopsProvider(query)).valueOrNull ?? const <Shop>[];
    if (shops.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubTitle(
            'Producteurs',
            size: 15,
            trailing: AppTextLink(label: 'Voir tout', fontSize: 13, onTap: () => context.push(AppRoutes.seller(shops.first.slug))),
          ),
          const SizedBox(height: 10),
          for (final s in shops) ...[
            AppCard(
              radius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onTap: () => context.push(AppRoutes.seller(s.slug)),
              child: Row(
                children: [
                  AppAvatar(initials: s.avatar.initials, color: s.avatar.colorValue, size: 40, fontSize: 13),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                        Text(
                          '${formatRating(s.ratingAvg)} ★ · ${s.productCount} produits · ${s.distanceKm != null ? '${s.distanceKm} km' : s.city}',
                          style: AppTypography.body(size: 12, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(AppIcons.chevronRight, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchProductsProvider(query));
    return results.when(
      data: (items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Produits correspondants · ${items.length}', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const EmptyState(icon: AppIcons.search, title: 'Aucun résultat', message: 'Vérifiez l’orthographe ou essayez un autre mot.')
          else
            ProductCarousel(products: items),
        ],
      ),
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TwoColumnGrid(children: [ProductCardSkeleton(), ProductCardSkeleton()]),
      ),
      error: (e, _) => ErrorState(error: e),
    );
  }
}
