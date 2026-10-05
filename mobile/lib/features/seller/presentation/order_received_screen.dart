import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../orders/data/models/models.dart';
import '../seller_providers.dart';

/// M-Order-Received — one received order with its status stepper
/// (Reçue → Acceptée → Préparée → Remise au livreur → Livrée).
class OrderReceivedScreen extends ConsumerWidget {
  const OrderReceivedScreen({super.key, required this.orderId});

  final String orderId;

  static const _ctas = ['Accepter la commande', 'Marquer comme préparée', 'Remettre au livreur', 'Confirmer la livraison', 'Commande terminée'];

  List<TimelineStep> _steps(Order o) {
    final st = o.status.step;
    final created = o.createdAt;
    final labels = <(String, String)>[
      ('Reçue', FrenchDates.relativeDayTime(created)),
      ('Acceptée', 'Confirmez avant ${o.acceptBefore == null ? '14h' : FrenchDates.hour(o.acceptBefore!, compact: true)}'),
      ('Préparée', 'Emballez et étiquetez'),
      (o.deliveryMode == DeliveryMode.home ? 'Remise au livreur' : 'Retrait par le client', o.deliverySlot ?? 'Demain matin'),
      ('Livrée', 'Paiement libéré'),
    ];
    return [
      for (var i = 0; i < labels.length; i++)
        TimelineStep(
          title: labels[i].$1,
          subtitle: labels[i].$2,
          state: i <= st ? TimelineState.done : (i == st + 1 ? TimelineState.current : TimelineState.upcoming),
        ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(sellerOrderProvider(orderId));
    final controller = ref.read(sellerOrderProvider(orderId).notifier);

    return Scaffold(
      body: order.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Column(
          children: [
            const AppTopBar(title: 'Commande', fallback: AppRoutes.ordersReceived),
            Expanded(child: ErrorState(error: e, onRetry: () => ref.invalidate(sellerOrderProvider(orderId)))),
          ],
        ),
        data: (o) {
          final step = o.status.step;
          final closed = step < 0;
          final finished = step >= 4 || closed;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBar(
                title: o.number,
                fallback: AppRoutes.ordersReceived,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                bottomGap: 6,
                actions: [StatusPill(label: o.status.sellerDetailLabel, tone: o.status.sellerTone, height: 26)],
                bottom: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    'Reçue ${FrenchDates.relativeDay(o.createdAt)} à ${FrenchDates.hour(o.createdAt)} · ${plural(o.items.length, 'article')}',
                    style: AppTypography.body(size: 13, color: AppColors.muted),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    if (o.status == OrderStatus.pendingConfirmation) ...[
                      InfoBanner(
                        icon: AppIcons.clock,
                        background: AppColors.orange100,
                        borderColor: AppColors.orange300,
                        iconColor: AppColors.orange700,
                        radius: 16,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'À confirmer avant ${o.acceptBefore == null ? '14h' : FrenchDates.hour(o.acceptBefore!, compact: true)}',
                                    style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.orangeInk),
                                  ),
                                  const TextSpan(text: ' pour la livraison de demain.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: AppButton(
                                    label: 'Refuser',
                                    variant: AppButtonVariant.dangerOutline,
                                    height: 46,
                                    radius: 12,
                                    fontSize: 14,
                                    expand: true,
                                    onPressed: controller.refuse,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 14,
                                  child: AppButton(
                                    label: 'Accepter la commande',
                                    height: 46,
                                    radius: 12,
                                    fontSize: 14,
                                    expand: true,
                                    onPressed: controller.advance,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppCard(
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Suivi', style: AppTypography.body(size: 16, weight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          if (closed)
                            Text(
                              o.status == OrderStatus.refused
                                  ? 'Commande refusée · la cliente est remboursée.'
                                  : 'Commande annulée · remboursement en cours.',
                              style: AppTypography.body(size: 14, color: AppColors.body),
                            )
                          else
                            OrderTimeline(steps: _steps(o), dotSize: 24),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      radius: 16,
                      child: Row(
                        children: [
                          AppAvatar(initials: o.buyer.avatar.initials, color: o.buyer.avatar.colorValue, size: 44, fontSize: 14),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.buyer.name, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                                if (o.buyer.meta != null)
                                  Text(o.buyer.meta!, style: AppTypography.body(size: 13, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          AppIconButton(
                            icon: AppIcons.message,
                            style: AppIconButtonStyle.soft,
                            semanticLabel: 'Écrire à ${o.buyer.name}',
                            onPressed: () => context.push(AppRoutes.chat('conv-mialy')),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Articles', style: AppTypography.body(size: 16, weight: FontWeight.w700)),
                          for (final it in o.items) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ProductThumb(visual: it.visual.copyWith(icon: 'leaf'), size: 48, radius: 10, iconSize: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(it.productName, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                                      Text(
                                        '${it.quantityLabel ?? '${it.quantity}'} × ${formatAriary(it.unitPrice)}',
                                        style: AppTypography.body(size: 12, color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(formatAriary(it.lineTotal), style: AppTypography.body(size: 14, weight: FontWeight.w700, fontFeatures: AppTypography.tabular)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          SummaryRow(size: 14, label: 'Sous-total', value: formatAriary(o.subtotal)),
                          if (o.deliveryFee > 0) ...[
                            const SizedBox(height: 6),
                            SummaryRow(size: 14, label: 'Livraison (payée par la cliente)', value: formatAriary(o.deliveryFee)),
                          ],
                          const SizedBox(height: 6),
                          SummaryRow(size: 14, label: 'Commission In my bush', value: formatAriary(-(o.commission ?? 0))),
                          const SizedBox(height: 10),
                          SummaryRow(
                            size: 15,
                            bold: true,
                            label: 'Vous recevez',
                            value: formatAriary(o.sellerNet ?? o.subtotal),
                            valueColor: AppColors.pomme800,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      radius: 16,
                      child: Column(
                        children: [
                          _InfoLine(
                            icon: o.deliveryMode == DeliveryMode.home ? AppIcons.truck : AppIcons.store,
                            title: '${o.deliveryMode.label} · ${o.deliverySlot ?? ''}',
                            subtitle: o.address ?? 'Retrait à la ferme, Antsirabe',
                          ),
                          const SizedBox(height: 12),
                          _InfoLine(
                            icon: AppIcons.wallet,
                            title: 'Payée par ${o.paymentMethod.family}',
                            subtitle: 'Versement sur votre compte après la livraison',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: Row(
                  children: [
                    AppIconButton(
                      icon: AppIcons.receipt,
                      size: 52,
                      radius: 14,
                      style: AppIconButtonStyle.outline,
                      semanticLabel: 'Imprimer le bon',
                      onPressed: () => showAppToast(context, 'Bon de préparation prêt à imprimer', icon: AppIcons.receipt),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: closed ? o.status.sellerDetailLabel : _ctas[step.clampStep()],
                        fontSize: 15,
                        expand: true,
                        variant: finished ? AppButtonVariant.muted : AppButtonVariant.primary,
                        onPressed: finished ? null : controller.advance,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

extension on int {
  int clampStep() => this < 0 ? 0 : (this > 4 ? 4 : this);
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.pomme700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.body(size: 14, color: AppColors.body)),
            ],
          ),
        ),
      ],
    );
  }
}
