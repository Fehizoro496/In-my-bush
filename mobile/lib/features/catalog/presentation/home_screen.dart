import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../cart/presentation/widgets/cart_icon_button.dart';
import '../catalog_providers.dart';
import '../data/catalog_models.dart';
import 'widgets/product_tile.dart';

/// M-Home — home + catalogue ("Explorer" merged in).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();
  final _catalogueKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis == Axis.vertical && notification.metrics.extentAfter < 600) {
      ref.read(catalogListProvider.notifier).loadMore();
    }
    return false;
  }

  void _scrollToCatalogue() {
    final context = _catalogueKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    }
  }

  void _pickCategory(String? slug) {
    ref.read(catalogQueryProvider.notifier).selectCategory(slug);
    _scrollToCatalogue();
  }

  Future<void> _refresh() async {
    ref.invalidate(homeFeedProvider);
    ref.invalidate(catalogListProvider);
    await ref.read(homeFeedProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            color: AppColors.pomme700,
            onRefresh: _refresh,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                _Header(onFilters: () => context.push(AppRoutes.filters)),
                const SizedBox(height: 28),
                _CategoryShortcuts(categories: categories, onPick: _pickCategory),
                const SizedBox(height: 28),
                _PromoBanner(onTap: () => _pickCategory(null)),
                const SizedBox(height: 28),
                feed.when(
                  data: (data) => _FeedSections(feed: data, onSeeAll: _scrollToCatalogue),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TwoColumnGrid(children: [
                      ProductCardSkeleton(),
                      ProductCardSkeleton(),
                      ProductCardSkeleton(),
                      ProductCardSkeleton(),
                    ]),
                  ),
                  error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(homeFeedProvider)),
                ),
                const SizedBox(height: 36),
                KeyedSubtree(key: _catalogueKey, child: _CatalogueSection(categories: categories)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.onFilters});

  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final area = ref.watch(homeFeedProvider).valueOrNull?.deliveryArea ?? 'Analakely, Antananarivo';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AppLogo(),
              Spacer(),
              CartIconButton(),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => context.push(AppRoutes.addresses),
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 32),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.pin, size: 18, color: AppColors.pomme700),
                  const SizedBox(width: 6),
                  Text('Livrer à', style: AppTypography.body(size: 13, color: AppColors.muted)),
                  const SizedBox(width: 6),
                  Text(area, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  const Icon(AppIcons.chevronDown, size: 16, color: AppColors.ink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SearchBarButton(
                  placeholder: 'Tomates, miel, vanille…',
                  onTap: () => context.push(AppRoutes.search),
                ),
              ),
              const SizedBox(width: 10),
              AppIconButton(
                icon: AppIcons.sliders,
                style: AppIconButtonStyle.dark,
                size: 50,
                radius: 14,
                semanticLabel: 'Filtres',
                onPressed: onFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryShortcuts extends StatelessWidget {
  const _CategoryShortcuts({required this.categories, required this.onPick});

  final List<Category> categories;
  final ValueChanged<String?> onPick;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(height: 102);
    }
    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final c = categories[index];
          return CategoryShortcut(
            label: c.label,
            icon: AppIcons.byKey(c.visual.icon),
            background: c.visual.tintColor,
            foreground: c.visual.inkColor,
            onTap: () => onPick(c.slug),
          );
        },
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 164),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.pomme900, borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -40,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(color: AppColors.pomme800, shape: BoxShape.circle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppTag(
                              label: '−20 % jusqu’à dimanche',
                              background: AppColors.orange500,
                              foreground: AppColors.onSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Paniers de saison des Hautes Terres',
                              style: AppTypography.display(size: 23, weight: FontWeight.w700, color: AppColors.pomme50, height: 1.12),
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'J’en profite',
                              trailingIcon: AppIcons.arrowRight,
                              size: AppButtonSize.medium,
                              fontSize: 14,
                              onPressed: onTap,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(AppIcons.basket, size: 72, color: AppColors.pommeLight),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 18, height: 6, decoration: BoxDecoration(color: AppColors.pomme700, borderRadius: BorderRadius.circular(999))),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.switchOff, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.switchOff, shape: BoxShape.circle)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedSections extends StatelessWidget {
  const _FeedSections({required this.feed, required this.onSeeAll});

  final HomeFeed feed;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Recommandé pour vous',
          actionLabel: 'Voir tout',
          onAction: onSeeAll,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ProductGrid(products: feed.recommended),
        ),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Promotions',
          badge: const AppTag(
            label: 'jusqu’à −30 %',
            background: AppColors.orange100,
            foreground: AppColors.orange700,
            fontWeight: FontWeight.w800,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          ),
          actionLabel: 'Voir tout',
          onAction: onSeeAll,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 14),
        ProductCarousel(products: feed.promotions),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Producteurs populaires',
          actionLabel: 'Voir tout',
          onAction: () => context.push(AppRoutes.search),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 14),
        HorizontalCards(
          itemWidth: 148,
          children: [
            for (final s in feed.popularShops)
              SellerMiniCard(
                name: s.name,
                location: s.city,
                avatar: s.avatar,
                ringColor: hexColor(s.ringColor ?? '#B2DA6A'),
                rating: s.ratingAvg,
                productCount: s.productCount,
                onTap: () => context.push(AppRoutes.seller(s.slug)),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Découvrir près de chez vous'),
              const SizedBox(height: 14),
              _NearbyMapCard(count: feed.nearbyProducerCount, onTap: onSeeAll),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Nouveautés',
          actionLabel: 'Voir tout',
          onAction: onSeeAll,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        const SizedBox(height: 14),
        ProductCarousel(products: feed.newArrivals),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Populaires · produits locaux'),
              const SizedBox(height: 14),
              AppCard(
                padding: EdgeInsets.zero,
                radius: 16,
                clip: true,
                child: Column(
                  children: [
                    for (var i = 0; i < feed.popular.length; i++)
                      ProductRankRow(
                        rank: i + 1,
                        name: feed.popular[i].name,
                        subtitle: '${feed.popular[i].shopName} · ${feed.popular[i].shopCity}',
                        price: feed.popular[i].price,
                        unitLabel: feed.popular[i].unitLabel.startsWith('pot') ? 'pot' : feed.popular[i].unitLabel,
                        visual: feed.popular[i].visual,
                        showDivider: i > 0,
                        onTap: () => context.push(AppRoutes.product(feed.popular[i].slug)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Illustrated "map" of nearby producers.
class _NearbyMapCard extends StatelessWidget {
  const _NearbyMapCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  Widget _pin(double left, double top, Color color) => Positioned(
        left: left,
        top: top,
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(999),
                topRight: Radius.circular(999),
                bottomRight: Radius.circular(999),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: const [BoxShadow(color: Color(0x331F2318), blurRadius: 8, offset: Offset(0, 3))],
            ),
            alignment: Alignment.center,
            child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      radius: 20,
      clip: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: ColoredBox(
              color: AppColors.mapBg,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: -20,
                    top: 40,
                    child: Transform.rotate(angle: -12 * math.pi / 180, child: Container(width: 460, height: 14, color: Colors.white)),
                  ),
                  Positioned(
                    left: 120,
                    top: -20,
                    child: Transform.rotate(angle: 18 * math.pi / 180, child: Container(width: 12, height: 220, color: Colors.white)),
                  ),
                  Positioned(
                    right: 30,
                    top: 70,
                    child: Container(
                      width: 90,
                      height: 60,
                      decoration: BoxDecoration(color: AppColors.mapPatch, borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  _pin(60, 40, AppColors.pomme700),
                  _pin(250, 30, AppColors.orange600),
                  _pin(300, 92, AppColors.pomme700),
                  _pin(110, 96, AppColors.pomme700),
                  Positioned(
                    left: 172,
                    top: 72,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.infoStrong,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Color(0x332F6DA8), spreadRadius: 6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$count producteurs à moins de 15 km', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Retrait à la ferme ou livraison le jour même',
                        style: AppTypography.body(size: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppIconButton(
                  icon: AppIcons.arrowRight,
                  style: AppIconButtonStyle.primary,
                  semanticLabel: 'Voir la carte',
                  onPressed: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueSection extends ConsumerWidget {
  const _CatalogueSection({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(catalogQueryProvider);
    final list = ref.watch(catalogListProvider);
    final controller = ref.read(catalogQueryProvider.notifier);
    final chipCategories = categories.where((c) => c.slug != 'produits-locaux' && c.slug != 'artisanat').toList();

    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.sand, width: 8))),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'Tous les produits',
                    style: AppTypography.display(size: 24, weight: FontWeight.w700, letterSpacing: -0.24),
                  ),
                ),
                Text(
                  plural(list.valueOrNull?.totalItems ?? 0, 'produit'),
                  style: AppTypography.body(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ChipScroller(
            children: [
              AppChoiceChip(
                label: 'Tout',
                tone: ChipTone.forest,
                height: 38,
                selected: query.categorySlug == null,
                onTap: () => controller.selectCategory(null),
              ),
              for (final c in chipCategories)
                AppChoiceChip(
                  label: c.label,
                  tone: ChipTone.forest,
                  height: 38,
                  selected: query.categorySlug == c.slug,
                  onTap: () => controller.selectCategory(c.slug),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FiltersButton(count: query.activeFilterCount, onTap: () => context.push(AppRoutes.filters)),
                const SizedBox(width: 8),
                Expanded(
                  child: Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.lineStrong, width: 1.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        final sort = await showOptionsSheet<ProductSort>(
                          context,
                          title: 'Trier par',
                          options: ProductSort.values,
                          labelOf: (s) => s.label,
                          selected: query.sort,
                        );
                        if (sort != null) controller.setSort(sort);
                      },
                      child: SizedBox(
                        height: 44,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Trier : ${query.sort.label}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(size: 14, weight: FontWeight.w600),
                                ),
                              ),
                              const Icon(AppIcons.chevronDown, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: AppIcons.grid,
                  iconSize: 18,
                  style: AppIconButtonStyle.outline,
                  semanticLabel: 'Toutes les catégories',
                  onPressed: () => context.push(AppRoutes.categories),
                ),
              ],
            ),
          ),
          if (query.maxDistanceKm != null || query.minRating != null || query.inStockOnly) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (query.maxDistanceKm != null)
                    RemovableChip(
                      label: query.maxDistanceKm! >= 1000 ? 'Toute l’île' : 'Moins de ${query.maxDistanceKm} km',
                      onRemove: controller.clearDistance,
                    ),
                  if (query.minRating != null)
                    RemovableChip(
                      label: '${formatRating(query.minRating!)} et +',
                      leadingIcon: AppIcons.star,
                      onRemove: () => controller.set(query.copyWith(clearRating: true)),
                    ),
                  if (query.inStockOnly)
                    RemovableChip(
                      label: 'En stock',
                      onRemove: () => controller.set(query.copyWith(inStockOnly: false)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: list.when(
              data: (page) {
                if (page.items.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.search,
                    title: 'Aucun produit',
                    message: 'Essayez d’élargir la distance ou de retirer un filtre.',
                    actionLabel: 'Réinitialiser les filtres',
                    onAction: controller.reset,
                  );
                }
                return Column(
                  children: [
                    ProductGrid(
                      products: page.items,
                      trailing: page.hasMore ? const [ProductCardSkeleton(), ProductCardSkeleton()] : const [],
                    ),
                    if (page.hasMore) ...[
                      const SizedBox(height: 12),
                      Text('Chargement de la suite…', style: AppTypography.body(size: 13, color: AppColors.muted)),
                    ],
                  ],
                );
              },
              loading: () => const TwoColumnGrid(children: [
                ProductCardSkeleton(),
                ProductCardSkeleton(),
                ProductCardSkeleton(),
                ProductCardSkeleton(),
              ]),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(catalogListProvider)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersButton extends StatelessWidget {
  const _FiltersButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.sliders, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text('Filtres', style: AppTypography.body(size: 14, weight: FontWeight.w700, color: Colors.white)),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  CountBadge(
                    count: count,
                    size: 20,
                    background: AppColors.pomme500,
                    foreground: AppColors.onPrimary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
