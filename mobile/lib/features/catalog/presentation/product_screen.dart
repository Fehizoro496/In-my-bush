import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../cart/cart_providers.dart';
import '../../favorites/favorites_providers.dart';
import '../catalog_providers.dart';
import '../data/catalog_models.dart';
import 'widgets/product_tile.dart';

/// M-Product — product page.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(slug));
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: product.when(
        data: (p) => _ProductView(product: p),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.all(8), child: AppBackButton()),
              Expanded(child: Center(child: ErrorState(error: e, onRetry: () => ref.invalidate(productProvider(slug))))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductView extends ConsumerStatefulWidget {
  const _ProductView({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<_ProductView> {
  int _quantity = 1;
  int _tab = 0;
  bool _added = false;

  Product get p => widget.product;

  Future<void> _addToCart() async {
    if (_added) {
      context.push(AppRoutes.cart);
      return;
    }
    await ref.read(cartControllerProvider.notifier).add(p, quantity: _quantity);
    if (mounted) setState(() => _added = true);
  }

  Future<void> _buyNow() async {
    if (!_added) await ref.read(cartControllerProvider.notifier).add(p, quantity: _quantity);
    if (mounted) context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(isFavoriteProvider(p.id));
    final shop = ref.watch(shopProvider(p.shopSlug)).valueOrNull;
    final reviews = ref.watch(productReviewsProvider(p.id)).valueOrNull ?? const <Review>[];
    final similar = ref.watch(similarProductsProvider(p.slug)).valueOrNull ?? const <Product>[];
    final top = MediaQuery.of(context).padding.top;
    final distance = p.distanceKm ?? shop?.distanceKm;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 380,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ProductPhoto(
                        visual: p.visual,
                        imageUrl: p.imageUrl,
                        iconSize: 120,
                        photoLabel: 'Photo produit · 1 / 5',
                        labelSize: 11,
                        labelPadding: const EdgeInsets.only(left: 16, bottom: 44),
                      ),
                      Positioned(
                        top: 12 + top,
                        left: 12,
                        right: 12,
                        child: Row(
                          children: [
                            AppIconButton(
                              icon: AppIcons.arrowLeft,
                              style: AppIconButtonStyle.glass,
                              semanticLabel: 'Retour',
                              onPressed: () => popOrGo(context, AppRoutes.home),
                            ),
                            const Spacer(),
                            AppIconButton(
                              icon: AppIcons.share,
                              style: AppIconButtonStyle.glass,
                              semanticLabel: 'Partager',
                              onPressed: () => showAppToast(context, 'Lien du produit copié', icon: AppIcons.share),
                            ),
                            const SizedBox(width: 8),
                            AppIconButton(
                              icon: isFavorite ? AppIcons.heartFilled : AppIcons.heart,
                              iconColor: isFavorite ? AppColors.orange600 : AppColors.ink,
                              style: AppIconButtonStyle.glass,
                              semanticLabel: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                              onPressed: () => ref.read(favoritesControllerProvider.notifier).toggle(p),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 40,
                        child: Row(
                          children: [
                            for (var i = 0; i < 5; i++) ...[
                              if (i > 0) const SizedBox(width: 6),
                              Container(
                                width: i == 0 ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == 0 ? AppColors.ink : const Color(0x4D1F2318),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 356),
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TitleBlock(product: p, distance: distance),
                      const SizedBox(height: 22),
                      _Provenance(product: p, shopLocation: shop?.location ?? p.originRegion, distance: distance),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(child: Text('Quantité', style: AppTypography.body(size: 15, weight: FontWeight.w600))),
                          QuantityStepper(
                            value: _quantity,
                            max: p.stock > 0 ? p.stock : 1,
                            onChanged: (v) => setState(() => _quantity = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DeliveryOptions(pickup: shop?.pickup ?? true),
                      const SizedBox(height: 22),
                      if (shop != null) _ShopCard(shop: shop),
                      const SizedBox(height: 22),
                      UnderlineTabs(
                        labels: ['Description', 'Origine', 'Avis (${p.ratingCount})'],
                        selectedIndex: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: 14),
                      _TabContent(tab: _tab, product: p, shop: shop, reviews: reviews),
                      const SizedBox(height: 22),
                      _ReviewsSection(product: p, reviews: reviews),
                      if (similar.isNotEmpty) ...[
                        const SizedBox(height: 22),
                        const SectionHeader(title: 'Produits similaires'),
                        const SizedBox(height: 14),
                        ProductCarousel(products: similar, padding: EdgeInsets.zero),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        BottomActionBar(
          shadow: true,
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _added ? 'Ajouté' : 'Au panier',
                  icon: _added ? AppIcons.check : AppIcons.cart,
                  variant: AppButtonVariant.outlinePrimary,
                  fontSize: 15,
                  expand: true,
                  onPressed: p.isOutOfStock ? null : _addToCart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Acheter · ${formatAriary(p.price * _quantity)}',
                  fontSize: 15,
                  expand: true,
                  onPressed: p.isOutOfStock ? null : _buyNow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.product, required this.distance});

  final Product product;
  final int? distance;

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (distance != null)
          AppTag(label: 'Local · $distance km', icon: AppIcons.pin, height: 24, padding: const EdgeInsets.symmetric(horizontal: 8)),
        const SizedBox(height: 10),
        Text(p.name, style: AppTypography.display(size: 28, weight: FontWeight.w700, height: 1.1, letterSpacing: -0.56)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(AppIcons.star, size: 16, color: AppColors.orange500),
            const SizedBox(width: 6),
            Text(formatRating(p.ratingAvg), style: AppTypography.body(size: 14, weight: FontWeight.w700)),
            const SizedBox(width: 6),
            Text('${p.ratingCount} avis', style: AppTypography.body(size: 14, color: AppColors.body)),
            if (p.soldCount > 0) ...[
              const SizedBox(width: 6),
              Text('·', style: AppTypography.body(size: 14, color: AppColors.disabled)),
              const SizedBox(width: 6),
              Text('${p.soldCount} vendus', style: AppTypography.body(size: 14, color: AppColors.body)),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: PriceText(amount: p.price, unit: p.unitLabel, compareAt: p.compareAtPrice, size: 30, display: true)),
            if (p.isOutOfStock)
              const StatusPill(label: 'Rupture de stock', tone: StatusTone.neutral)
            else
              DotLabel(
                label: '${p.stock} en stock',
                color: p.isLowStock ? AppColors.orange700 : AppColors.pomme800,
                dotColor: p.isLowStock ? AppColors.orange500 : AppColors.pomme600,
              ),
          ],
        ),
      ],
    );
  }
}

class _Provenance extends StatelessWidget {
  const _Provenance({required this.product, required this.shopLocation, required this.distance});

  final Product product;
  final String shopLocation;
  final int? distance;

  @override
  Widget build(BuildContext context) {
    Widget dashed() => Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = (constraints.maxWidth / 7).floor();
              return Row(
                children: [
                  for (var i = 0; i < count; i++) ...[
                    Container(width: 4, height: 2, color: AppColors.lineDashed),
                    const SizedBox(width: 3),
                  ],
                ],
              );
            },
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTile(icon: AppIcons.pin, background: AppColors.surface, foreground: AppColors.orange700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROVENANCE', style: AppTypography.overline()),
                    const SizedBox(height: 2),
                    Text(shopLocation, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                    Text(
                      '${product.shopName} · récolte de saison',
                      style: AppTypography.body(size: 13, color: AppColors.body, height: 18 / 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (distance != null) ...[
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Text('Producteur', style: AppTypography.body(size: 12, weight: FontWeight.w600, color: AppColors.body)),
                  const SizedBox(width: 8),
                  dashed(),
                  const SizedBox(width: 8),
                  AppTag(
                    label: '$distance km',
                    background: AppColors.pommeSelected,
                    foreground: AppColors.pomme800,
                    fontSize: 11,
                    radius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                  const SizedBox(width: 8),
                  dashed(),
                  const SizedBox(width: 8),
                  Text('Chez vous', style: AppTypography.body(size: 12, weight: FontWeight.w600, color: AppColors.body)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryOptions extends StatelessWidget {
  const _DeliveryOptions({required this.pickup});

  final bool pickup;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String bold, String rest, String price, {bool free = false, bool divider = false}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(border: divider ? const Border(top: BorderSide(color: AppColors.divider)) : null),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.pomme700),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: bold, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    TextSpan(text: rest, style: AppTypography.body(size: 14)),
                  ],
                ),
              ),
            ),
            Text(
              price,
              style: AppTypography.body(
                size: 14,
                weight: free ? FontWeight.w700 : FontWeight.w600,
                color: free ? AppColors.pomme700 : AppColors.ink,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      radius: 14,
      child: Column(
        children: [
          row(AppIcons.truck, 'Livraison demain', ' à Analakely', formatAriary(3000)),
          if (pickup) row(AppIcons.store, 'Retrait sur place', ' · mer. et sam.', 'Gratuit', free: true, divider: true),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(initials: shop.avatar.initials, color: shop.avatar.colorValue, size: 52, fontSize: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(shop.name, style: AppTypography.body(size: 16, weight: FontWeight.w700))),
                        if (shop.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(AppIcons.shield, size: 16, color: AppColors.infoStrong, semanticLabel: 'Vendeur vérifié'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatRating(shop.ratingAvg)} ★ · ${shop.ratingCount} avis · depuis ${shop.since}'
                      '${shop.responseTime != null ? ' · répond en ${shop.responseTime}' : ''}',
                      style: AppTypography.body(size: 13, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Contacter',
                  icon: AppIcons.message,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.chat('conv-ra')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Boutique',
                  icon: AppIcons.store,
                  variant: AppButtonVariant.soft,
                  size: AppButtonSize.medium,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.seller(shop.slug)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({required this.tab, required this.product, required this.shop, required this.reviews});

  final int tab;
  final Product product;
  final Shop? shop;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final body = AppTypography.body(size: 15, color: AppColors.bodyStrong, height: 23 / 15);
    if (tab == 1) {
      return Text(
        shop?.description.isNotEmpty == true
            ? shop!.description
            : 'Produit par ${product.shopName}, ${product.originRegion}.',
        style: body,
      );
    }
    if (tab == 2) {
      return Text(
        reviews.isEmpty
            ? 'Pas encore d’avis sur ce produit.'
            : '${reviews.length} avis récents ci-dessous · note moyenne ${formatRating(product.ratingAvg)} / 5.',
        style: body,
      );
    }
    final facts = product.attributes.isNotEmpty
        ? product.attributes
        : {'Unité': product.unitLabel, 'Origine': product.originRegion};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(product.description.isEmpty ? 'Produit bio et local, préparé par ${product.shopName}.' : product.description, style: body),
        const SizedBox(height: 14),
        for (final entry in facts.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 130, child: Text(entry.key, style: AppTypography.body(size: 14, color: AppColors.muted))),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.value, style: AppTypography.body(size: 14, weight: FontWeight.w600))),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.product, required this.reviews});

  final Product product;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    final count = product.ratingCount;
    final distribution = [
      (count * 0.88).round(),
      (count * 0.09).round(),
      (count * 0.02).round(),
      (count * 0.01).round(),
      0,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: 'Avis clients', actionLabel: 'Tout voir', onAction: () {}),
        const SizedBox(height: 14),
        RatingSummary(average: product.ratingAvg, count: count, distribution: distribution),
        for (final r in reviews)
          Container(
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(initials: r.author.initials, color: r.author.colorValue, size: 32, fontSize: 12),
                    const SizedBox(width: 10),
                    Expanded(child: Text(r.authorName, style: AppTypography.body(size: 14, weight: FontWeight.w700))),
                    Text(FrenchDates.ago(r.createdAt), style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                RatingStars(rating: r.rating),
                const SizedBox(height: 6),
                Text(r.comment, style: AppTypography.body(size: 14, color: AppColors.bodyStrong, height: 21 / 14)),
                if (r.verifiedPurchase) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(AppIcons.checkCircle, size: 14, color: AppColors.pomme700),
                      const SizedBox(width: 4),
                      Text('Achat vérifié', style: AppTypography.body(size: 12, weight: FontWeight.w600, color: AppColors.pomme700)),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
