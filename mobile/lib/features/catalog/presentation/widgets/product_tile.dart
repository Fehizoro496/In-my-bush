import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets.dart';
import '../../../cart/cart_providers.dart';
import '../../../favorites/favorites_providers.dart';
import '../../data/models/models.dart';

/// [ProductCard] wired to favorites, cart and navigation.
class ProductTile extends ConsumerWidget {
  const ProductTile({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.id));
    final inCart = ref.watch(isInCartProvider(product.id));
    return ProductCard(
      name: product.name,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      unitLabel: product.unitLabel,
      visual: product.visual,
      imageUrl: product.imageUrl,
      photoLabel: product.photoLabel,
      sellerName: product.shopName,
      location: product.shopCity,
      rating: product.ratingAvg,
      reviewCount: product.ratingCount,
      stockState: product.stockState,
      stockLabel: product.stockLabel,
      isFavorite: isFavorite,
      inCart: inCart,
      onTap: () => context.push(AppRoutes.product(product.slug)),
      onToggleFavorite: () => ref.read(favoritesControllerProvider.notifier).toggle(product),
      onAddToCart: () {
        if (inCart) {
          context.push(AppRoutes.cart);
          return;
        }
        ref.read(cartControllerProvider.notifier).add(product);
        showAppToast(context, '${product.name} ajouté au panier', actionLabel: 'Voir', onAction: () {
          context.push(AppRoutes.cart);
        });
      },
      onNotifyMe: () => showAppToast(
        context,
        'Nous vous préviendrons du retour en stock',
        icon: AppIcons.bell,
      ),
    );
  }
}

/// Grid of [ProductTile]s (two columns, equal row heights).
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products, this.trailing = const []});

  final List<Product> products;

  /// Extra cells (loading skeletons).
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return TwoColumnGrid(
      children: [
        for (final p in products) ProductTile(product: p),
        ...trailing,
      ],
    );
  }
}

/// Horizontal row of 172px product cards.
class ProductCarousel extends StatelessWidget {
  const ProductCarousel({super.key, required this.products, this.padding = const EdgeInsets.symmetric(horizontal: 16)});

  final List<Product> products;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return HorizontalCards(
      padding: padding,
      children: [for (final p in products) ProductTile(product: p)],
    );
  }
}
