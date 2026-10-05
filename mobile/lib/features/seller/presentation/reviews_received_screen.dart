import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../../catalog/data/models/models.dart' show Review;
import '../seller_providers.dart';

/// M-Sell-Reviews — reviews received by the seller, with inline reply.
class ReviewsReceivedScreen extends ConsumerStatefulWidget {
  const ReviewsReceivedScreen({super.key});

  @override
  ConsumerState<ReviewsReceivedScreen> createState() => _ReviewsReceivedScreenState();
}

class _ReviewsReceivedScreenState extends ConsumerState<ReviewsReceivedScreen> {
  String? _replyingTo;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(Review review) async {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    await ref.read(sellerReviewsProvider.notifier).reply(review, text);
    _replyController.clear();
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ref.watch(sellerReviewsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Avis reçus'),
            Expanded(
              child: AsyncValueView<List<Review>>(
                value: reviews,
                onRetry: () => ref.invalidate(sellerReviewsProvider),
                loading: () => ListView(
                  padding: const EdgeInsets.all(16),
                  children: List.generate(3, (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Skeleton(height: 120, radius: 16),
                  )),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        icon: AppIcons.starOutline,
                        title: 'Aucun avis',
                        message: 'Les avis de vos clients apparaîtront ici.',
                      ),
                    );
                  }

                  // Compute average
                  final avg = list.fold<int>(0, (s, r) => s + r.rating) / list.length;

                  return RefreshIndicator(
                    color: AppColors.pomme700,
                    onRefresh: () async {
                      ref.invalidate(sellerReviewsProvider);
                      await ref.read(sellerReviewsProvider.future);
                    },
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      children: [
                        // Summary header
                        AppCard(
                          radius: 16,
                          borderColor: AppColors.line,
                          child: Row(
                            children: [
                              Text(
                                formatRating(avg),
                                style: AppTypography.display(size: 36, weight: FontWeight.w800, color: AppColors.pomme700),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingStars(rating: avg, size: 20),
                                    const SizedBox(height: 2),
                                    Text(
                                      plural(list.length, 'avis'),
                                      style: AppTypography.body(size: 13, color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Review list
                        for (final review in list) ...[
                          _ReviewCard(
                            review: review,
                            isReplying: _replyingTo == review.id,
                            replyController: _replyController,
                            onTapReply: () {
                              setState(() {
                                _replyingTo = _replyingTo == review.id ? null : review.id;
                                _replyController.clear();
                              });
                            },
                            onSendReply: () => _sendReply(review),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.isReplying,
    required this.replyController,
    required this.onTapReply,
    required this.onSendReply,
  });

  final Review review;
  final bool isReplying;
  final TextEditingController replyController;
  final VoidCallback onTapReply;
  final VoidCallback onSendReply;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      borderColor: AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, name, product, date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(initials: review.author.initials, color: review.author.colorValue, size: 36, fontSize: 13),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review.authorName, style: AppTypography.body(size: 14, weight: FontWeight.w700)),
                        const Spacer(),
                        Text(FrenchDates.ago(review.createdAt), style: AppTypography.body(size: 12, color: AppColors.disabled)),
                      ],
                    ),
                    if (review.productName.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(review.productName, style: AppTypography.body(size: 12, color: AppColors.muted)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stars + comment
          RatingStars(rating: review.rating.toDouble(), size: 16),
          const SizedBox(height: 6),
          Text(review.comment, style: AppTypography.body(size: 14, color: AppColors.body, height: 20 / 14)),

          // Seller reply (if exists)
          if (review.sellerReply != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pomme50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.reply, size: 16, color: AppColors.pomme700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.sellerReply!,
                      style: AppTypography.body(size: 13, color: AppColors.pomme800, height: 18 / 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Reply button or reply input
          if (review.sellerReply == null) ...[
            const SizedBox(height: 10),
            if (!isReplying)
              Align(
                alignment: Alignment.centerRight,
                child: AppTextLink(
                  label: 'Répondre',
                  icon: LucideIcons.reply,
                  fontSize: 13,
                  onTap: onTapReply,
                ),
              )
            else ...[
              AppTextField(
                controller: replyController,
                hint: 'Votre réponse…',
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppTextLink(label: 'Annuler', fontSize: 13, onTap: onTapReply),
                  const SizedBox(width: 8),
                  AppButton(label: 'Envoyer', size: AppButtonSize.small, onPressed: onSendReply),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
