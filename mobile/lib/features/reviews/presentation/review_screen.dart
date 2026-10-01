import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../auth/auth_controller.dart';
import '../data/reviews_repository.dart';

/// M-Review — review of the products of a delivered order (one at a time).
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  static const _labels = ['', 'Décevant', 'Moyen', 'Correct', 'Très bien', 'Excellent'];
  static const _tagOptions = [
    'Frais',
    'Parfum agréable',
    'Bien emballé',
    'Livré à l’heure',
    'Conforme à la photo',
    'Bon rapport qualité-prix',
  ];

  int _index = 0;
  int _rating = 4;
  Set<String> _tags = {'Parfum agréable', 'Bien emballé'};
  int _communication = 5;
  int _preparation = 4;
  bool _showName = true;
  bool _sending = false;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _next(int total) {
    if (_index + 1 >= total) {
      popOrGo(context, AppRoutes.orders);
      return;
    }
    setState(() {
      _index++;
      _rating = 5;
      _tags = {};
      _comment.clear();
    });
  }

  Future<void> _publish(ReviewTarget target, int total) async {
    setState(() => _sending = true);
    await ref.read(reviewsRepositoryProvider).submit(
          target.orderId,
          ReviewDraft(
            productId: target.productId,
            rating: _rating,
            comment: _comment.text.trim(),
            tags: _tags,
            communicationRating: _communication,
            preparationRating: _preparation,
            showName: _showName,
          ),
        );
    if (!mounted) return;
    setState(() => _sending = false);
    showAppToast(context, 'Merci pour votre avis !', icon: AppIcons.star);
    _next(total);
  }

  @override
  Widget build(BuildContext context) {
    final targets = ref.watch(reviewTargetsProvider(widget.orderId));
    final user = ref.watch(currentUserProvider);
    final publicName = user == null ? 'Client' : '${user.firstName} ${user.lastName.isEmpty ? '' : '${user.lastName[0]}.'}'.trim();

    return Scaffold(
      body: targets.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Column(
          children: [
            const AppTopBar(title: 'Votre avis', leading: TopBarLeading.close, fallback: AppRoutes.orders),
            Expanded(child: ErrorState(error: e)),
          ],
        ),
        data: (list) {
          if (list.isEmpty) {
            return const Column(
              children: [
                AppTopBar(title: 'Votre avis', leading: TopBarLeading.close, fallback: AppRoutes.orders),
                Expanded(child: EmptyState(icon: AppIcons.starOutline, title: 'Aucun produit à évaluer')),
              ],
            );
          }
          final target = list[_index < list.length ? _index : list.length - 1];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTopBar(
                title: 'Votre avis',
                leading: TopBarLeading.close,
                fallback: AppRoutes.orders,
                actions: [
                  Text('${_index + 1} / ${list.length}', style: AppTypography.body(size: 13, color: AppColors.muted)),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  children: [
                    Row(
                      children: [
                        ProductThumb(visual: target.visual, size: 64, radius: 14, iconSize: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(target.productName, style: AppTypography.body(size: 16, weight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(
                                '${target.shopName}${target.deliveredAt != null ? ' · livré le ${FrenchDates.dayMonth(target.deliveredAt!)}' : ''}',
                                style: AppTypography.body(size: 13, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Comment trouvez-vous ce produit ?',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 16, weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Center(child: StarRatingInput(value: _rating, onChanged: (v) => setState(() => _rating = v))),
                    const SizedBox(height: 10),
                    Text(
                      _labels[_rating],
                      textAlign: TextAlign.center,
                      style: AppTypography.body(size: 15, weight: FontWeight.w700, color: AppColors.orange700),
                    ),
                    const SizedBox(height: 22),
                    Text('Ce qui vous a plu', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in _tagOptions)
                          AppChoiceChip(
                            label: t,
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            selected: _tags.contains(t),
                            onTap: () => setState(() {
                              _tags = Set<String>.of(_tags);
                              if (!_tags.remove(t)) _tags.add(t);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AppTextField(
                      label: 'Votre commentaire',
                      hint: 'Goût, fraîcheur, emballage… Votre avis aide les autres acheteurs et le producteur.',
                      controller: _comment,
                      maxLines: 5,
                      minLines: 5,
                      maxLength: 500,
                      showCounter: true,
                      radius: 12,
                    ),
                    const SizedBox(height: 22),
                    Text('Photos (facultatif)', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(color: target.visual.tintColor, borderRadius: BorderRadius.circular(12)),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 76,
                          height: 76,
                          child: DashedBorderBox(
                            background: AppColors.pomme50,
                            radius: 12,
                            onTap: () => showAppToast(context, 'Choisissez une photo', icon: AppIcons.camera),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(AppIcons.camera, size: 20, color: AppColors.pomme800),
                                  const SizedBox(height: 4),
                                  Text('Ajouter', style: AppTypography.body(size: 11, weight: FontWeight.w700, color: AppColors.pomme800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AppCard(
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Et le vendeur ?', style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          _SellerRating(
                            label: 'Communication',
                            value: _communication,
                            onChanged: (v) => setState(() => _communication = v),
                          ),
                          const SizedBox(height: 10),
                          _SellerRating(
                            label: 'Délai de préparation',
                            value: _preparation,
                            onChanged: (v) => setState(() => _preparation = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    SwitchRow(
                      title: 'Publier sous « $publicName »',
                      minHeight: 44,
                      value: _showName,
                      onChanged: (v) => setState(() => _showName = v),
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: Row(
                  children: [
                    AppButton(
                      label: 'Plus tard',
                      variant: AppButtonVariant.ghost,
                      foregroundColor: AppColors.body,
                      fontSize: 15,
                      onPressed: () => _next(list.length),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Publier l’avis',
                        expand: true,
                        loading: _sending,
                        onPressed: () => _publish(target, list.length),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SellerRating extends StatelessWidget {
  const _SellerRating({required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: AppTypography.body(size: 14, color: AppColors.body))),
        StarRatingInput(value: value, onChanged: onChanged, starSize: 18, hitSize: 26),
      ],
    );
  }
}
