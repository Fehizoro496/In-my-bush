import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Initials avatar (people, shops). Circle by default, rounded square with
/// [radius]. [ringColor] draws the double ring of the "popular producers"
/// cards; [online] adds the green presence dot.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 40,
    this.radius,
    this.fontSize,
    this.display,
    this.borderColor,
    this.borderWidth = 0,
    this.ringColor,
    this.online = false,
    this.imageUrl,
  });

  final String initials;
  final Color color;
  final double size;

  /// Corner radius; `null` = circle.
  final double? radius;
  final double? fontSize;

  /// Use the display font (Bricolage) — defaults to true from 52px.
  final bool? display;
  final Color? borderColor;
  final double borderWidth;
  final Color? ringColor;
  final bool online;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final useDisplay = display ?? size >= 52;
    final textSize = fontSize ?? (size * (useDisplay ? 0.34 : 0.32)).roundToDouble();
    final style = useDisplay
        ? AppTypography.display(size: textSize, weight: FontWeight.w800, color: Colors.white)
        : AppTypography.body(size: textSize, weight: FontWeight.w800, color: Colors.white);
    final shapeRadius = BorderRadius.circular(radius ?? size / 2);

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: shapeRadius,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: borderWidth),
        image: imageUrl == null
            ? null
            : DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover),
      ),
      alignment: Alignment.center,
      child: imageUrl == null ? Text(initials, style: style) : null,
    );

    if (ringColor != null) {
      // Draw the white ring above the colored one.
      avatar = Container(
        decoration: BoxDecoration(
          borderRadius: shapeRadius,
          boxShadow: [BoxShadow(color: ringColor!, spreadRadius: 5)],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: shapeRadius,
            boxShadow: const [BoxShadow(color: Colors.white, spreadRadius: 3)],
          ),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, borderRadius: shapeRadius),
            alignment: Alignment.center,
            child: Text(initials, style: style),
          ),
        ),
      );
    }

    if (!online) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.pomme600,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
