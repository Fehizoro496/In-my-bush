import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../orders/data/order_models.dart';
import '../data/seller_models.dart';
import '../seller_providers.dart';
import 'widgets/seller_widgets.dart';

/// M-Sell-Dashboard — "Vendre" tab.
class SellDashboardScreen extends ConsumerStatefulWidget {
  const SellDashboardScreen({super.key});

  @override
  ConsumerState<SellDashboardScreen> createState() => _SellDashboardScreenState();
}

class _SellDashboardScreenState extends ConsumerState<SellDashboardScreen> {
  SalesPeriod _period = SalesPeriod.month;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user != null && !user.isSeller) return const _NotSellerYet();

    final dashboard = ref.watch(sellerDashboardProvider(_period));
    final orders = ref.watch(sellerOrdersProvider);
    final shop = CatalogMockData.jardinDeHery;
    final shopName = user?.shopName ?? shop.name;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.pomme700,
          onRefresh: () async {
            ref.invalidate(sellerDashboardProvider(_period));
            ref.invalidate(sellerOrdersProvider);
            await ref.read(sellerDashboardProvider(_period).future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const ModeSwitch(selling: true),
              const SizedBox(height: 18),
              Row(
                children: [
                  AppAvatar(initials: initialsOf(shopName), color: AppColors.pomme700, size: 48, radius: 14, fontSize: 17, display: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shopName, style: AppTypography.headerTitle),
                        const SizedBox(height: 2),
                        const DotLabel(label: 'Boutique en ligne'),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: AppIcons.eye,
                    style: AppIconButtonStyle.outline,
                    semanticLabel: 'Voir ma boutique',
                    onPressed: () => context.push(AppRoutes.seller(shop.slug)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (final p in const [SalesPeriod.week, SalesPeriod.month, SalesPeriod.year]) ...[
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
              AsyncValueView<SellerDashboard>(
                value: dashboard,
                onRetry: () => ref.invalidate(sellerDashboardProvider(_period)),
                loading: () => const Skeleton(height: 330, radius: 20),
                data: (d) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.pomme900, borderRadius: BorderRadius.circular(20)),
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
                                    Text(
                                      'Chiffre des ventes · ${_period.label}',
                                      style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.pommeLight),
                                    ),
                                    const SizedBox(height: 4),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        formatAriary(d.revenue),
                                        style: AppTypography.display(
                                          size: 32,
                                          weight: FontWeight.w800,
                                          color: AppColors.pomme50,
                                          fontFeatures: AppTypography.tabular,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AppTag(
                                label: formatPercent(d.trendPercent, signed: true),
                                icon: AppIcons.trend,
                                background: AppColors.pomme500,
                                foreground: AppColors.onPrimary,
                                fontWeight: FontWeight.w800,
                                radius: 999,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SalesBarChart(bars: d.bars, highlightIndex: 5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    TwoColumnGrid(
                      spacing: 10,
                      children: [
                        _Kpi(
                          icon: AppIcons.receipt,
                          value: '${d.ordersReceived}',
                          label: 'Commandes reçues',
                          sub: '${d.toPrepare} à préparer',
                          subColor: AppColors.orange700,
                          onTap: () => context.push(AppRoutes.ordersReceived),
                        ),
                        _Kpi(
                          icon: AppIcons.package,
                          value: '${d.activeProducts}',
                          label: 'Produits actifs',
                          sub: plural(d.drafts, 'brouillon'),
                          onTap: () => context.push(AppRoutes.myProducts),
                        ),
                        _Kpi(
                          icon: AppIcons.alert,
                          value: '${d.lowStock}',
                          label: 'Bientôt en rupture',
                          sub: 'Réassortir →',
                          subColor: AppColors.orange700,
                          background: AppColors.orange100,
                          foreground: AppColors.orange700,
                          border: AppColors.orange300,
                          onTap: () => context.push(AppRoutes.myProducts),
                        ),
                        _Kpi(
                          icon: AppIcons.star,
                          value: formatRating(d.ratingAvg),
                          label: 'Note moyenne',
                          sub: '${d.ratingCount} avis',
                          background: AppColors.orange50,
                          foreground: AppColors.orange600,
                          onTap: () => context.push(AppRoutes.reviewsReceived),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: 'Ajouter un produit',
                icon: AppIcons.plus,
                expand: true,
                onPressed: () => context.push(AppRoutes.addProduct),
              ),
              const SizedBox(height: 18),
              SectionHeader(
                title: 'À préparer',
                titleSize: 20,
                actionLabel: 'Commandes reçues',
                onAction: () => context.push(AppRoutes.ordersReceived),
              ),
              const SizedBox(height: 10),
              ...(orders.valueOrNull ?? const <Order>[])
                  .where((o) => o.status == OrderStatus.pendingConfirmation || o.status == OrderStatus.accepted)
                  .map((o) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _OrderRow(order: o))),
              const SizedBox(height: 8),
              TwoColumnGrid(
                spacing: 10,
                children: [
                  _QuickLink(icon: AppIcons.package, label: 'Mes produits', onTap: () => context.push(AppRoutes.myProducts)),
                  _QuickLink(icon: AppIcons.layers, label: 'Gestion du stock', onTap: () => context.push(AppRoutes.myProducts)),
                  _QuickLink(icon: AppIcons.chart, label: 'Historique ventes', onTap: () => context.push(AppRoutes.salesHistory)),
                  _QuickLink(icon: AppIcons.starOutline, label: 'Avis reçus', onTap: () => context.push(AppRoutes.reviewsReceived)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.value,
    required this.label,
    required this.sub,
    this.subColor = AppColors.muted,
    this.background = AppColors.pomme100,
    this.foreground = AppColors.pomme700,
    this.border = AppColors.line,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final String sub;
  final Color subColor;
  final Color background;
  final Color foreground;
  final Color border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      borderColor: border,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, background: background, foreground: foreground, size: 34, radius: 10, iconSize: 18),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.display(size: 26, weight: FontWeight.w800, height: 1)),
          const SizedBox(height: 8),
          Text(label, style: AppTypography.body(size: 13, color: AppColors.body, height: 17 / 13)),
          Text(sub, style: AppTypography.body(size: 13, weight: FontWeight.w600, color: subColor, height: 17 / 13)),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final label = status == OrderStatus.pendingConfirmation ? 'Nouvelle' : status.sellerLabel;
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => context.push(AppRoutes.orderReceived(order.id)),
      child: Row(
        children: [
          AppAvatar(initials: order.buyer.avatar.initials, color: order.buyer.avatar.colorValue, size: 40, fontSize: 13),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${order.buyer.name} · ${order.number}', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(order.itemsSummary, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatAriary(order.subtotal), style: AppTypography.body(size: 14, weight: FontWeight.w700, fontFeatures: AppTypography.tabular)),
              const SizedBox(height: 4),
              StatusPill(label: label, tone: status.sellerTone, dense: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.pomme700),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTypography.body(size: 14, weight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

/// Shown on the "Vendre" tab when the account has no shop yet.
class _NotSellerYet extends StatelessWidget {
  const _NotSellerYet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ModeSwitch(selling: true),
            const SizedBox(height: 24),
            EmptyState(
              icon: AppIcons.store,
              title: 'Vendez vos produits bio',
              message: 'Même compte, nouvelle casquette : ouvrez votre boutique en 3 étapes.',
              actionLabel: 'Devenir vendeur',
              onAction: () => context.push(AppRoutes.becomeSeller),
            ),
          ],
        ),
      ),
    );
  }
}
