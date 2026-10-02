import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../data/seller_models.dart';
import '../seller_providers.dart';
import 'widgets/seller_widgets.dart';

/// M-Sell-History — sales history with revenue chart and record list.
class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  SalesPeriod _period = SalesPeriod.halfYear;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(salesHistoryProvider(_period));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Historique des ventes'),
            Expanded(
              child: AsyncValueView<SalesHistory>(
                value: history,
                onRetry: () => ref.invalidate(salesHistoryProvider(_period)),
                loading: () => const Center(child: Skeleton(height: 400, radius: 20)),
                data: (h) => RefreshIndicator(
                  color: AppColors.pomme700,
                  onRefresh: () async {
                    ref.invalidate(salesHistoryProvider(_period));
                    await ref.read(salesHistoryProvider(_period).future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      // Period chips
                      Row(
                        children: [
                          for (final p in const [SalesPeriod.month, SalesPeriod.halfYear, SalesPeriod.year]) ...[
                            AppChoiceChip(
                              label: p.label,
                              tone: ChipTone.sand,
                              height: 36,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              selected: _period == p,
                              onTap: () => setState(() => _period = p),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Revenue chart
                      AppCard(
                        radius: 18,
                        borderColor: AppColors.line,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Revenus · ${_period.label}',
                                style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formatCompactAriary(h.gross),
                                style: AppTypography.display(size: 28, weight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SalesBarChart(
                              bars: h.bars,
                              height: 80,
                              barColor: AppColors.pomme200,
                              highlightColor: AppColors.pomme500,
                              labelColor: AppColors.muted,
                              showValues: true,
                              baseline: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Summary row
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryTile(
                              label: 'Commission',
                              value: formatCompactAriary(h.commission),
                              color: AppColors.orange700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryTile(
                              label: 'Net perçu',
                              value: formatCompactAriary(h.net),
                              color: AppColors.pomme700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Records
                      const SectionHeader(title: 'Dernières ventes', titleSize: 18),
                      const SizedBox(height: 10),
                      if (h.records.isEmpty)
                        const EmptyState(
                          icon: AppIcons.receipt,
                          title: 'Aucune vente',
                          message: 'Vos ventes apparaîtront ici.',
                        )
                      else
                        for (final record in h.records)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RecordRow(record: record),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      borderColor: AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.body(size: 12, color: AppColors.muted)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.body(size: 16, weight: FontWeight.w800, color: color, fontFeatures: AppTypography.tabular)),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});

  final SaleRecord record;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: record.visual.tintColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.byKey(record.visual.icon), size: 20, color: record.visual.inkColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record.client} · ${record.number}',
                    style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(record.itemsSummary,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatAriary(record.amount),
                  style: AppTypography.body(size: 14, weight: FontWeight.w700, fontFeatures: AppTypography.tabular)),
              const SizedBox(height: 4),
              StatusPill(
                label: record.payout.label,
                tone: record.payout == PayoutState.paid
                    ? StatusTone.success
                    : record.payout == PayoutState.refunded
                        ? StatusTone.neutral
                        : StatusTone.warning,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
