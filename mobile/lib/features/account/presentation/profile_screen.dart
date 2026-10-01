import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../../cart/cart_providers.dart';
import '../../favorites/favorites_providers.dart';
import '../../messages/messages_providers.dart';
import '../../orders/data/order_models.dart';
import '../../orders/data/orders_repository.dart';
import '../../seller/seller_providers.dart';

/// M-Account — "Mon profil" (reached from Paramètres).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref.read(authControllerProvider.notifier).updateProfile(
          fullName: _name.text,
          email: _email.text,
          city: _city.text,
        );
    if (mounted) showAppToast(context, 'Informations enregistrées');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user != null && !_filled) {
      _name.text = user.fullName;
      _email.text = user.email ?? '';
      _city.text = user.city;
      _filled = true;
    }
    final purchases = ref.watch(purchasesProvider).valueOrNull ?? const <Purchase>[];
    final active = purchases.where((p) => p.isActive).toList();
    final favorites = ref.watch(favoritesControllerProvider).valueOrNull?.length ?? 0;
    final unreadMessages = ref.watch(unreadMessagesCountProvider);
    final cartCount = ref.watch(cartCountProvider);
    final toReview = purchases.where((p) => p.canReview).length;
    final isSeller = user?.isSeller ?? false;
    final toPrepare = isSeller
        ? (ref.watch(sellerOrdersProvider).valueOrNull ?? const <Order>[])
            .where((o) => o.status == OrderStatus.pendingConfirmation || o.status == OrderStatus.accepted)
            .length
        : 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(-10, 0),
                  child: const AppBackButton(fallback: AppRoutes.settings, semanticLabel: 'Retour aux paramètres'),
                ),
                Text('Mon profil', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppAvatar(
                      initials: user?.initials ?? '?',
                      color: hexColor(user?.avatarColor ?? '#365A10'),
                      size: 64,
                      fontSize: 22,
                    ),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: Semantics(
                        button: true,
                        label: 'Changer la photo',
                        child: GestureDetector(
                          onTap: () => showAppToast(context, 'Choisissez une photo depuis votre galerie', icon: AppIcons.camera),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.pomme500,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.bg, width: 3),
                            ),
                            child: const Icon(AppIcons.camera, size: 13, color: AppColors.onPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'Invité', style: AppTypography.headerTitle),
                      const SizedBox(height: 2),
                      Text(
                        'Membre depuis ${user?.createdAt?.year ?? DateTime.now().year}${user?.district.isNotEmpty == true ? ' · ${user!.district}' : ''}',
                        style: AppTypography.body(size: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SegmentedSwitch<int>(
              segments: const [
                SegmentItem(value: 0, label: 'J’achète', icon: AppIcons.basket),
                SegmentItem(value: 1, label: 'Je vends', icon: AppIcons.store),
              ],
              selected: 0,
              onChanged: (v) {
                if (v == 1) context.go(isSeller ? AppRoutes.sell : AppRoutes.becomeSeller);
              },
            ),
            const SizedBox(height: 18),
            if (isSeller)
              AppCard(
                radius: 18,
                borderColor: AppColors.pomme300,
                borderWidth: 1.5,
                onTap: () => context.go(AppRoutes.sell),
                child: Row(
                  children: [
                    const IconTile(
                      icon: AppIcons.store,
                      background: AppColors.pomme500,
                      foreground: AppColors.onPrimary,
                      size: 44,
                      iconSize: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.shopName ?? 'Ma boutique', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            toPrepare > 0 ? '$toPrepare commande${toPrepare > 1 ? 's' : ''} à préparer' : 'Aucune commande à préparer',
                            style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.orange700),
                          ),
                        ],
                      ),
                    ),
                    const Icon(AppIcons.chevronRight, size: 20),
                  ],
                ),
              )
            else
              const _BecomeSellerPromo(),
            const SizedBox(height: 18),
            Row(
              children: [
                _Tile(label: 'Commandes', icon: AppIcons.package, count: active.length, onTap: () => context.push(AppRoutes.orders)),
                const SizedBox(width: 8),
                _Tile(label: 'Favoris', icon: AppIcons.heart, onTap: () => context.push(AppRoutes.favorites)),
                const SizedBox(width: 8),
                _Tile(label: 'Messages', icon: AppIcons.message, count: unreadMessages, onTap: () => context.go(AppRoutes.messages)),
                const SizedBox(width: 8),
                _Tile(label: 'Panier', icon: AppIcons.cart, count: cartCount, onTap: () => context.push(AppRoutes.cart)),
              ],
            ),
            if (active.isNotEmpty) ...[
              const SizedBox(height: 18),
              _CurrentOrderCard(purchase: active.first),
            ],
            const SizedBox(height: 18),
            SettingsGroup(
              title: 'Mes achats',
              children: [
                SettingsTile(
                  icon: AppIcons.receipt,
                  title: 'Commandes & historique',
                  value: '${purchases.length}',
                  minHeight: 52,
                  onTap: () => context.push(AppRoutes.orders),
                ),
                SettingsTile(
                  icon: AppIcons.heart,
                  title: 'Favoris',
                  value: '$favorites',
                  minHeight: 52,
                  onTap: () => context.push(AppRoutes.favorites),
                ),
                SettingsTile(
                  icon: AppIcons.starOutline,
                  title: 'Avis à laisser',
                  value: toReview > 0 ? '$toReview en attente' : null,
                  valueColor: AppColors.orange700,
                  valueWeight: FontWeight.w600,
                  minHeight: 52,
                  onTap: () {
                    final target = purchases.where((p) => p.canReview).toList();
                    if (target.isNotEmpty) context.push(AppRoutes.orderReview(target.first.id));
                  },
                ),
                SettingsTile(
                  icon: AppIcons.message,
                  title: 'Messages',
                  value: unreadMessages > 0 ? '$unreadMessages non lus' : null,
                  valueColor: AppColors.pomme700,
                  valueWeight: FontWeight.w600,
                  minHeight: 52,
                  onTap: () => context.go(AppRoutes.messages),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: GroupLabel('Informations personnelles')),
                AppTextLink(label: 'Enregistrer', fontSize: 13, onTap: _save),
              ],
            ),
            const SizedBox(height: 8),
            AppCard(
              radius: 16,
              child: Column(
                children: [
                  AppTextField(label: 'Nom complet', labelSize: 13, labelGap: 5, height: 46, controller: _name),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Téléphone',
                    labelSize: 13,
                    labelGap: 5,
                    height: 46,
                    initialValue: user?.maskedPhone ?? '',
                    enabled: false,
                    verified: user?.phoneVerified ?? false,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'E-mail',
                    labelSize: 13,
                    labelGap: 5,
                    height: 46,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    verified: user?.emailVerified ?? false,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(label: 'Ville', labelSize: 13, labelGap: 5, height: 46, controller: _city),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: AppIcons.settings,
                  title: 'Adresses, paiement, notifications…',
                  value: 'Paramètres',
                  valueColor: AppColors.pomme700,
                  valueWeight: FontWeight.w700,
                  showChevron: false,
                  minHeight: 52,
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.icon, required this.onTap, this.count = 0});

  final String label;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(icon, size: 22, color: AppColors.pomme700),
                  const SizedBox(height: 6),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 12, weight: FontWeight.w600)),
                ],
              ),
            ),
            if (count > 0) Positioned(top: -4, right: 8, child: CountBadge(count: count)),
          ],
        ),
      ),
    );
  }
}

class _BecomeSellerPromo extends StatelessWidget {
  const _BecomeSellerPromo();

  @override
  Widget build(BuildContext context) {
    Widget step(int n, String text, bool active) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: active ? AppColors.pomme500 : const Color(0x29F4FAE8),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$n',
                  style: AppTypography.body(size: 12, weight: FontWeight.w800, color: active ? AppColors.onPrimary : AppColors.pomme50),
                ),
              ),
              const SizedBox(width: 10),
              Text(text, style: AppTypography.body(size: 14, color: AppColors.pomme50)),
            ],
          ),
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.pomme900, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(color: AppColors.pomme800, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('MÊME COMPTE, NOUVELLE CASQUETTE', style: AppTypography.overline(color: AppColors.pommeLight)),
                const SizedBox(height: 6),
                Text(
                  'Vendez vos produits bio en 3 étapes',
                  style: AppTypography.display(size: 21, weight: FontWeight.w700, color: AppColors.pomme50, height: 1.15),
                ),
                const SizedBox(height: 6),
                step(1, 'Nommez votre boutique', true),
                step(2, 'Vérifiez votre identité', false),
                step(3, 'Publiez votre premier produit', false),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Devenir vendeur',
                  trailingIcon: AppIcons.arrowRight,
                  height: 48,
                  radius: 12,
                  fontSize: 15,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.becomeSeller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentOrderCard extends StatelessWidget {
  const _CurrentOrderCard({required this.purchase});

  final Purchase purchase;

  @override
  Widget build(BuildContext context) {
    final order = purchase.orders.first;
    final item = order.items.isEmpty ? null : order.items.first;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Commande en cours', style: AppTypography.body(size: 15, weight: FontWeight.w700))),
              StatusPill(label: purchase.status.buyerLabel, tone: purchase.status.buyerTone),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (item != null) ProductThumb(visual: item.visual, size: 52, iconSize: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${purchase.number} · ${order.shop.name}', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(purchase.note ?? '', style: AppTypography.body(size: 13, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBars(count: 4, filled: purchase.status.step < 0 ? 0 : purchase.status.step),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Suivre',
                  variant: AppButtonVariant.soft,
                  size: AppButtonSize.medium,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.order(purchase.id)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Vendeur',
                  icon: AppIcons.message,
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  expand: true,
                  onPressed: () => context.push(AppRoutes.chat('conv-ra')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
