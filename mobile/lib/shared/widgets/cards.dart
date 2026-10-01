import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'inputs.dart';

/// White rounded card with a 1px #EAE6DB border.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.color = AppColors.surface,
    this.borderColor = AppColors.line,
    this.borderWidth = 1,
    this.onTap,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!, width: borderWidth),
    );
    return Material(
      color: color,
      shape: shape,
      clipBehavior: clip || onTap != null ? Clip.antiAlias : Clip.none,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

/// Tinted callout: icon + rich text (+ trailing).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.child,
    this.background = AppColors.orange50,
    this.iconColor = AppColors.orange600,
    this.textColor = AppColors.orangeInk,
    this.borderColor,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.radius = 14,
  });

  /// Plain text convenience constructor.
  InfoBanner.text({
    super.key,
    required this.icon,
    required String text,
    this.background = AppColors.orange50,
    this.iconColor = AppColors.orange600,
    this.textColor = AppColors.orangeInk,
    this.borderColor,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.radius = 14,
  }) : child = Text(text);

  final IconData icon;
  final Widget child;
  final Color background;
  final Color iconColor;
  final Color textColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: DefaultTextStyle.merge(
              style: AppTypography.body(size: fontSize, color: textColor, height: 20 / 14),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Container with a dashed rounded border (add photo, promo code, new
/// address…).
class DashedBorderBox extends StatelessWidget {
  const DashedBorderBox({
    super.key,
    required this.child,
    this.color = AppColors.pommeLight,
    this.background,
    this.radius = 14,
    this.strokeWidth = 1.5,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color? background;
  final double radius;
  final double strokeWidth;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content);
    }
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(color: color, radius: radius, strokeWidth: strokeWidth),
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color, required this.radius, required this.strokeWidth});

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(strokeWidth / 2), Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    const dash = 5.0;
    const gap = 4.0;
    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = distance + dash < metric.length ? distance + dash : metric.length;
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius || oldDelegate.strokeWidth != strokeWidth;
}

/// Selectable option card with a radio dot (checkout delivery / payment,
/// payment methods, addresses).
class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key,
    required this.selected,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.expanded,
    this.onTap,
    this.showRadio = true,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final bool selected;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  /// Extra content shown under the header when selected.
  final Widget? expanded;
  final VoidCallback? onTap;
  final bool showRadio;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.pomme500 : AppColors.line,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                children: [
                  if (showRadio) ...[
                    Padding(
                      padding: EdgeInsets.only(top: crossAxisAlignment == CrossAxisAlignment.start ? 2 : 0),
                      child: AppRadioDot(selected: selected),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTypography.body(size: 13, color: AppColors.muted, height: 18 / 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing!],
                ],
              ),
            ),
          ),
          if (selected && expanded != null)
            Padding(padding: const EdgeInsets.fromLTRB(48, 0, 14, 14), child: expanded),
        ],
      ),
    );
  }
}

/// Icon in a tinted rounded square (address, KPI, notification icons).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.background = AppColors.pomme100,
    this.foreground = AppColors.pomme700,
    this.size = 40,
    this.radius = 12,
    this.iconSize,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize ?? size / 2, color: foreground),
    );
  }
}

/// Horizontally scrolling row of equal-height cards with the page gutter.
class HorizontalCards extends StatelessWidget {
  const HorizontalCards({
    super.key,
    required this.children,
    this.itemWidth = 172,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final double itemWidth;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              SizedBox(width: itemWidth, child: children[i]),
            ],
          ],
        ),
      ),
    );
  }
}

/// Two-column grid whose rows take the height of their tallest card
/// (CSS grid behaviour of the mockups).
class TwoColumnGrid extends StatelessWidget {
  const TwoColumnGrid({super.key, required this.children, this.spacing = 12});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: children[i]),
              SizedBox(width: spacing),
              Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
            ],
          ),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}
