import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';

enum ChipTone {
  /// Selected = pale green + pomme border (filters, tags, delivery slots).
  green,

  /// Selected = dark green #1F3608 (home sub-category chips).
  forest,

  /// Selected = ink #1F2318 (notification / order filters).
  ink,

  /// Borderless sand pills, selected = ink (period selector).
  sand,
}

/// Choice / filter chip.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    this.tone = ChipTone.green,
    this.height = 40,
    this.radius = 999,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.count,
    this.padding = const EdgeInsets.symmetric(horizontal: 14),
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final ChipTone tone;
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;

  /// Small counter pill after the label (orders received filters).
  final int? count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color? border;
    switch (tone) {
      case ChipTone.green:
        bg = selected ? AppColors.pommeSelected : AppColors.surface;
        fg = selected ? AppColors.pomme800 : AppColors.ink;
        border = selected ? AppColors.pomme500 : AppColors.lineStrong;
      case ChipTone.forest:
        bg = selected ? AppColors.pomme900 : AppColors.surface;
        fg = selected ? AppColors.pomme50 : AppColors.ink;
        border = selected ? AppColors.pomme900 : AppColors.lineStrong;
      case ChipTone.ink:
        bg = selected ? AppColors.ink : AppColors.surface;
        fg = selected ? Colors.white : AppColors.ink;
        border = selected ? AppColors.ink : AppColors.lineStrong;
      case ChipTone.sand:
        bg = selected ? AppColors.ink : AppColors.sand;
        fg = selected ? Colors.white : AppColors.ink;
        border = null;
    }

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: border == null ? BorderSide.none : BorderSide(color: border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: fontSize + 1, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTypography.body(size: fontSize, weight: fontWeight, color: fg),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.pomme500 : AppColors.sand,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: AppTypography.body(
                        size: 11,
                        weight: FontWeight.w700,
                        color: selected ? AppColors.onPrimary : AppColors.body,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of chips with the page gutter.
class ChipScroller extends StatelessWidget {
  const ChipScroller({
    super.key,
    required this.children,
    this.spacing = 8,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Removable pale-green chip ("Moins de 15 km ✕", delivery zones).
class RemovableChip extends StatelessWidget {
  const RemovableChip({
    super.key,
    required this.label,
    this.onRemove,
    this.height = 32,
    this.fontSize = 13,
    this.leadingIcon,
    this.background = AppColors.pommeSelected,
    this.foreground = AppColors.pomme800,
    this.border,
    this.fontWeight = FontWeight.w700,
  });

  final String label;
  final VoidCallback? onRemove;
  final double height;
  final double fontSize;
  final IconData? leadingIcon;
  final Color background;
  final Color foreground;
  final Color? border;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: 12, right: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: border == null ? null : Border.all(color: border!, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 14, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.body(size: fontSize, weight: fontWeight, color: foreground)),
          const SizedBox(width: 2),
          Semantics(
            button: true,
            label: 'Retirer $label',
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 26,
                height: 26,
                child: Icon(AppIcons.close, size: 13, color: foreground == AppColors.ink ? AppColors.muted : foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Home category shortcut: 64px rounded tile with an icon and a label.
class CategoryShortcut extends StatelessWidget {
  const CategoryShortcut({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(20),
                  border: background == AppColors.surface
                      ? Border.all(color: AppColors.line)
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 26, color: foreground),
              ),
              const SizedBox(height: 8),
              ExcludeSemantics(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.body(size: 12, weight: FontWeight.w600, height: 15 / 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
