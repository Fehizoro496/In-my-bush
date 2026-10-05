import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets.dart';
import '../../data/models/models.dart';

/// "J’achète / Je vends" switch (same account, two hats).
class ModeSwitch extends StatelessWidget {
  const ModeSwitch({super.key, required this.selling, this.height = 40});

  final bool selling;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SegmentedSwitch<bool>(
      height: height,
      fontSize: 14,
      segments: const [
        SegmentItem(value: false, label: 'J’achète', icon: AppIcons.basket),
        SegmentItem(value: true, label: 'Je vends', icon: AppIcons.store),
      ],
      selected: selling,
      onChanged: (value) {
        if (value == selling) return;
        context.go(value ? AppRoutes.sell : AppRoutes.profile);
      },
    );
  }
}

/// Vertical bars chart (dashboard: 7 days, history: 6 months).
class SalesBarChart extends StatelessWidget {
  const SalesBarChart({
    super.key,
    required this.bars,
    this.height = 72,
    this.highlightIndex,
    this.barColor = const Color(0x73B2DA6A),
    this.highlightColor = AppColors.pomme500,
    this.labelColor = AppColors.pommeLight,
    this.showValues = false,
    this.gap = 6,
    this.baseline = false,
  });

  final List<SalesBar> bars;
  final double height;
  final int? highlightIndex;
  final Color barColor;
  final Color highlightColor;
  final Color labelColor;
  final bool showValues;
  final double gap;
  final bool baseline;

  @override
  Widget build(BuildContext context) {
    final max = bars.fold<int>(1, (m, b) => b.value > m ? b.value : m);
    final highlight = highlightIndex ?? bars.length - 1;
    return Semantics(
      label: 'Graphique des ventes',
      child: SizedBox(
        height: height + 24,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < bars.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showValues)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          bars[i].valueLabel ?? '',
                          style: AppTypography.body(size: 10, color: AppColors.muted),
                        ),
                      ),
                    Container(
                      height: (height - (showValues ? 16 : 0)) * bars[i].value / max,
                      decoration: BoxDecoration(
                        color: i == highlight ? highlightColor : barColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6), bottom: Radius.circular(3)),
                      ),
                    ),
                    if (baseline) Container(height: 1, color: AppColors.lineStrong),
                    const SizedBox(height: 4),
                    Text(bars[i].label, style: AppTypography.body(size: showValues ? 11 : 10, color: labelColor)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
