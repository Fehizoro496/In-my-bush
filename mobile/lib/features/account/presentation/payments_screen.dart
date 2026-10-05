import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../data/account_repository.dart';
import '../data/models/models.dart';

/// M-Payments — payment methods (buyer) and payouts (seller).
class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  bool _cashOnDelivery = true;

  Future<void> _setDefault(SavedPaymentMethod m) async {
    await ref.read(accountRepositoryProvider).setDefaultPaymentMethod(m.id);
    ref.invalidate(paymentMethodsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final methods = ref.watch(paymentMethodsProvider);
    final isSeller = ref.watch(currentUserProvider)?.isSeller ?? false;
    final payout = isSeller ? ref.watch(payoutSummaryProvider).valueOrNull : null;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTopBar(title: 'Paiement', fallback: AppRoutes.settings),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
              children: [
                const GroupLabel('Pour payer mes achats', padding: EdgeInsets.zero),
                const SizedBox(height: 10),
                AsyncValueView<List<SavedPaymentMethod>>(
                  value: methods,
                  onRetry: () => ref.invalidate(paymentMethodsProvider),
                  loading: () => const ListSkeleton(count: 2, circle: false, leadingSize: 34),
                  data: (list) => Column(
                    children: [
                      for (final m in list) ...[
                        RadioCard(
                          selected: m.isDefault,
                          showRadio: false,
                          title: m.label,
                          subtitle: m.detail,
                          leading: Container(
                            width: 48,
                            height: 34,
                            decoration: BoxDecoration(color: m.look.tintColor, borderRadius: BorderRadius.circular(8)),
                            child: Icon(AppIcons.byKey(m.look.icon), size: 20, color: m.look.inkColor),
                          ),
                          trailing: m.isDefault
                              ? const AppTag(label: 'Par défaut', background: AppColors.pommeSelected, foreground: AppColors.pomme800)
                              : null,
                          onTap: () => _setDefault(m),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                AppButton(
                  label: 'Ajouter un moyen de paiement',
                  icon: AppIcons.plus,
                  variant: AppButtonVariant.dashed,
                  height: 50,
                  fontSize: 15,
                  expand: true,
                  onPressed: () => showAppToast(context, 'Ajout de MVola, Orange Money, Airtel Money ou carte', icon: AppIcons.wallet),
                ),
                const SizedBox(height: 4),
                SwitchRow(
                  title: 'Proposer le paiement à la réception',
                  subtitle: 'Selon les vendeurs',
                  titleWeight: FontWeight.w700,
                  minHeight: 52,
                  value: _cashOnDelivery,
                  onChanged: (v) => setState(() => _cashOnDelivery = v),
                ),
                if (isSeller) ...[
                  const SizedBox(height: 22),
                  const GroupLabel('Pour recevoir mes ventes', padding: EdgeInsets.zero),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.pomme900, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prochain versement · ${payout == null ? '…' : FrenchDates.weekdays[payout.nextDate.weekday - 1]}',
                                    style: AppTypography.body(size: 13, color: AppColors.pommeLight),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    payout == null ? '—' : formatAriary(payout.nextAmount),
                                    style: AppTypography.display(size: 26, weight: FontWeight.w700, color: AppColors.pomme50),
                                  ),
                                ],
                              ),
                            ),
                            const IconTile(
                              icon: AppIcons.wallet,
                              background: Color(0x2EB2DA6A),
                              foreground: AppColors.pommeLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: const Color(0x26F4FAE8)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Versé sur ${payout?.destination ?? 'MVola'}',
                                style: AppTypography.body(size: 14, color: AppColors.pomme50),
                              ),
                            ),
                            AppTextLink(
                              label: 'Modifier',
                              color: AppColors.pommeLight,
                              onTap: () => showAppToast(context, 'Choisissez le compte qui reçoit vos ventes', icon: AppIcons.wallet),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: AppIcons.receipt,
                        iconColor: AppColors.pomme700,
                        title: 'Historique des versements',
                        minHeight: 52,
                        onTap: () => context.push(AppRoutes.salesHistory),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(AppIcons.lock, size: 18, color: AppColors.pomme700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Vos numéros sont chiffrés. In my bush ne stocke jamais votre code secret Mobile Money.',
                        style: AppTypography.body(size: 13, color: AppColors.body, height: 19 / 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
