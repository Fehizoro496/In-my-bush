import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../../cart/presentation/widgets/cart_icon_button.dart';
import '../../notifications/data/notifications_repository.dart';
import '../data/account_repository.dart';

/// Local preferences of the Settings screen.
class SettingsPrefs {
  const SettingsPrefs({
    this.orderUpdates = true,
    this.messages = true,
    this.promotions = false,
    this.sms = true,
    this.shopPaused = false,
    this.twoFactor = true,
  });

  final bool orderUpdates;
  final bool messages;
  final bool promotions;
  final bool sms;
  final bool shopPaused;
  final bool twoFactor;

  SettingsPrefs copyWith({bool? orderUpdates, bool? messages, bool? promotions, bool? sms, bool? shopPaused, bool? twoFactor}) =>
      SettingsPrefs(
        orderUpdates: orderUpdates ?? this.orderUpdates,
        messages: messages ?? this.messages,
        promotions: promotions ?? this.promotions,
        sms: sms ?? this.sms,
        shopPaused: shopPaused ?? this.shopPaused,
        twoFactor: twoFactor ?? this.twoFactor,
      );
}

final settingsPrefsProvider = StateProvider<SettingsPrefs>((ref) => const SettingsPrefs());

/// M-Settings — "Paramètres" tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final prefs = ref.watch(settingsPrefsProvider);
    final unread = ref.watch(unreadNotificationsCountProvider);
    final addresses = ref.watch(addressesProvider).valueOrNull;
    final methods = ref.watch(paymentMethodsProvider).valueOrNull;
    void update(SettingsPrefs p) => ref.read(settingsPrefsProvider.notifier).state = p;

    String? defaultMethod;
    for (final m in methods ?? const []) {
      if (m.isDefault) defaultMethod = m.label;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: LargeTitleBar(title: 'Paramètres', actions: [CartIconButton()]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  if (user == null)
                    AppCard(
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Connectez-vous', style: AppTypography.display(size: 20, weight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('Un seul compte pour acheter et vendre.', style: AppTypography.body(size: 14, color: AppColors.muted)),
                          const SizedBox(height: 14),
                          AppButton(label: 'Se connecter', expand: true, onPressed: () => context.push(AppRoutes.login)),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      radius: 20,
                      borderColor: AppColors.pomme300,
                      borderWidth: 1.5,
                      padding: const EdgeInsets.all(16),
                      onTap: () => context.push(AppRoutes.profile),
                      child: Row(
                        children: [
                          AppAvatar(initials: user.initials, color: hexColor(user.avatarColor), size: 60, fontSize: 21),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName, style: AppTypography.body(size: 18, weight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text(user.roleLine, style: AppTypography.body(size: 13, color: AppColors.muted)),
                                const SizedBox(height: 3),
                                Text('Voir mon profil', style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.pomme700)),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(color: AppColors.pomme100, shape: BoxShape.circle),
                            child: const Icon(AppIcons.chevronRight, size: 18, color: AppColors.pomme800),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Mon compte',
                    children: [
                      SettingsTile(
                        icon: AppIcons.user,
                        title: 'Mon profil',
                        subtitle: 'Informations personnelles, commandes, favoris',
                        onTap: () => context.push(AppRoutes.profile),
                      ),
                      SettingsTile(
                        icon: AppIcons.pin,
                        title: 'Adresses',
                        value: addresses == null ? null : '${addresses.length}',
                        onTap: () => context.push(AppRoutes.addresses),
                      ),
                      SettingsTile(
                        icon: AppIcons.wallet,
                        title: 'Moyens de paiement',
                        value: defaultMethod,
                        onTap: () => context.push(AppRoutes.payments),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Notifications',
                    children: [
                      SettingsSwitchTile(
                        icon: AppIcons.truck,
                        title: 'Suivi des commandes',
                        value: prefs.orderUpdates,
                        onChanged: (v) => update(prefs.copyWith(orderUpdates: v)),
                      ),
                      SettingsSwitchTile(
                        icon: AppIcons.message,
                        title: 'Messages',
                        value: prefs.messages,
                        onChanged: (v) => update(prefs.copyWith(messages: v)),
                      ),
                      SettingsSwitchTile(
                        icon: AppIcons.percent,
                        title: 'Promotions et nouveautés',
                        value: prefs.promotions,
                        onChanged: (v) => update(prefs.copyWith(promotions: v)),
                      ),
                      SettingsSwitchTile(
                        icon: AppIcons.bell,
                        title: 'Recevoir aussi par SMS',
                        subtitle: 'Utile sans connexion internet',
                        value: prefs.sms,
                        onChanged: (v) => update(prefs.copyWith(sms: v)),
                      ),
                      SettingsTile(
                        icon: AppIcons.bell,
                        title: 'Voir mes notifications',
                        value: unread > 0 ? '$unread nouvelle${unread > 1 ? 's' : ''}' : null,
                        valueColor: AppColors.orange700,
                        valueWeight: FontWeight.w700,
                        onTap: () => context.go(AppRoutes.notifications),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Espace vendeur',
                    children: [
                      SettingsTile(
                        icon: AppIcons.chart,
                        title: user?.isSeller == true ? 'Tableau de bord vendeur' : 'Devenir vendeur',
                        onTap: () => context.go(user?.isSeller == true ? AppRoutes.sell : AppRoutes.becomeSeller),
                      ),
                      if (user?.isSeller == true) ...[
                        SettingsTile(
                          icon: AppIcons.store,
                          title: 'Profil de la boutique',
                          value: user?.shopName,
                          onTap: () => context.push(AppRoutes.shopProfile),
                        ),
                        SettingsSwitchTile(
                          icon: AppIcons.clock,
                          title: 'Mettre ma boutique en pause',
                          subtitle: 'Vos produits sont masqués temporairement',
                          value: prefs.shopPaused,
                          onChanged: (v) => update(prefs.copyWith(shopPaused: v)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Sécurité & préférences',
                    children: [
                      SettingsTile(
                        icon: AppIcons.lock,
                        title: 'Mot de passe',
                        value: 'Modifier',
                        onTap: () => showAppToast(context, 'Un code de réinitialisation vous a été envoyé par SMS', icon: AppIcons.lock),
                      ),
                      SettingsSwitchTile(
                        icon: AppIcons.shield,
                        title: 'Validation en 2 étapes',
                        subtitle: 'Code SMS à la connexion',
                        value: prefs.twoFactor,
                        onChanged: (v) => update(prefs.copyWith(twoFactor: v)),
                      ),
                      const SettingsTile(icon: AppIcons.info, title: 'Langue', value: 'Français'),
                      const SettingsTile(icon: AppIcons.wallet, title: 'Devise', value: 'Ariary (Ar)'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Aide',
                    children: [
                      SettingsTile(icon: AppIcons.message, title: 'Aide & contact', onTap: () => context.push(AppRoutes.chat('conv-team'))),
                      SettingsTile(
                        icon: AppIcons.flag,
                        title: 'Signaler un problème',
                        onTap: () => showAppToast(context, 'Merci, notre équipe vous recontacte rapidement', icon: AppIcons.flag),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (user != null) ...[
                    AppButton(
                      label: 'Se déconnecter',
                      icon: AppIcons.logout,
                      variant: AppButtonVariant.outline,
                      fontSize: 15,
                      height: 50,
                      expand: true,
                      onPressed: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      label: 'Supprimer mon compte',
                      icon: AppIcons.trash,
                      variant: AppButtonVariant.ghost,
                      foregroundColor: AppColors.dangerFg,
                      fontSize: 14,
                      height: 44,
                      expand: true,
                      onPressed: () => showAppSheet<void>(
                        context,
                        (sheetContext) => ConfirmSheet(
                          title: 'Supprimer mon compte ?',
                          message: 'Vos commandes en cours restent à honorer. Cette action est définitive.',
                          confirmLabel: 'Supprimer définitivement',
                          onConfirm: () => Navigator.of(sheetContext).pop(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Version ${AppConfig.version} · Conditions · Confidentialité',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(size: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
