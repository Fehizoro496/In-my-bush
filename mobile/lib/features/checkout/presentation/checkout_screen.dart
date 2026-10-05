import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../account/data/account_repository.dart';
import '../../account/data/models/models.dart';
import '../../auth/auth_controller.dart';
import '../../cart/cart_providers.dart';
import '../../orders/data/models/models.dart';
import '../../orders/data/orders_repository.dart';
import '../data/checkout_repository.dart';

enum _PayChoice { mobileMoney, card, cash }

/// M-Checkout — address, delivery mode + slot, payment.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const _slots = ['Demain · 8h–12h', 'Demain · 14h–18h', 'Jeudi · 8h–12h'];

  DeliveryMode _mode = DeliveryMode.home;
  String _slot = _slots.first;
  _PayChoice _pay = _PayChoice.mobileMoney;
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  PaymentMethod get _method {
    switch (_pay) {
      case _PayChoice.mobileMoney:
        return PaymentMethod.mvola;
      case _PayChoice.card:
        return PaymentMethod.card;
      case _PayChoice.cash:
        return PaymentMethod.cashOnDelivery;
    }
  }

  Future<void> _submit(Address? address) async {
    final cart = ref.read(cartControllerProvider).valueOrNull;
    if (cart == null || cart.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final result = await ref.read(checkoutRepositoryProvider).checkout(
            CheckoutRequest(
              addressId: address?.id ?? '',
              deliveryMode: _mode,
              slot: _slot.replaceAll(' · ', ' '),
              paymentMethod: _method,
              phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
              promoCode: cart.promoCode,
            ),
            cart,
          );
      ref.read(lastCheckoutProvider.notifier).state = result;
      ref.invalidate(purchasesProvider);
      await ref.read(cartControllerProvider.notifier).clear();
      if (mounted) context.go(AppRoutes.confirmation);
    } on ApiException catch (e) {
      if (mounted) showAppToast(context, e.message, icon: AppIcons.alert);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider).valueOrNull;
    final addresses = ref.watch(addressesProvider).valueOrNull ?? const <Address>[];
    final user = ref.watch(currentUserProvider);
    Address? address;
    for (final a in addresses) {
      if (a.isDefault) address = a;
    }
    address ??= addresses.isEmpty ? null : addresses.first;

    final shipping = _mode == DeliveryMode.home ? (cart?.deliveryFee ?? 0) : 0;
    final discount = cart?.discount ?? 0;
    final total = (cart?.subtotal ?? 0) + shipping - discount;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppTopBar(
            title: 'Livraison & paiement',
            fallback: AppRoutes.cart,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 14),
            bottom: StepProgressBar(
              labels: ['Panier', 'Livraison', 'Paiement', 'Confirmation'],
              filledCount: 2,
              activeIndex: 1,
              partialIndex: 2,
              checkCompleted: true,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                SubTitle(
                  'Adresse de livraison',
                  trailing: AppTextLink(label: 'Modifier', onTap: () => context.push(AppRoutes.addresses)),
                ),
                const SizedBox(height: 10),
                if (address != null)
                  AppCard(
                    radius: 16,
                    borderColor: AppColors.pomme500,
                    borderWidth: 1.5,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconTile(icon: AppIcons.byKey(address.icon)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${address.label} · ${address.recipient}', style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(address.fullLine, style: AppTypography.body(size: 14, color: AppColors.body, height: 20 / 14)),
                              Text(user?.maskedPhone ?? address.phone, style: AppTypography.body(size: 14, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  AppButton(
                    label: 'Ajouter une adresse',
                    icon: AppIcons.plus,
                    variant: AppButtonVariant.dashed,
                    expand: true,
                    onPressed: () => context.push(AppRoutes.addresses),
                  ),
                const SizedBox(height: 22),
                const SubTitle('Mode de réception'),
                const SizedBox(height: 10),
                RadioCard(
                  selected: _mode == DeliveryMode.home,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  title: DeliveryMode.home.label,
                  subtitle: 'Chaque vendeur livre sa partie · ${plural(cart?.shopCount ?? 0, 'livraison')}',
                  trailing: Text(formatAriary(cart?.deliveryFee ?? 0), style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                  onTap: () => setState(() => _mode = DeliveryMode.home),
                ),
                const SizedBox(height: 10),
                RadioCard(
                  selected: _mode == DeliveryMode.pickup,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  title: DeliveryMode.pickup.label,
                  subtitle: 'Ambohimanga (22 km) · Antsirabe (170 km)',
                  trailing: Text('Gratuit', style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.pomme700)),
                  onTap: () => setState(() => _mode = DeliveryMode.pickup),
                ),
                const SizedBox(height: 14),
                Text('Créneau', style: AppTypography.body(size: 13, weight: FontWeight.w700, color: AppColors.body)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in _slots)
                      AppChoiceChip(
                        label: s,
                        radius: 10,
                        fontSize: 13,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        selected: _slot == s,
                        onTap: () => setState(() => _slot = s),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                const SubTitle('Paiement'),
                const SizedBox(height: 10),
                RadioCard(
                  selected: _pay == _PayChoice.mobileMoney,
                  title: 'Mobile Money',
                  subtitle: 'MVola · Orange Money · Airtel Money',
                  leading: const IconTile(icon: AppIcons.wallet, background: AppColors.sand, foreground: AppColors.ink, size: 36, radius: 10, iconSize: 18),
                  onTap: () => setState(() => _pay = _PayChoice.mobileMoney),
                  expanded: AppTextField(
                    label: 'Numéro Mobile Money',
                    labelSize: 13,
                    hint: '+261 34 00 000 00',
                    controller: _phone,
                    height: 46,
                    keyboardType: TextInputType.phone,
                    helperText: 'Vous recevrez une demande de validation sur votre téléphone.',
                  ),
                ),
                const SizedBox(height: 10),
                RadioCard(
                  selected: _pay == _PayChoice.card,
                  title: 'Carte bancaire',
                  subtitle: 'Visa, Mastercard',
                  leading: const IconTile(icon: AppIcons.card, background: AppColors.sand, foreground: AppColors.ink, size: 36, radius: 10, iconSize: 18),
                  onTap: () => setState(() => _pay = _PayChoice.card),
                ),
                const SizedBox(height: 10),
                RadioCard(
                  selected: _pay == _PayChoice.cash,
                  title: 'Paiement à la réception',
                  subtitle: 'Espèces, montant exact apprécié',
                  leading: const IconTile(icon: AppIcons.package, background: AppColors.sand, foreground: AppColors.ink, size: 36, radius: 10, iconSize: 18),
                  onTap: () => setState(() => _pay = _PayChoice.cash),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      SummaryRow(
                        size: 14,
                        label: '${plural(cart?.unitCount ?? 0, 'article')} · ${plural(cart?.shopCount ?? 0, 'vendeur')}',
                        value: formatAriary(cart?.subtotal ?? 0),
                      ),
                      const SizedBox(height: 8),
                      SummaryRow(size: 14, label: 'Livraison', value: shipping == 0 ? 'Gratuit' : formatAriary(shipping)),
                      if (discount > 0) ...[
                        const SizedBox(height: 8),
                        SummaryRow(
                          size: 14,
                          label: 'Réduction ${cart?.promoCode ?? ''}',
                          value: formatAriary(-discount),
                          color: AppColors.orange700,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text.rich(
                  TextSpan(
                    style: AppTypography.body(size: 12, color: AppColors.muted, height: 18 / 12),
                    children: [
                      const TextSpan(text: 'En confirmant, vous acceptez les '),
                      TextSpan(
                        text: 'conditions générales de vente',
                        style: AppTypography.body(size: 12, color: AppColors.pomme700, decoration: TextDecoration.underline),
                      ),
                      const TextSpan(text: '. Chaque vendeur prépare sa partie de la commande.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: AppButton(
              label: 'Payer ${formatAriary(total)}',
              icon: AppIcons.lock,
              height: 54,
              expand: true,
              loading: _submitting,
              onPressed: cart == null || cart.isEmpty ? null : () => _submit(address),
            ),
          ),
        ],
      ),
    );
  }
}
