import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import 'app_icons.dart';

/// Row of 5 filled stars (orange), unfilled ones in #E6E2D6.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 14,
    this.spacing = 2,
    this.color = AppColors.orange500,
    this.emptyColor = AppColors.lineStrong,
  });

  final num rating;
  final double size;
  final double spacing;
  final Color color;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round();
    return Semantics(
      label: '${formatRating(rating)} sur 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Icon(AppIcons.star, size: size, color: i < filled ? color : emptyColor),
          ],
        ],
      ),
    );
  }
}

/// ★ 4,8 (126) — compact rating used on cards.
class RatingInline extends StatelessWidget {
  const RatingInline({
    super.key,
    required this.rating,
    this.count,
    this.fontSize = 13,
    this.iconSize = 14,
    this.suffix,
  });

  final num rating;
  final int? count;
  final double fontSize;
  final double iconSize;

  /// Text after the rating instead of `(count)`, e.g. `"· 28 produits"`.
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(AppIcons.star, size: iconSize, color: AppColors.orange500),
        const SizedBox(width: 4),
        Text(formatRating(rating), style: AppTypography.body(size: fontSize, weight: FontWeight.w600)),
        if (count != null || suffix != null) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              suffix ?? '($count)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(size: fontSize, color: AppColors.muted),
            ),
          ),
        ],
      ],
    );
  }
}

/// Big average + 5→1 distribution bars (product reviews, reviews received).
class RatingSummary extends StatelessWidget {
  const RatingSummary({
    super.key,
    required this.average,
    required this.count,
    required this.distribution,
    this.showCounts = false,
    this.footer,
    this.averageSize = 44,
  });

  final num average;
  final int count;

  /// Counts per star, index 0 = 5 stars … index 4 = 1 star.
  final List<int> distribution;
  final bool showCounts;
  final Widget? footer;
  final double averageSize;

  @override
  Widget build(BuildContext context) {
    final total = distribution.fold<int>(0, (sum, v) => sum + v);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatRating(average),
              style: AppTypography.display(size: averageSize, weight: FontWeight.w800, height: 1),
            ),
            Text('${formatThousands(count)} avis', style: AppTypography.body(size: 12, color: AppColors.muted)),
            if (footer != null) ...[const SizedBox(height: 4), footer!],
          ],
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                        child: Text('${5 - i}', style: AppTypography.body(size: 12, color: AppColors.muted)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            height: 6,
                            child: Stack(
                              children: [
                                const Positioned.fill(child: ColoredBox(color: AppColors.divider)),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: total == 0 || i >= distribution.length
                                      ? 0
                                      : distribution[i] / total,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.orange500,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (showCounts) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 20,
                          child: Text(
                            i < distribution.length ? '${distribution[i]}' : '0',
                            textAlign: TextAlign.right,
                            style: AppTypography.body(size: 12, color: AppColors.muted),
                          ),
                        ),
                      ],
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

/// Tappable 5-star input (review form).
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.starSize = 42,
    this.hitSize = 52,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double starSize;
  final double hitSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var n = 1; n <= 5; n++)
          Semantics(
            button: true,
            selected: n <= value,
            label: '$n étoile${n > 1 ? 's' : ''}',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(n),
              child: SizedBox(
                width: hitSize,
                height: hitSize,
                child: Icon(
                  AppIcons.star,
                  size: starSize,
                  color: n <= value ? AppColors.orange500 : AppColors.lineStrong,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
