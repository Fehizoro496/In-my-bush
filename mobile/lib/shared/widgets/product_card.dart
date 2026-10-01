import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../models/visual.dart';
import 'app_icons.dart';
import 'badges.dart';
import 'rating.dart';

enum StockState { inStock, low, out }

/// Product photo or, without URL, the mockups' tinted placeholder
/// (colored square + icon).
class ProductThumb extends StatelessWidget {
  const ProductThumb({
    super.key,
    required this.visual,
    this.imageUrl,
    this.size = 52,
    this.radius = 12,
    this.iconSize,
    this.opacity = 1,
  });

  final Visual visual;
  final String? imageUrl;
  final double size;
  final double radius;
  final double? iconSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: visual.tintColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    Icon(AppIcons.byKey(visual.icon), size: iconSize ?? size * 0.42, color: visual.inkColor),
              )
            : Icon(AppIcons.byKey(visual.icon), size: iconSize ?? size * 0.42, color: visual.inkColor),
      ),
    );
  }
}

/// Large photo area used by cards and the product page.
class ProductPhoto extends StatelessWidget {
  const ProductPhoto({
    super.key,
    required this.visual,
    this.imageUrl,
    this.photoLabel,
    this.iconSize = 56,
    this.labelPadding = const EdgeInsets.only(left: 10, bottom: 8),
    this.labelSize = 10,
  });

  final Visual visual;
  final String? imageUrl;
  final String? photoLabel;
  final double iconSize;
  final EdgeInsets labelPadding;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return ColoredBox(
      color: visual.tintColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Opacity(
              opacity: 0.55,
              child: Icon(AppIcons.byKey(visual.icon), size: iconSize, color: visual.inkColor),
            ),
          ),
          if (photoLabel != null)
            Positioned(
              left: labelPadding.left,
              bottom: labelPadding.bottom,
              child: Opacity(
                opacity: 0.7,
                child: Text(
                  photoLabel!.toUpperCase(),
                  style: AppTypography.body(
                    size: labelSize,
                    weight: FontWeight.w700,
                    color: visual.inkColor,
                    letterSpacing: labelSize * 0.08,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Product card of the design system (ProductCard mockup): photo with promo
/// tag, favorite button, stock states; seller line, name, rating, price and
/// add-to-cart button.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.unitLabel,
    required this.visual,
    this.imageUrl,
    this.photoLabel,
    this.sellerName = '',
    this.location = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.compareAtPrice,
    this.stockState = StockState.inStock,
    this.stockLabel,
    this.isFavorite = false,
    this.inCart = false,
    this.highlighted = false,
    this.onTap,
    this.onToggleFavorite,
    this.onAddToCart,
    this.onNotifyMe,
  });

  final String name;
  final int price;
  final String unitLabel;
  final Visual visual;
  final String? imageUrl;
  final String? photoLabel;
  final String sellerName;
  final String location;
  final double rating;
  final int reviewCount;
  final int? compareAtPrice;
  final StockState stockState;
  final String? stockLabel;
  final bool isFavorite;
  final bool inCart;
  final bool highlighted;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onAddToCart;
  final VoidCallback? onNotifyMe;

  @override
  Widget build(BuildContext context) {
    final out = stockState == StockState.out;
    final promo = promoLabel(price, compareAtPrice);
    final priceColor = out
        ? AppColors.muted
        : (compareAtPrice != null ? AppColors.orange700 : AppColors.ink);

    return Semantics(
      container: true,
      label: name,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: highlighted ? AppColors.pomme300 : AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1 / 0.86,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductPhoto(
                      visual: visual,
                      imageUrl: imageUrl,
                      photoLabel: photoLabel == null ? null : 'Photo · $photoLabel',
                    ),
                    if (promo != null)
                      Positioned(top: 10, left: 10, child: AppTag.promo(label: promo)),
                    if (out)
                      Positioned.fill(
                        child: ColoredBox(
                          color: const Color(0x9EFBFAF6),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.ink,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Rupture de stock',
                                style: AppTypography.body(size: 12, weight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (stockState == StockState.low && stockLabel != null)
                      Positioned(
                        right: 10,
                        bottom: 8,
                        child: AppTag(
                          label: stockLabel!,
                          background: AppColors.orange100,
                          foreground: AppColors.orange700,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _FavoriteButton(isFavorite: isFavorite, onTap: onToggleFavorite),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(AppIcons.pin, size: 13, color: AppColors.muted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location.isEmpty ? sellerName : '$sellerName · $location',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(size: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 40,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(size: 15, weight: FontWeight.w600, height: 20 / 15),
                      ),
                    ),
                    const SizedBox(height: 6),
                    RatingInline(rating: rating, count: reviewCount),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (compareAtPrice != null)
                                Text(
                                  formatAriary(compareAtPrice!),
                                  style: AppTypography.body(
                                    size: 12,
                                    color: AppColors.muted,
                                    decoration: TextDecoration.lineThrough,
                                    fontFeatures: AppTypography.tabular,
                                  ),
                                ),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 3,
                                children: [
                                  Text(
                                    formatAriary(price),
                                    style: AppTypography.body(
                                      size: 17,
                                      weight: FontWeight.w700,
                                      color: priceColor,
                                      fontFeatures: AppTypography.tabular,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '/ $unitLabel',
                                      style: AppTypography.body(size: 12, color: AppColors.muted),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (out)
                          _CardActionButton(
                            icon: AppIcons.bell,
                            semanticLabel: 'M’alerter du retour en stock',
                            background: AppColors.surface,
                            foreground: AppColors.body,
                            border: AppColors.lineStrong,
                            onTap: onNotifyMe,
                          )
                        else
                          _CardActionButton(
                            icon: inCart ? AppIcons.check : AppIcons.plus,
                            semanticLabel: inCart ? 'Ajouté au panier' : 'Ajouter au panier',
                            background: inCart ? AppColors.pomme700 : AppColors.pomme500,
                            foreground: inCart ? Colors.white : AppColors.onPrimary,
                            onTap: onAddToCart,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, this.onTap});

  final bool isFavorite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isFavorite,
      label: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xF0FFFFFF),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x1F1F2318), blurRadius: 3, offset: Offset(0, 1))],
              ),
              alignment: Alignment.center,
              child: Icon(
                isFavorite ? AppIcons.heartFilled : AppIcons.heart,
                size: 18,
                color: isFavorite ? AppColors.orange600 : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.background,
    required this.foreground,
    this.border,
    this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final Color background;
  final Color foreground;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: border == null ? BorderSide.none : BorderSide(color: border!, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Icon(icon, size: 20, color: foreground),
          ),
        ),
      ),
    );
  }
}

/// Compact product row ("Populaires · produits locaux": rank, thumb, name,
/// seller, price).
class ProductRankRow extends StatelessWidget {
  const ProductRankRow({
    super.key,
    required this.rank,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.unitLabel,
    required this.visual,
    this.imageUrl,
    this.onTap,
    this.showDivider = false,
  });

  final int rank;
  final String name;
  final String subtitle;
  final int price;
  final String unitLabel;
  final Visual visual;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider ? const Border(top: BorderSide(color: AppColors.divider)) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              child: Text(
                '$rank',
                style: AppTypography.display(size: 18, weight: FontWeight.w800, color: AppColors.disabled),
              ),
            ),
            const SizedBox(width: 12),
            ProductThumb(visual: visual.copyWith(icon: 'leaf'), imageUrl: imageUrl, size: 52, iconSize: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 12, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatAriary(price), style: AppTypography.body(size: 14, weight: FontWeight.w700, fontFeatures: AppTypography.tabular)),
                Text('/ $unitLabel', style: AppTypography.body(size: 12, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
