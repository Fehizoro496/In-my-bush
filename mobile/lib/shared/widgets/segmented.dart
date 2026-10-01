import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'badges.dart';

class SegmentItem<T> {
  const SegmentItem({required this.value, required this.label, this.icon, this.count});

  final T value;
  final String label;
  final IconData? icon;
  final int? count;
}

/// Sand pill switch with a white selected segment: J’achète / Je vends,
/// Connexion / Inscription, Mes achats / Mes ventes.
class SegmentedSwitch<T> extends StatelessWidget {
  const SegmentedSwitch({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 44,
    this.radius = 14,
    this.fontSize = 15,
  });

  final List<SegmentItem<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(radius)),
      child: Row(
        children: [
          for (final segment in segments)
            Expanded(
              child: Semantics(
                button: true,
                selected: segment.value == selected,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(segment.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: height,
                    decoration: BoxDecoration(
                      color: segment.value == selected ? AppColors.surface : Colors.transparent,
                      borderRadius: BorderRadius.circular(radius - 3),
                      boxShadow: segment.value == selected ? AppShadows.segment : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (segment.icon != null) ...[
                          Icon(
                            segment.icon,
                            size: fontSize + 3,
                            color: segment.value == selected ? AppColors.ink : AppColors.body,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          segment.label,
                          style: AppTypography.body(
                            size: fontSize,
                            weight: segment.value == selected ? FontWeight.w700 : FontWeight.w500,
                            color: segment.value == selected || segment.icon == null
                                ? AppColors.ink
                                : AppColors.body,
                          ),
                        ),
                        if (segment.count != null && segment.count! > 0) ...[
                          const SizedBox(width: 6),
                          CountBadge(count: segment.count!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Text tabs with a 3px pomme underline (Description / Origine / Avis).
class UnderlineTabs extends StatelessWidget {
  const UnderlineTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.gap = 24,
    this.fontSize = 15,
    this.showBaseline = true,
    this.scrollable = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double gap;
  final double fontSize;
  final bool showBaseline;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Semantics(
            button: true,
            selected: i == selectedIndex,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == selectedIndex ? AppColors.pomme500 : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  style: AppTypography.body(
                    size: fontSize,
                    weight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                    color: i == selectedIndex ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
    return Container(
      decoration: showBaseline
          ? const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.lineStrong)))
          : null,
      child: scrollable ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row) : row,
    );
  }
}
