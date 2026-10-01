import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../favorites/favorites_providers.dart';
import '../catalog_providers.dart';
import '../data/catalog_models.dart';
import 'widgets/product_tile.dart';

/// M-Seller — public shop profile.
class SellerScreen extends ConsumerWidget {
  const SellerScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopProvider(slug));
    return Scaffold(
      body: shop.when(
        data: (s) => _SellerView(shop: s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.all(8), child: AppBackButton()),
              Expanded(child: Center(child: ErrorState(error: e, onRetry: () => ref.invalidate(shopProvider(slug))))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerView extends ConsumerStatefulWidget {
  const _SellerView({required this.shop});

  final Shop shop;

  @override
  ConsumerState<_SellerView> createState() => _SellerViewState();
}

class _SellerViewState extends ConsumerState<_SellerView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.shop;
    final products = ref.watch(shopProductsProvider(s.slug));
    final latest = ref.watch(shopLatestReviewProvider(s.slug)).valueOrNull;
    final following = ref.watch(followedShopsProvider).valueOrNull?.any((x) => x.id == s.id) ?? false;
    final top = MediaQuery.of(context).padding.top;
    final productCount = products.valueOrNull?.length ?? s.productCount;

    Widget stat(String value, String label, {bool star = false, bool divider = true}) => Expanded(
          child: Container(
            decoration: BoxDecoration(border: divider ? const Border(left: BorderSide(color: AppColors.divider)) : null),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value, style: AppTypography.body(size: 17, weight: FontWeight.w700)),
                    if (star) ...[
                      const SizedBox(width: 3),
                      const Icon(AppIcons.star, size: 14, color: AppColors.orange500),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(label, style: AppTypography.body(size: 12, color: AppColors.muted)),
              ],
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        Stack(
          children: [
            Container(
              height: 190 + top,
              color: s.cover.tintColor,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.only(right: 16, bottom: 14),
              child: Opacity(
                opacity: 0.7,
                child: Text(
                  'PHOTO · LA BOUTIQUE',
                  style: AppTypography.body(size: 11, weight: FontWeight.w700, color: s.cover.inkColor, letterSpacing: 0.9),
                ),
              ),
            ),
            Positioned(
              top: top + 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  AppIconButton(
                    icon: AppIcons.arrowLeft,
                    style: AppIconButtonStyle.glass,
                    semanticLabel: 'Retour',
                    onPressed: () => popOrGo(context, AppRoutes.home),
                  ),
                  const Spacer(),
                  AppIconButton(
                    icon: AppIcons.share,
                    style: AppIconButtonStyle.glass,
                    semanticLabel: 'Partager',
                    onPressed: () => showAppToast(context, 'Lien de la boutique copié', icon: AppIcons.share),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 190 + top - 44, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppAvatar(
                    initials: s.avatar.initials,
                    color: s.avatar.colorValue,
                    size: 88,
                    fontSize: 30,
                    borderColor: AppColors.bg,
                    borderWidth: 4,
                  ),
                  const Spacer(),
                  if (s.verified)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppTag(
                        label: 'Vendeur vérifié',
                        icon: AppIcons.shield,
                        background: AppColors.infoBg,
                        foreground: AppColors.infoFg,
                        radius: 999,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.name, style: AppTypography.pageTitle),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(AppIcons.pin, size: 16, color: AppColors.body),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${s.location}${s.distanceKm != null ? ' · ${s.distanceKm} km de vous' : ''}',
                      style: AppTypography.body(size: 14, color: AppColors.body),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Row(
                  children: [
                    stat(formatRating(s.ratingAvg), '${s.ratingCount} avis', star: true, divider: false),
                    stat('$productCount', 'produits'),
                    stat(s.since, 'membre'),
                    stat(s.responseTime ?? '—', 'réponse'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (s.description.isNotEmpty) ...[
                Text(s.description, style: AppTypography.body(size: 15, color: AppColors.bodyStrong, height: 23 / 15)),
                const SizedBox(height: 18),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (s.pickup)
                    const AppTag(
                      label: 'Retrait sur place',
                      icon: AppIcons.store,
                      background: AppColors.sand,
                      foreground: AppColors.body,
                      fontSize: 13,
                      radius: 8,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    ),
                  AppTag(
                    label: s.deliveryNote ?? 'Livraison à domicile',
                    icon: AppIcons.truck,
                    background: AppColors.sand,
                    foreground: AppColors.body,
                    fontSize: 13,
                    radius: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Contacter le vendeur',
                      icon: AppIcons.message,
                      fontSize: 15,
                      height: 50,
                      expand: true,
                      onPressed: () => context.push(AppRoutes.chat('conv-ra')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: following ? 'Suivi' : 'Suivre',
                    icon: following ? AppIcons.heartFilled : AppIcons.heart,
                    variant: AppButtonVariant.outline,
                    foregroundColor: following ? AppColors.orange600 : AppColors.ink,
                    fontSize: 15,
                    height: 50,
                    onPressed: () => ref.read(followedShopsProvider.notifier).toggle(s),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              UnderlineTabs(
                labels: ['Produits ($productCount)', 'Avis (${s.ratingCount})', 'À propos'],
                selectedIndex: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 18),
              if (_tab == 0)
                products.when(
                  data: (items) => items.isEmpty
                      ? const EmptyState(icon: AppIcons.package, title: 'Aucun produit pour le moment')
                      : ProductGrid(products: items),
                  loading: () => const TwoColumnGrid(children: [ProductCardSkeleton(), ProductCardSkeleton()]),
                  error: (e, _) => ErrorState(error: e),
                )
              else if (_tab == 2)
                Text(
                  'Membre depuis ${s.since}. ${s.description}',
                  style: AppTypography.body(size: 15, color: AppColors.bodyStrong, height: 23 / 15),
                ),
              if (latest != null) ...[
                const SizedBox(height: 18),
                AppCard(
                  radius: 16,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SubTitle(
                        'Derniers avis',
                        size: 16,
                        trailing: AppTextLink(label: 'Voir les ${s.ratingCount}', onTap: () => setState(() => _tab = 1)),
                      ),
                      const SizedBox(height: 8),
                      Text('« ${latest.comment} »', style: AppTypography.body(size: 14, color: AppColors.bodyStrong, height: 21 / 14)),
                      const SizedBox(height: 8),
                      Text(
                        '${latest.authorName} · ${'★' * latest.rating} · ${FrenchDates.ago(latest.createdAt)}',
                        style: AppTypography.body(size: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
