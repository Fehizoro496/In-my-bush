import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';
import 'inputs.dart';
import 'section_header.dart';

/// Group of settings rows: uppercase label + white rounded card with
/// dividers between rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[GroupLabel(title!), const SizedBox(height: 8)],
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(height: 1, thickness: 1, color: AppColors.divider),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Navigation row: icon, title (+ description), value and chevron.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.valueColor = AppColors.muted,
    this.valueWeight = FontWeight.w400,
    this.onTap,
    this.iconColor = AppColors.body,
    this.minHeight = 56,
    this.trailing,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Color valueColor;
  final FontWeight valueWeight;
  final VoidCallback? onTap;
  final Color iconColor;
  final double minHeight;
  final Widget? trailing;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTypography.body(size: 15)),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(value!, style: AppTypography.body(size: 14, color: valueColor, weight: valueWeight)),
              ],
              if (showChevron) ...[
                const SizedBox(width: 4),
                const Icon(AppIcons.chevronRight, size: 16, color: AppColors.disabled),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Row with a switch.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.iconColor = AppColors.body,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: AppTypography.body(size: 15)),
                    if (subtitle != null)
                      Text(subtitle!, style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppSwitch(value: value, onChanged: onChanged, semanticLabel: title),
            ],
          ),
        ),
      ),
    );
  }
}
