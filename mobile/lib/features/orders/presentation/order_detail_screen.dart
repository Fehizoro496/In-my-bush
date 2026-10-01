import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../data/order_models.dart';
import '../data/orders_repository.dart';

/// M-Order-Detail — tracking of a purchase (map, courier, timeline, parcels).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchase = ref.watch(purchaseProvider(orderId));
    return Scaffold(
      body: purchase.when(
        data: (p) => _DetailView(purchase: p),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Column(
          children: [
            const AppTopBar(title: 'Commande', fallback: AppRoutes.orders),
            Expanded(child: ErrorState(error: e, onRetry: () => ref.invalidate(purchaseProvider(orderId)))),
          ],
        ),
      ),
    );
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.purchase});

  final Purchase purchase;

  List<TimelineStep> _steps(Order order) {
    final done = switch (order.status) {
      OrderStatus.pendingConfirmation => 0,
      OrderStatus.accepted => 1,
      OrderStatus.prepared => 2,
      OrderStatus.inDelivery => 3,
      OrderStatus.delivered => 5,
      OrderStatus.refused || OrderStatus.cancelled => 0,
    };
    String? date(OrderStatus s) {
      final d = order.eventDate(s);
      return d == null ? null : FrenchDates.relativeDayTime(d);
    }

    final labels = <(String, String?)>[
      ('Commande confirmée', date(OrderStatus.accepted) ?? date(OrderStatus.pendingConfirmation)),
      ('Préparée par le vendeur', date(OrderStatus.prepared)),
      ('En route', date(OrderStatus.inDelivery)),
      ('Livrée', date(OrderStatus.delivered) ?? (order.deliverySlot != null ? 'Prévue ${order.deliverySlot}' : null)),
      ('Paiement versé au vendeur', 'Après votre réception'),
    ];
    return [
      for (var i = 0; i < labels.length; i++)
        TimelineStep(
          title: labels[i].$1,
          subtitle: labels[i].$2,
          state: i < done ? TimelineState.done : (i == done ? TimelineState.current : TimelineState.upcoming),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = purchase;
    final tracked = p.orders.firstWhere((o) => o.status == OrderStatus.inDelivery, orElse: () => p.orders.first);
    final trackedIndex = p.orders.indexOf(tracked);
    final cancelled = p.status == OrderStatus.cancelled || p.status == OrderStatus.refused;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTopBar(
          title: 'Commande ${p.number}',
          titleSize: 20,
          subtitle: 'Passée le ${FrenchDates.dayMonth(p.createdAt)} · ${formatAriary(p.total)}',
          fallback: AppRoutes.orders,
          actions: [
            AppIconButton(
              icon: AppIcons.download,
              semanticLabel: 'Télécharger la facture',
              onPressed: () => showAppToast(context, 'Facture téléchargée', icon: AppIcons.download),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              if (!cancelled)
                AppCard(
                  radius: 20,
                  padding: EdgeInsets.zero,
                  clip: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _MiniMap(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Livraison ${trackedIndex + 1} / ${p.orders.length} · ${tracked.shop.name}',
                                        style: AppTypography.body(size: 12, color: AppColors.muted),
                                      ),
                                      Text(
                                        tracked.eta ?? (tracked.deliverySlot ?? tracked.status.buyerLabel),
                                        style: AppTypography.display(size: 22, weight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusPill(label: tracked.status.buyerLabel, tone: tracked.status.buyerTone, height: 26),
                              ],
                            ),
                            if (tracked.courier != null) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  AppAvatar(
                                    initials: tracked.courier!.avatar.initials,
                                    color: tracked.courier!.avatar.colorValue,
                                    size: 40,
                                    fontSize: 13,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${tracked.courier!.name}, votre livreur', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                                        Text(
                                          '${tracked.courier!.vehicle}${tracked.courier!.distance != null ? ' · ${tracked.courier!.distance}' : ''}',
                                          style: AppTypography.body(size: 12, color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppIconButton(
                                    icon: AppIcons.message,
                                    iconSize: 19,
                                    style: AppIconButtonStyle.soft,
                                    semanticLabel: 'Écrire au livreur',
                                    onPressed: () => context.push(AppRoutes.chat('conv-naina')),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (!cancelled) ...[
                const SizedBox(height: 14),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Suivi', style: AppTypography.body(size: 16, weight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      OrderTimeline(steps: _steps(tracked)),
                    ],
                  ),
                ),
              ],
              for (final order in p.orders) ...[
                const SizedBox(height: 14),
                _ParcelCard(order: order),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SummaryRow(size: 14, label: 'Sous-total', value: formatAriary(p.subtotal)),
                    const SizedBox(height: 8),
                    SummaryRow(size: 14, label: 'Livraison', value: formatAriary(p.deliveryFee)),
                    if (p.discount > 0) ...[
                      const SizedBox(height: 8),
                      SummaryRow(
                        size: 14,
                        label: 'Réduction ${p.promoCode ?? ''}'.trim(),
                        value: formatAriary(-p.discount),
                        color: AppColors.orange700,
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.lineStrong),
                    const SizedBox(height: 6),
                    SummaryRow(
                      size: 16,
                      bold: true,
                      label: cancelled ? 'Remboursé · ${p.paymentMethod.family}' : 'Payé · ${p.paymentMethod.family}',
                      value: formatAriary(p.total),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Contacter',
                      icon: AppIcons.message,
                      variant: AppButtonVariant.outline,
                      height: 48,
                      radius: 12,
                      fontSize: 14,
                      expand: true,
                      onPressed: () => context.push(AppRoutes.chat('conv-ra')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Un problème ?',
                      icon: AppIcons.flag,
                      variant: AppButtonVariant.dangerOutline,
                      height: 48,
                      radius: 12,
                      fontSize: 14,
                      expand: true,
                      onPressed: () => showAppToast(context, 'Signalement envoyé à l’équipe In my bush', icon: AppIcons.flag),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (p.canReview)
                AppButton(
                  label: 'Laisser un avis',
                  icon: AppIcons.starOutline,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.orderReview(p.id)),
                )
              else
                Text(
                  _cancelHint(p),
                  textAlign: TextAlign.center,
                  style: AppTypography.body(size: 12, color: AppColors.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _cancelHint(Purchase p) {
    if (p.status == OrderStatus.cancelled) return 'Commande annulée et remboursée.';
    if (p.orders.any((o) => o.status.step >= OrderStatus.prepared.step)) {
      return 'Annulation impossible : la commande est ${p.status == OrderStatus.inDelivery ? 'en route' : 'préparée'}.';
    }
    return 'Vous pouvez annuler tant que la commande n’est pas préparée.';
  }
}

class _ParcelCard extends StatelessWidget {
  const _ParcelCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusText = order.status == OrderStatus.inDelivery || order.status.isClosed
        ? order.status.buyerLabel
        : (order.deliverySlot ?? order.status.buyerLabel);
    final statusColor = order.status == OrderStatus.inDelivery ? AppColors.infoFg : AppColors.orange800;
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.bg,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                AppAvatar(initials: order.shop.avatar.initials, color: order.shop.avatar.colorValue, size: 30, fontSize: 11),
                const SizedBox(width: 10),
                Expanded(child: Text(order.shop.name, style: AppTypography.body(size: 14, weight: FontWeight.w700))),
                Text(statusText, style: AppTypography.body(size: 12, weight: FontWeight.w700, color: statusColor)),
              ],
            ),
          ),
          const Divider(),
          for (var i = 0; i < order.items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  ProductThumb(visual: order.items[i].visual, size: 48, radius: 10, iconSize: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.items[i].productName, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                        Text(order.items[i].quantityText, style: AppTypography.body(size: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Text(formatAriary(order.items[i].lineTotal), style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Illustrated delivery map (road, dashed route, courier, destination pin).
class _MiniMap extends StatelessWidget {
  const _MiniMap();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ColoredBox(
        color: AppColors.mapBg,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -20,
              top: 70,
              child: Transform.rotate(angle: -10 * math.pi / 180, child: Container(width: 460, height: 12, color: Colors.white)),
            ),
            Positioned(
              left: 40,
              top: 96,
              child: Transform.rotate(
                angle: -10 * math.pi / 180,
                child: Row(
                  children: [
                    for (var i = 0; i < 26; i++) ...[
                      Container(width: 5, height: 3, color: AppColors.pomme600),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: 150,
              top: 58,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x1F1F2318), spreadRadius: 6)],
                ),
                child: const Icon(AppIcons.truck, size: 18, color: Colors.white),
              ),
            ),
            Positioned(
              right: 60,
              top: 38,
              child: Transform.rotate(
                angle: -math.pi / 4,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.pomme700,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(999),
                      topRight: Radius.circular(999),
                      bottomRight: Radius.circular(999),
                      bottomLeft: Radius.circular(4),
                    ),
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
