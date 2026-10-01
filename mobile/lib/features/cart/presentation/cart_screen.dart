import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../cart_providers.dart';
import '../data/cart_models.dart';

/// M-Cart — pushed from the cart icon of the top bar.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final ok = ref.read(cartControllerProvider.notifier).applyPromo(_promoController.text);
    showAppToast(
      context,
      ok ? 'Code ${_promoController.text.trim().toUpperCase()} appliqué' : 'Code promo invalide',
      icon: ok ? AppIcons.check : AppIcons.alert,
    );
    if (ok) _promoController.clear();
  }

  Future<void> _confirmClear() async {
    await showAppSheet<void>(
      context,
      (sheetContext) => ConfirmSheet(
        title: 'Vider le panier ?',
        message: 'Tous les articles seront retirés de votre panier.',
        confirmLabel: 'Vider le panier',
        onConfirm: () {
          ref.read(cartControllerProvider.notifier).clear();
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartControllerProvider);
    final cart = cartAsync.valueOrNull;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 12 + top, 16, 24),
              children: [
                Row(
                  children: [
                    Transform.translate(offset: const Offset(-10, 0), child: const AppBackButton()),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'Panier ',
                          style: AppTypography.pageTitle,
                          children: [
                            TextSpan(
                              text: '(${cart?.unitCount ?? 0})',
                              style: AppTypography.display(size: 28, weight: FontWeight.w600, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (cart != null && !cart.isEmpty)
                      AppTextLink(label: 'Vider', color: AppColors.muted, minHeight: 44, onTap: _confirmClear),
                  ],
                ),
                const SizedBox(height: 16),
                const StepProgressBar(
                  labels: ['Panier', 'Livraison', 'Paiement', 'Confirmation'],
                  filledCount: 1,
                  activeIndex: 0,
                ),
                const SizedBox(height: 16),
                if (cartAsync.isLoading && cart == null)
                  const ListSkeleton(count: 3, circle: false, leadingSize: 76)
                else if (cart == null || cart.isEmpty)
                  EmptyState(
                    icon: AppIcons.cart,
                    title: 'Votre panier est vide',
                    message: 'Découvrez les produits bio des producteurs près de chez vous.',
                    actionLabel: 'Voir les produits',
                    onAction: () => context.go(AppRoutes.home),
                  )
                else ...[
                  for (final group in cart.groups) ...[
                    _ShopGroupCard(group: group),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: DashedBorderBox(
                          color: AppColors.lineDashed,
                          background: AppColors.surface,
                          radius: 12,
                          child: SizedBox(
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                children: [
                                  const Icon(AppIcons.tag, size: 18, color: AppColors.orange600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _promoController,
                                      textCapitalization: TextCapitalization.characters,
                                      onSubmitted: (_) => _applyPromo(),
                                      style: AppTypography.body(size: 15),
                                      decoration: InputDecoration(
                                        isCollapsed: true,
                                        border: InputBorder.none,
                                        hintText: 'Code promo',
                                        hintStyle: AppTypography.body(size: 15, color: AppColors.disabled),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'Appliquer',
                        variant: AppButtonVariant.dark,
                        height: 48,
                        radius: 12,
                        fontSize: 14,
                        onPressed: _applyPromo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SummaryRow(label: 'Sous-total', value: formatAriary(cart.subtotal)),
                        const SizedBox(height: 10),
                        SummaryRow(
                          label: 'Livraison · ${plural(cart.shopCount, 'vendeur')}',
                          value: formatAriary(cart.deliveryFee),
                        ),
                        if (cart.discount > 0) ...[
                          const SizedBox(height: 10),
                          SummaryRow(
                            label: 'Réduction · ${cart.promoCode} −${(cart.promoRate * 100).round()} %',
                            value: formatAriary(-cart.discount),
                            color: AppColors.orange700,
                          ),
                        ],
                        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider()),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(child: Text('Total', style: AppTypography.body(size: 17, weight: FontWeight.w700))),
                            Text(
                              formatAriary(cart.total),
                              style: AppTypography.display(size: 24, weight: FontWeight.w700, fontFeatures: AppTypography.tabular),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(AppIcons.shield, size: 18, color: AppColors.pomme700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Paiement sécurisé · le vendeur est payé à la réception',
                          style: AppTypography.body(size: 13, color: AppColors.body),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (cart != null && !cart.isEmpty)
            BottomActionBar(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: AppTypography.body(size: 12, color: AppColors.muted)),
                      Text(
                        formatAriary(cart.total),
                        style: AppTypography.body(size: 18, weight: FontWeight.w700, fontFeatures: AppTypography.tabular),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: AppButton(
                      label: 'Commander',
                      trailingIcon: AppIcons.arrowRight,
                      expand: true,
                      onPressed: () => context.push(AppRoutes.checkout),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopGroupCard extends ConsumerWidget {
  const _ShopGroupCard({required this.group});

  final CartShopGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = CatalogMockData.shopBySlug(group.shopSlug);
    final avatar = shop?.avatar ?? AvatarLook(initials: initialsOf(group.shopName));
    final controller = ref.read(cartControllerProvider.notifier);
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
                AppAvatar(initials: avatar.initials, color: avatar.colorValue, size: 32, fontSize: 12),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.seller(group.shopSlug)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.shopName, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                        Text(shop?.city ?? '', style: AppTypography.body(size: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
                const Icon(AppIcons.truck, size: 15, color: AppColors.pomme700),
                const SizedBox(width: 4),
                Text(
                  '${formatAriary(3000)} · ${shop?.slug == 'ferme-tsara' ? 'jeudi' : 'demain'}',
                  style: AppTypography.body(size: 12, weight: FontWeight.w700, color: AppColors.pomme700),
                ),
              ],
            ),
          ),
          const Divider(),
          for (var i = 0; i < group.items.length; i++)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: i == 0 ? null : const Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: _CartLine(
                item: group.items[i],
                onQuantity: (q) => controller.setQuantity(group.items[i], q),
                onRemove: () => controller.remove(group.items[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.item, required this.onQuantity, required this.onRemove});

  final CartItem item;
  final ValueChanged<int> onQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final p = item.product;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductThumb(visual: p.visual, imageUrl: p.imageUrl, size: 76, iconSize: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(p.name, style: AppTypography.body(size: 15, weight: FontWeight.w700))),
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Retirer ${p.name}',
                      onPressed: onRemove,
                      icon: const Icon(AppIcons.trash, size: 17, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              Text('${formatAriary(p.price)} / ${p.unitLabel}', style: AppTypography.body(size: 13, color: AppColors.muted)),
              const SizedBox(height: 6),
              Row(
                children: [
                  QuantityStepper(
                    value: item.quantity,
                    max: p.stock > 0 ? p.stock : null,
                    size: QuantityStepperSize.small,
                    onChanged: onQuantity,
                  ),
                  const Spacer(),
                  Text(
                    formatAriary(item.lineTotal),
                    style: AppTypography.body(size: 16, weight: FontWeight.w700, fontFeatures: AppTypography.tabular),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
