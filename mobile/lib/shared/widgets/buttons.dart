import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'badges.dart';

enum AppButtonVariant {
  /// Pomme green, dark green text — main action.
  primary,

  /// White with #E6E2D6 border.
  outline,

  /// White with pomme border (#8CC63F), green text ("Au panier").
  outlinePrimary,

  /// Pale green (#F0F6E6) with #365A10 text ("Suivre", "Boutique").
  soft,

  /// Transparent, text only.
  ghost,

  /// Ink background, white text ("Appliquer", filters button).
  dark,

  /// Red background (destructive confirmation).
  danger,

  /// White with red border and red text ("Un problème ?", "Refuser").
  dangerOutline,

  /// Pale green with dashed-looking pomme border ("Ajouter un moyen de paiement").
  dashed,

  /// Disabled look used by the mockups for a finished flow (#EFECE3).
  muted,
}

enum AppButtonSize { large, medium, small }

class _ButtonColors {
  const _ButtonColors(this.background, this.foreground, [this.border]);

  final Color background;
  final Color foreground;
  final Color? border;
}

/// Buttons of the design system (large 52 · medium 44 · small 36).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.loading = false,
    this.height,
    this.radius,
    this.fontSize,
    this.foregroundColor,
    this.padding,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;
  final bool loading;
  final double? height;
  final double? radius;
  final double? fontSize;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;

  _ButtonColors get _colors {
    switch (variant) {
      case AppButtonVariant.primary:
        return const _ButtonColors(AppColors.pomme500, AppColors.onPrimary);
      case AppButtonVariant.outline:
        return const _ButtonColors(AppColors.surface, AppColors.ink, AppColors.lineStrong);
      case AppButtonVariant.outlinePrimary:
        return const _ButtonColors(AppColors.surface, AppColors.pomme800, AppColors.pomme500);
      case AppButtonVariant.soft:
        return const _ButtonColors(AppColors.pomme100, AppColors.pomme800);
      case AppButtonVariant.ghost:
        return const _ButtonColors(Colors.transparent, AppColors.pomme800);
      case AppButtonVariant.dark:
        return const _ButtonColors(AppColors.ink, Colors.white);
      case AppButtonVariant.danger:
        return const _ButtonColors(AppColors.dangerFg, Colors.white);
      case AppButtonVariant.dangerOutline:
        return const _ButtonColors(AppColors.surface, AppColors.dangerFg, AppColors.dangerBorder);
      case AppButtonVariant.dashed:
        return const _ButtonColors(AppColors.pomme50, AppColors.pomme800, AppColors.pommeLight);
      case AppButtonVariant.muted:
        return const _ButtonColors(AppColors.skeleton, AppColors.disabled);
    }
  }

  double get _height {
    if (height != null) return height!;
    switch (size) {
      case AppButtonSize.large:
        return 52;
      case AppButtonSize.medium:
        return 44;
      case AppButtonSize.small:
        return 36;
    }
  }

  double get _radius {
    if (radius != null) return radius!;
    switch (size) {
      case AppButtonSize.large:
        return 14;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.small:
        return 9;
    }
  }

  double get _fontSize {
    if (fontSize != null) return fontSize!;
    switch (size) {
      case AppButtonSize.large:
        return 16;
      case AppButtonSize.medium:
        return 14;
      case AppButtonSize.small:
        return 13;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final fg = foregroundColor ?? colors.foreground;
    final enabled = onPressed != null && !loading;
    final textStyle = AppTypography.body(size: _fontSize, weight: FontWeight.w700, color: fg);
    final iconSize = _fontSize + 2;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: fg),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: iconSize, color: fg),
          ),
        Text(label, style: textStyle, maxLines: 1, softWrap: false),
        if (trailingIcon != null)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(trailingIcon, size: iconSize, color: fg),
          ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_radius),
      side: colors.border == null
          ? BorderSide.none
          : BorderSide(color: colors.border!, width: 1.5),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: SizedBox(
        height: _height,
        width: expand ? double.infinity : null,
        child: Material(
          color: colors.background,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: padding ??
                  EdgeInsets.symmetric(horizontal: size == AppButtonSize.small ? 12 : 16),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppIconButtonStyle {
  /// Transparent (header actions).
  plain,

  /// White with #E6E2D6 border.
  outline,

  /// Pomme green (add to cart, send).
  primary,

  /// Pale green (#F0F6E6) with green icon (chat with courier).
  soft,

  /// Sand (#F4F0E6) — attach photo, share.
  sand,

  /// Translucent white disc floating over photos (back / share / favorite).
  glass,

  /// Ink background (search filters).
  dark,
}

/// Square or round 44px touch target with an icon and an optional
/// orange count badge.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.style = AppIconButtonStyle.plain,
    this.size = 44,
    this.iconSize = 20,
    this.radius,
    this.iconColor,
    this.background,
    this.badgeCount,
    this.badgeBorderColor = AppColors.surface,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final AppIconButtonStyle style;
  final double size;
  final double iconSize;
  final double? radius;
  final Color? iconColor;
  final Color? background;
  final int? badgeCount;
  final Color badgeBorderColor;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;
    double r = radius ?? 12;
    List<BoxShadow>? shadow;
    switch (style) {
      case AppIconButtonStyle.plain:
        bg = Colors.transparent;
        fg = AppColors.ink;
      case AppIconButtonStyle.outline:
        bg = AppColors.surface;
        fg = AppColors.ink;
        side = const BorderSide(color: AppColors.lineStrong, width: 1.5);
      case AppIconButtonStyle.primary:
        bg = AppColors.pomme500;
        fg = AppColors.onPrimary;
      case AppIconButtonStyle.soft:
        bg = AppColors.pomme100;
        fg = AppColors.pomme800;
      case AppIconButtonStyle.sand:
        bg = AppColors.sand;
        fg = AppColors.ink;
      case AppIconButtonStyle.glass:
        bg = AppColors.glass;
        fg = AppColors.ink;
        r = radius ?? 999;
        shadow = const [BoxShadow(color: Color(0x1F1F2318), blurRadius: 8, offset: Offset(0, 2))];
      case AppIconButtonStyle.dark:
        bg = AppColors.ink;
        fg = Colors.white;
    }
    bg = background ?? bg;
    fg = iconColor ?? fg;

    Widget glyph = Icon(icon, size: iconSize, color: fg);
    if (badgeCount != null && badgeCount! > 0) {
      glyph = Stack(
        clipBehavior: Clip.none,
        children: [
          glyph,
          Positioned(
            top: -5,
            right: -9,
            child: CountBadge(count: badgeCount!, borderColor: badgeBorderColor),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r),
          boxShadow: shadow,
        ),
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r), side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Center(child: glyph),
          ),
        ),
      ),
    );
  }
}

/// Bold green text link ("Voir tout", "Modifier", "Tout lire").
class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.label,
    this.onTap,
    this.color = AppColors.pomme700,
    this.fontSize = 14,
    this.icon,
    this.minHeight = 32,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double fontSize;
  final IconData? icon;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 3, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.body(size: fontSize, weight: FontWeight.w700, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
