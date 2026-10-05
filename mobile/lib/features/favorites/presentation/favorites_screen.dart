import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../../catalog/data/models/models.dart';
import '../../catalog/presentation/widgets/product_tile.dart';
import '../favorites_providers.dart';

/// M-Favorites — favorite products and followed producers.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(favoritesControllerProvider);
    final shops = ref.watch(followedShopsProvider);
    final productList = products.valueOrNull ?? const <Product>[];
    final promoCount = productList.where((p) => p.compareAtPrice != null).length;
    final lowCount = productList.where((p) => p.isLowStock).length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Favoris',
            fallback: AppRoutes.profile,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            bottomGap: 6,
            actions: [AppTextLink(label: 'Modifier', minHeight: 40, onTap: () {})],
            bottom: UnderlineTabs(
              showBaseline: false,
              labels: [
                'Produits (${productList.length})',
                'Producteurs (${shops.valueOrNull?.length ?? 0})',
              ],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (promoCount > 0 || lowCount > 0) ...[
                  InfoBanner(
                    icon: AppIcons.percent,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$promoCount favori${promoCount > 1 ? 's' : ''} en promotion',
                            style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.orangeInk),
                          ),
                          TextSpan(text: lowCount > 0 ? ' et $lowCount bientôt épuisé${lowCount > 1 ? 's' : ''}' : ''),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (_tab == 0)
                  AsyncValueView<List<Product>>(
                    value: products,
                    onRetry: () => ref.invalidate(favoritesControllerProvider),
                    loading: () => const TwoColumnGrid(children: [ProductCardSkeleton(), ProductCardSkeleton()]),
                    data: (list) => list.isEmpty
                        ? EmptyState(
                            icon: AppIcons.heart,
                            title: 'Aucun favori',
                            message: 'Touchez le cœur d’un produit pour le retrouver ici.',
                            actionLabel: 'Explorer les produits',
                            onAction: () => context.go(AppRoutes.home),
                          )
                        : ProductGrid(products: list),
                  )
                else
                  AsyncValueView<List<Shop>>(
                    value: shops,
                    onRetry: () => ref.invalidate(followedShopsProvider),
                    data: (list) => list.isEmpty
                        ? const EmptyState(icon: AppIcons.store, title: 'Aucun producteur suivi')
                        : Column(
                            children: [
                              for (final s in list) ...[
                                SellerCard(
                                  name: s.name,
                                  location: s.location,
                                  avatar: s.avatar,
                                  cover: s.cover,
                                  rating: s.ratingAvg,
                                  reviewCount: s.ratingCount,
                                  productCount: s.productCount,
                                  since: s.since,
                                  tags: s.tags,
                                  verified: s.verified,
                                  onTap: () => context.push(AppRoutes.seller(s.slug)),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
