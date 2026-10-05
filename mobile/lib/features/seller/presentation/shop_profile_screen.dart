import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../data/models/models.dart';
import '../data/seller_repository.dart';
import '../seller_providers.dart';

/// M-Sell-ShopProfile — edit the seller's shop info (name, description,
/// pickup schedule, delivery zones, pause toggle).
class ShopProfileScreen extends ConsumerStatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  ConsumerState<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends ConsumerState<ShopProfileScreen> {
  bool _saving = false;

  static const _allDays = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  Future<void> _togglePause(ShopSettings settings) async {
    setState(() => _saving = true);
    try {
      await ref.read(sellerRepositoryProvider).saveShopSettings(settings.copyWith(paused: !settings.paused));
      ref.invalidate(shopSettingsProvider);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(shopSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Ma boutique',
              actions: [
                if (_saving) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pomme700)),
              ],
            ),
            Expanded(
              child: AsyncValueView<ShopSettings>(
                value: settings,
                onRetry: () => ref.invalidate(shopSettingsProvider),
                loading: () => const Center(child: Skeleton(height: 400, radius: 20)),
                data: (shop) => ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    // Shop status banner
                    AppCard(
                      radius: 16,
                      borderColor: shop.paused ? AppColors.orange300 : AppColors.pomme200,
                      color: shop.paused ? AppColors.orange50 : AppColors.pomme50,
                      child: Row(
                        children: [
                          Icon(
                            shop.paused ? LucideIcons.pause : AppIcons.check,
                            size: 20,
                            color: shop.paused ? AppColors.orange700 : AppColors.pomme700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              shop.paused ? 'Boutique en pause' : 'Boutique en ligne',
                              style: AppTypography.body(
                                size: 14,
                                weight: FontWeight.w700,
                                color: shop.paused ? AppColors.orange700 : AppColors.pomme700,
                              ),
                            ),
                          ),
                          AppTextLink(
                            label: shop.paused ? 'Reprendre' : 'Mettre en pause',
                            fontSize: 13,
                            onTap: () => _togglePause(shop),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Shop info section
                    const SectionHeader(title: 'Informations', titleSize: 18),
                    const SizedBox(height: 10),
                    _InfoRow(label: 'Nom', value: shop.name),
                    _InfoRow(label: 'Description', value: shop.description),
                    _InfoRow(label: 'Localisation', value: shop.location),
                    const SizedBox(height: 20),

                    // Pickup section
                    const SectionHeader(title: 'Retrait en boutique', titleSize: 18),
                    const SizedBox(height: 10),
                    AppCard(
                      radius: 14,
                      borderColor: AppColors.line,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jours de retrait', style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final day in _allDays)
                                AppChoiceChip(
                                  label: day,
                                  tone: ChipTone.green,
                                  selected: shop.pickupDays.contains(day),
                                  height: 34,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  onTap: () {},
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Horaires', style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text('${shop.pickupFrom} – ${shop.pickupTo}',
                              style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Delivery section
                    const SectionHeader(title: 'Livraison', titleSize: 18),
                    const SizedBox(height: 10),
                    AppCard(
                      radius: 14,
                      borderColor: AppColors.line,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(label: 'Frais de livraison', value: formatAriary(shop.deliveryFee), inCard: true),
                          const SizedBox(height: 10),
                          Text('Zones desservies', style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final zone in shop.zones)
                                AppTag(label: zone, background: AppColors.sand, foreground: AppColors.body, radius: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Edit button
                    AppButton(
                      label: 'Modifier les informations',
                      icon: AppIcons.edit,
                      variant: AppButtonVariant.outline,
                      expand: true,
                      onPressed: () {
                        // TODO: open edit sheet
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.inCard = false});

  final String label;
  final String value;
  final bool inCard;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: inCard ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '–' : value,
            style: AppTypography.body(size: 15, color: value.isEmpty ? AppColors.disabled : AppColors.ink),
          ),
        ],
      ),
    );
  }
}
