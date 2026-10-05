import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../catalog/data/models/models.dart';
import '../seller_providers.dart';

/// M-My-Products — products & stock (inline stock stepper, visibility).
class MyProductsScreen extends ConsumerStatefulWidget {
  const MyProductsScreen({super.key});

  @override
  ConsumerState<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends ConsumerState<MyProductsScreen> {
  int _tab = 0;
  String _filter = '';

  void _setStock(Product p, int stock) {
    final previous = p.stock;
    ref.read(sellerProductsProvider.notifier).setStock(p, stock);
    showAppToast(
      context,
      'Stock mis à jour',
      actionLabel: 'Annuler',
      onAction: () => ref.read(sellerProductsProvider.notifier).setStock(p.copyWith(stock: stock), previous),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(sellerProductsProvider);
    final all = products.valueOrNull ?? const <Product>[];
    final active = all.where((p) => p.status == ProductStatus.published && !p.isOutOfStock).toList();
    final drafts = all.where((p) => p.status == ProductStatus.draft).toList();
    final out = all.where((p) => p.status == ProductStatus.published && p.isOutOfStock).toList();
    final lowCount = all.where((p) => p.status == ProductStatus.published && p.isLowStock).length;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Mes produits',
            fallback: AppRoutes.sell,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            actions: [
              AppButton(
                label: 'Ajouter',
                icon: AppIcons.plus,
                height: 40,
                radius: 10,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                onPressed: () => context.push(AppRoutes.addProduct),
              ),
            ],
            bottom: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  hint: 'Rechercher dans mes produits',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 10),
                    child: Icon(AppIcons.search, size: 18, color: AppColors.muted),
                  ),
                  height: 44,
                  radius: 12,
                  fillColor: AppColors.bg,
                  onChanged: (v) => setState(() => _filter = v),
                ),
                const SizedBox(height: 6),
                UnderlineTabs(
                  showBaseline: false,
                  gap: 22,
                  fontSize: 14,
                  labels: ['Actifs (${active.length})', 'Brouillons (${drafts.length})', 'Rupture (${out.length})'],
                  selectedIndex: _tab,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Product>>(
              value: products,
              onRetry: () => ref.invalidate(sellerProductsProvider),
              loading: () => const ListSkeleton(count: 4, circle: false, leadingSize: 64),
              data: (_) {
                final source = switch (_tab) {
                  1 => drafts,
                  2 => out,
                  _ => [...active, ...out.where((p) => !p.visible)],
                };
                final needle = slugify(_filter);
                final list = needle.isEmpty ? source : source.where((p) => slugify(p.name).contains(needle)).toList();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    if (lowCount > 0 && _tab == 0) ...[
                      InfoBanner(
                        icon: AppIcons.alert,
                        background: AppColors.orange100,
                        iconColor: AppColors.orange700,
                        fontSize: 13,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: plural(lowCount, 'produit'),
                                style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.orangeInk),
                              ),
                              TextSpan(text: lowCount > 1 ? ' passent sous le seuil d’alerte' : ' passe sous le seuil d’alerte'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (list.isEmpty)
                      const EmptyState(icon: AppIcons.package, title: 'Aucun produit ici')
                    else
                      for (final p in list) ...[
                        _StockCard(
                          product: p,
                          onStock: (v) => _setStock(p, v),
                          onVisible: (v) => ref.read(sellerProductsProvider.notifier).setVisible(p, v),
                        ),
                        const SizedBox(height: 10),
                      ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.product, required this.onStock, required this.onVisible});

  final Product product;
  final ValueChanged<int> onStock;
  final ValueChanged<bool> onVisible;

  @override
  Widget build(BuildContext context) {
    final p = product;
    final draft = p.status == ProductStatus.draft;
    final out = p.isOutOfStock && !draft;
    final low = p.isLowStock && !draft;
    final status = draft ? 'Brouillon' : (out ? 'Rupture · masqué' : (low ? 'Stock faible' : 'En ligne'));
    final tone = draft || out ? StatusTone.neutral : (low ? StatusTone.warning : StatusTone.success);

    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      borderColor: low ? AppColors.orange300 : AppColors.line,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductThumb(visual: p.visual.copyWith(icon: 'leaf'), size: 64, iconSize: 26, opacity: out ? 0.55 : 1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(p.name, style: AppTypography.body(size: 15, weight: FontWeight.w700))),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            tooltip: 'Modifier ${p.name}',
                            onPressed: () => context.push(AppRoutes.editProduct(p.id)),
                            icon: const Icon(AppIcons.edit, size: 18, color: AppColors.body),
                          ),
                        ),
                      ],
                    ),
                    Text.rich(
                      TextSpan(
                        text: formatAriary(p.price),
                        style: AppTypography.body(size: 14, weight: FontWeight.w700, fontFeatures: AppTypography.tabular),
                        children: [
                          TextSpan(text: ' / ${p.unitLabel}', style: AppTypography.body(size: 14, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusPill(label: status, tone: tone, dense: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          Row(
            children: [
              Text('Stock', style: AppTypography.body(size: 13, color: AppColors.muted)),
              const SizedBox(width: 10),
              QuantityStepper(
                value: p.stock,
                min: 0,
                size: QuantityStepperSize.small,
                valueWidth: 60,
                label: '${p.stock} ${p.stockUnitLabel ?? p.unitLabel}',
                borderColor: low ? AppColors.orangeBorderStrong : AppColors.lineStrong,
                valueColor: out ? AppColors.disabled : (low ? AppColors.orange700 : AppColors.ink),
                decreaseLabel: 'Retirer une unité',
                increaseLabel: 'Ajouter une unité',
                onChanged: onStock,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => onVisible(!p.visible),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Text('Visible', style: AppTypography.body(size: 13, color: AppColors.body)),
                      const SizedBox(width: 8),
                      AppSwitch(value: p.visible, small: true, onChanged: onVisible, semanticLabel: 'Visible sur la marketplace'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
