import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'buttons.dart';

/// Section title (Bricolage 22) with an optional "Voir tout" link and an
/// optional inline badge (e.g. "jusqu’à −30 %").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.badge,
    this.trailing,
    this.titleSize = 22,
    this.padding = EdgeInsets.zero,
    this.leading,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? badge;
  final Widget? trailing;
  final double titleSize;
  final EdgeInsetsGeometry padding;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: AppTypography.display(
                      size: titleSize,
                      weight: FontWeight.w700,
                      letterSpacing: -0.01 * titleSize,
                    ),
                  ),
                ),
                if (badge != null) ...[const SizedBox(width: 8), badge!],
              ],
            ),
          ),
          if (trailing != null) trailing!,
          if (actionLabel != null) AppTextLink(label: actionLabel!, onTap: onAction),
        ],
      ),
    );
  }
}

/// Uppercase group label ("MON COMPTE", "AUJOURD’HUI"…).
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.text, {super.key, this.padding = const EdgeInsets.only(left: 4)});

  final String text;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text.toUpperCase(), style: AppTypography.overline()),
    );
  }
}

/// Small bold section title (15–17px Figtree) used in forms and lists.
class SubTitle extends StatelessWidget {
  const SubTitle(this.text, {super.key, this.size = 17, this.trailing, this.color = AppColors.ink});

  final String text;
  final double size;
  final Widget? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final title = Text(text, style: AppTypography.body(size: size, weight: FontWeight.w700, color: color));
    if (trailing == null) return title;
    return Row(
      children: [
        Expanded(child: title),
        trailing!,
      ],
    );
  }
}
