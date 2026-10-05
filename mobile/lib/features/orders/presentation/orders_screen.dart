import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../cart/cart_providers.dart';
import '../../catalog/data/catalog_repository.dart';
import '../data/models/models.dart';
import '../data/orders_repository.dart';

/// M-Orders — "Mes commandes".
class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final purchases = ref.watch(purchasesProvider);
    final all = purchases.valueOrNull ?? const <Purchase>[];
    final active = all.where((p) => p.isActive).length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Mes commandes',
            fallback: AppRoutes.profile,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            bottomGap: 6,
            actions: [
              AppIconButton(icon: AppIcons.search, semanticLabel: 'Rechercher une commande', onPressed: () {}),
            ],
            bottom: UnderlineTabs(
              showBaseline: false,
              labels: ['Toutes (${all.length})', 'En cours ($active)', 'Livrées'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Purchase>>(
              value: purchases,
              onRetry: () => ref.invalidate(purchasesProvider),
              loading: () => const ListSkeleton(count: 4, circle: false, leadingSize: 52),
              data: (list) {
                final filtered = switch (_tab) {
                  1 => list.where((p) => p.isActive).toList(),
                  2 => list.where((p) => p.status == OrderStatus.delivered).toList(),
                  _ => list,
                };
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: AppIcons.package,
                    title: 'Aucune commande',
                    message: 'Vos commandes apparaîtront ici.',
                    actionLabel: 'Découvrir les produits',
                    onAction: () => context.go(AppRoutes.home),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.pomme700,
                  onRefresh: () async {
                    ref.invalidate(purchasesProvider);
                    await ref.read(purchasesProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _PurchaseCard(purchase: filtered[index]),
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

class _PurchaseCard extends ConsumerWidget {
  const _PurchaseCard({required this.purchase});

  final Purchase purchase;

  Future<void> _reorder(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartControllerProvider.notifier);
    final catalog = ref.read(catalogRepositoryProvider);
    for (final item in purchase.items) {
      final slug = item.productSlug.isNotEmpty ? item.productSlug : item.productId.replaceFirst('prd-', '');
      try {
        await cart.add(await catalog.getProduct(slug), quantity: item.quantity);
      } catch (_) {
        // Product no longer on sale: skip it.
      }
    }
    if (context.mounted) context.push(AppRoutes.cart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = purchase;
    final status = p.status;
    void detail() => context.push(AppRoutes.order(p.id));
    void contact() => context.push(AppRoutes.chat('conv-ra'));

    List<Widget> actions;
    switch (status) {
      case OrderStatus.inDelivery:
      case OrderStatus.prepared:
        actions = [
          _action('Suivre', AppIcons.truck, true, detail),
          _action('Contacter', AppIcons.message, false, contact),
        ];
      case OrderStatus.delivered:
        actions = [
          if (!p.reviewed)
            _action('Laisser un avis', AppIcons.starOutline, true, () => context.push(AppRoutes.orderReview(p.id))),
          _action('Racheter', AppIcons.refresh, false, () => _reorder(context, ref)),
          if (p.reviewed)
            _action('Facture', AppIcons.download, false, () => showAppToast(context, 'Facture téléchargée', icon: AppIcons.download)),
        ];
      case OrderStatus.cancelled:
      case OrderStatus.refused:
        actions = [_action('Voir le détail', AppIcons.eye, false, detail)];
      case OrderStatus.pendingConfirmation:
      case OrderStatus.accepted:
        actions = [_action('Détail', AppIcons.eye, false, detail)];
    }

    return AppCard(
      onTap: detail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.number, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${FrenchDates.dayMonth(p.createdAt)} · ${plural(p.itemCount, 'article')}',
                      style: AppTypography.body(size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              StatusPill(label: status.buyerLabel, tone: status.buyerTone, showDot: true),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final item in p.items.take(3)) ...[
                ProductThumb(visual: item.visual, size: 52, iconSize: 22),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              Text(formatAriary(p.total), style: AppTypography.body(size: 16, weight: FontWeight.w700, fontFeatures: AppTypography.tabular)),
            ],
          ),
          if (p.note != null) ...[
            const SizedBox(height: 12),
            Text(p.note!, style: AppTypography.body(size: 13, color: AppColors.body)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: actions[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(String label, IconData icon, bool primary, VoidCallback onTap) => AppButton(
        label: label,
        icon: icon,
        size: AppButtonSize.medium,
        variant: primary ? AppButtonVariant.primary : AppButtonVariant.outline,
        expand: true,
        onPressed: onTap,
      );
}
