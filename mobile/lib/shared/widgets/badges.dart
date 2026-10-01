import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Orange count badge (#F28C28 / #3A1E05) used for every counter: tab bar,
/// cart, conversation tabs, account tiles.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.borderColor,
    this.size = 18,
    this.background = AppColors.orange500,
    this.foreground = AppColors.onSecondary,
  });

  final int count;

  /// Ring around the badge (the surface color behind it); `null` = no ring.
  final Color? borderColor;
  final double size;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: BoxConstraints(minWidth: size),
      height: size,
      padding: EdgeInsets.symmetric(horizontal: label.length > 1 ? 4 : 0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTypography.body(size: 11, weight: FontWeight.w800, color: foreground, height: 1),
      ),
    );
  }
}

enum StatusTone { info, warning, success, neutral, danger, pomme }

class StatusColors {
  const StatusColors(this.background, this.foreground, this.dot);

  final Color background;
  final Color foreground;
  final Color dot;

  static StatusColors of(StatusTone tone) {
    switch (tone) {
      case StatusTone.info:
        return const StatusColors(AppColors.infoBg, AppColors.infoFg, AppColors.infoStrong);
      case StatusTone.warning:
        return const StatusColors(AppColors.orange100, AppColors.orange800, AppColors.orange500);
      case StatusTone.success:
        return const StatusColors(AppColors.successBg, AppColors.successFg, AppColors.pomme700);
      case StatusTone.neutral:
        return const StatusColors(AppColors.sand, AppColors.body, AppColors.disabled);
      case StatusTone.danger:
        return const StatusColors(AppColors.dangerBg, AppColors.dangerFg, AppColors.dangerFg);
      case StatusTone.pomme:
        return const StatusColors(AppColors.pommeSelected, AppColors.pomme800, AppColors.pomme600);
    }
  }
}

/// Rounded status pill ("En route", "À confirmer", "Livrée"…), optionally
/// with a leading dot as in the orders list.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.tone = StatusTone.info,
    this.showDot = false,
    this.dense = false,
    this.height,
  });

  final String label;
  final StatusTone tone;
  final bool showDot;
  final bool dense;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(tone);
    return Container(
      height: height ?? (dense ? 20 : 24),
      padding: EdgeInsets.only(left: showDot ? 8 : (dense ? 8 : 10), right: dense ? 8 : 10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: colors.dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.body(
              size: dense ? 11 : 12,
              weight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small square-ish tag (radius 6): promo "−20 %", "Par défaut",
/// "Local · 22 km", "Vérifié", "Photo · …" chips.
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.pomme100,
    this.foreground = AppColors.pomme800,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w700,
    this.height,
    this.radius = 6,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  /// Orange promo tag used on product cards.
  const AppTag.promo({super.key, required this.label})
      : icon = null,
        background = AppColors.orange500,
        foreground = AppColors.onSecondary,
        fontSize = 11,
        fontWeight = FontWeight.w800,
        height = null,
        radius = 6,
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final double fontSize;
  final FontWeight fontWeight;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.body(size: fontSize, weight: fontWeight, color: foreground, height: 1.1),
          ),
        ],
      ),
    );
  }
}

/// Green dot + label ("24 en stock", "Boutique en ligne", "En ligne").
class DotLabel extends StatelessWidget {
  const DotLabel({
    super.key,
    required this.label,
    this.color = AppColors.pomme800,
    this.dotColor = AppColors.pomme600,
    this.fontSize = 13,
    this.dotSize = 8,
  });

  final String label;
  final Color color;
  final Color dotColor;
  final double fontSize;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.body(size: fontSize, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
