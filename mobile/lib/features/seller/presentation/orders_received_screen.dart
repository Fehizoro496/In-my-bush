import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../orders/data/order_models.dart';
import '../data/seller_repository.dart';
import '../seller_providers.dart';

enum _Tab {
  all('Tout', null),
  toConfirm('À confirmer', OrderStatus.pendingConfirmation),
  toPrepare('À préparer', OrderStatus.accepted),
  delivering('En livraison', OrderStatus.inDelivery),
  done('Terminées', OrderStatus.delivered);

  const _Tab(this.label, this.status);

  final String label;
  final OrderStatus? status;

  bool matches(Order o) {
    if (status == null) return true;
    if (this == _Tab.toPrepare) return o.status == OrderStatus.accepted || o.status == OrderStatus.prepared;
    return o.status == status;
  }
}

/// M-Orders-Received — seller's received orders.
class OrdersReceivedScreen extends ConsumerStatefulWidget {
  const OrdersReceivedScreen({super.key});

  @override
  ConsumerState<OrdersReceivedScreen> createState() => _OrdersReceivedScreenState();
}

class _OrdersReceivedScreenState extends ConsumerState<OrdersReceivedScreen> {
  _Tab _tab = _Tab.all;

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(sellerOrdersProvider);
    final all = orders.valueOrNull ?? const <Order>[];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Commandes reçues',
            fallback: AppRoutes.sell,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            actions: [AppIconButton(icon: AppIcons.filter, semanticLabel: 'Filtrer', onPressed: () {})],
            bottom: ChipScroller(
              padding: EdgeInsets.zero,
              children: [
                for (final t in _Tab.values)
                  AppChoiceChip(
                    label: t.label,
                    tone: ChipTone.ink,
                    height: 36,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    count: all.where(t.matches).length,
                    selected: _tab == t,
                    onTap: () => setState(() => _tab = t),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Order>>(
              value: orders,
              onRetry: () => ref.invalidate(sellerOrdersProvider),
              loading: () => const ListSkeleton(count: 4),
              data: (list) {
                final filtered = list.where(_tab.matches).toList();
                if (filtered.isEmpty) {
                  return const EmptyState(icon: AppIcons.receipt, title: 'Aucune commande', message: 'Les nouvelles commandes apparaîtront ici.');
                }
                return RefreshIndicator(
                  color: AppColors.pomme700,
                  onRefresh: () async {
                    ref.invalidate(sellerOrdersProvider);
                    await ref.read(sellerOrdersProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ReceivedOrderCard(
                      order: filtered[i],
                      onAction: (action) async {
                        await ref.read(sellerRepositoryProvider).transition(filtered[i].id, action);
                        ref.invalidate(sellerOrdersProvider);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedOrderCard extends StatelessWidget {
  const _ReceivedOrderCard({required this.order, required this.onAction});

  final Order order;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final o = order;
    final isNew = o.status == OrderStatus.pendingConfirmation;
    final cta = switch (o.status) {
      OrderStatus.pendingConfirmation => ('Accepter', 'accept'),
      OrderStatus.accepted => ('Marquer préparée', 'prepare'),
      _ => null,
    };
    final mode = o.deliveryMode == DeliveryMode.home ? 'Domicile' : 'Retrait';
    return AppCard(
      borderColor: isNew ? AppColors.orange300 : AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppAvatar(initials: o.buyer.avatar.initials, color: o.buyer.avatar.colorValue, size: 40, fontSize: 13),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.buyer.name, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                    Text(
                      '${o.number} · ${FrenchDates.isSameDay(o.createdAt, DateTime.now()) ? FrenchDates.hour(o.createdAt) : FrenchDates.relativeDay(o.createdAt)}',
                      style: AppTypography.body(size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StatusPill(label: o.status.sellerLabel, tone: o.status.sellerTone),
            ],
          ),
          const SizedBox(height: 10),
          Text(o.itemsSummary, style: AppTypography.body(size: 14, color: AppColors.bodyStrong)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(o.deliveryMode == DeliveryMode.home ? AppIcons.truck : AppIcons.store, size: 16, color: AppColors.body),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$mode · ${o.deliverySlot ?? ''}',
                  style: AppTypography.body(size: 13, color: AppColors.body),
                ),
              ),
              Text(formatAriary(o.subtotal), style: AppTypography.body(size: 15, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: AppButton(
                  label: 'Détail',
                  variant: AppButtonVariant.outline,
                  height: 42,
                  radius: 11,
                  fontSize: 14,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.orderReceived(o.id)),
                ),
              ),
              if (cta != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 14,
                  child: AppButton(
                    label: cta.$1,
                    height: 42,
                    radius: 11,
                    fontSize: 14,
                    expand: true,
                    onPressed: () => onAction(cta.$2),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
