import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';

/// Ariary price with optional unit (`18 000 Ar / pot 500 g`) and struck
/// compare-at price.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    this.unit,
    this.compareAt,
    this.size = 17,
    this.unitSize,
    this.color,
    this.display = false,
    this.weight,
  });

  final int amount;
  final String? unit;
  final int? compareAt;
  final double size;
  final double? unitSize;
  final Color? color;

  /// Bricolage 800 (product page) instead of Figtree 700.
  final bool display;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final priceColor = color ?? (compareAt != null ? AppColors.orange700 : AppColors.ink);
    final priceStyle = display
        ? AppTypography.display(
            size: size,
            weight: weight ?? FontWeight.w800,
            color: priceColor,
            fontFeatures: AppTypography.tabular,
          )
        : AppTypography.body(
            size: size,
            weight: weight ?? FontWeight.w700,
            color: priceColor,
            fontFeatures: AppTypography.tabular,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (compareAt != null)
          Text(
            formatAriary(compareAt!),
            style: AppTypography.body(
              size: 12,
              color: AppColors.muted,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text.rich(
          TextSpan(
            text: formatAriary(amount),
            style: priceStyle,
            children: [
              if (unit != null)
                TextSpan(
                  text: '  / $unit',
                  style: AppTypography.body(size: unitSize ?? (size >= 30 ? 15.0 : 12.0), color: AppColors.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Label ........ value" line of order / cart summaries.
class SummaryRow extends StatelessWidget {
  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.labelColor = AppColors.body,
    this.valueColor = AppColors.ink,
    this.color,
    this.size = 15,
    this.bold = false,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  /// Overrides both colors (discount lines are orange).
  final Color? color;
  final double size;
  final bool bold;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.w700 : FontWeight.w400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(label, style: AppTypography.body(size: size, weight: weight, color: color ?? labelColor)),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: valueStyle ??
              AppTypography.body(
                size: size,
                weight: weight,
                color: color ?? valueColor,
                fontFeatures: AppTypography.tabular,
              ),
        ),
      ],
    );
  }
}
