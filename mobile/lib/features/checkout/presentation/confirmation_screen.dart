import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../data/checkout_repository.dart';

/// M-Confirmation.
class ConfirmationScreen extends ConsumerWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastCheckoutProvider);
    final firstName = ref.watch(currentUserProvider)?.firstName ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                children: [
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(color: AppColors.pommeSelected, shape: BoxShape.circle),
                          ),
                          Positioned(
                            left: 0,
                            top: 14,
                            child: Transform.rotate(
                              angle: -30 * math.pi / 180,
                              child: const Icon(AppIcons.leaf, size: 28, color: AppColors.pomme600),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            bottom: 10,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(color: AppColors.orange500, shape: BoxShape.circle),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.6, end: 1),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: AppColors.pomme500,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Color(0x595C9120), blurRadius: 24, offset: Offset(0, 10))],
                              ),
                              child: const Icon(AppIcons.check, size: 36, color: AppColors.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    firstName.isEmpty ? 'C’est commandé !' : 'Merci $firstName, c’est commandé !',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(size: 28, weight: FontWeight.w800, letterSpacing: -0.56),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      result == null
                          ? 'Votre commande a bien été enregistrée.'
                          : 'Commande n° ${result.orderNumber} · ${formatAriary(result.total)} payés par '
                              '${result.paymentMethod.family}. Un reçu vous a été envoyé par SMS.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 15, color: AppColors.body, height: 22 / 15),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final d in result?.deliveries ?? const <CheckoutDelivery>[]) ...[
                    AppCard(
                      radius: 16,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              AppAvatar(initials: d.avatar.initials, color: d.avatar.colorValue, size: 32, fontSize: 12),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d.shopName, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                                    Text(d.itemsSummary, style: AppTypography.body(size: 12, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              StatusPill(label: d.when, tone: StatusTone.info),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const StepProgressBar(
                            labels: ['Confirmée', 'Préparation', 'En route', 'Livrée'],
                            filledCount: 1,
                            labelSize: 11,
                            gap: 4,
                            labelGap: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: [
                  AppButton(
                    label: 'Suivre ma commande',
                    expand: true,
                    onPressed: () => result?.firstOrderId == null
                        ? context.go(AppRoutes.orders)
                        : context.go(AppRoutes.order(result!.firstOrderId!)),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Continuer mes achats',
                    variant: AppButtonVariant.ghost,
                    expand: true,
                    onPressed: () => context.go(AppRoutes.home),
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
