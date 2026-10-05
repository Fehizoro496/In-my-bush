import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../models/avatar_look.dart';
import '../models/visual.dart';
import 'app_icons.dart';
import 'avatar.dart';
import 'badges.dart';

/// Shop card (SellerCard mockup): cover, avatar, "Vérifié", name, place,
/// rating/products/since, tags and "Voir la boutique".
class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    required this.name,
    required this.location,
    required this.avatar,
    required this.cover,
    required this.rating,
    required this.reviewCount,
    required this.productCount,
    required this.since,
    this.tags = const [],
    this.verified = true,
    this.onTap,
  });

  final String name;
  final String location;
  final AvatarLook avatar;
  final Visual cover;
  final double rating;
  final int reviewCount;
  final int productCount;
  final String since;
  final List<String> tags;
  final bool verified;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 106,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 76,
                  child: Container(
                    color: cover.tintColor,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 10, top: 8),
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        'PHOTO · EXPLOITATION',
                        style: AppTypography.body(
                          size: 10,
                          weight: FontWeight.w700,
                          color: cover.inkColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x1F1F2318), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: AppAvatar(
                      initials: avatar.initials,
                      color: avatar.colorValue,
                      size: 54,
                      fontSize: 20,
                      display: true,
                    ),
                  ),
                ),
                if (verified)
                  const Positioned(
                    right: 16,
                    bottom: 0,
                    child: AppTag(label: 'Vérifié', icon: AppIcons.shield, fontSize: 11),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(name, style: AppTypography.display(size: 18, weight: FontWeight.w700, letterSpacing: -0.18)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(AppIcons.pin, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(child: Text(location, style: AppTypography.body(size: 13, color: AppColors.muted))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(AppIcons.star, size: 14, color: AppColors.orange500),
                          const SizedBox(width: 4),
                          Text(formatRating(rating), style: AppTypography.body(size: 13, weight: FontWeight.w700)),
                          Text(' ($reviewCount)', style: AppTypography.body(size: 13, color: AppColors.body)),
                        ],
                      ),
                      Text('$productCount produits', style: AppTypography.body(size: 13, color: AppColors.body)),
                      Text('Depuis $since', style: AppTypography.body(size: 13, color: AppColors.body)),
                    ],
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in tags)
                          AppTag(
                            label: tag,
                            background: AppColors.sand,
                            foreground: AppColors.body,
                            fontWeight: FontWeight.w600,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: Material(
                      color: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.pomme300, width: 1.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Voir la boutique', style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.pomme800)),
                            const SizedBox(width: 6),
                            const Icon(AppIcons.arrowRight, size: 16, color: AppColors.pomme800),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }
}

/// Compact producer card (Home "Producteurs populaires", 148px wide).
class SellerMiniCard extends StatelessWidget {
  const SellerMiniCard({
    super.key,
    required this.name,
    required this.location,
    required this.avatar,
    required this.ringColor,
    required this.rating,
    required this.productCount,
    this.onTap,
  });

  final String name;
  final String location;
  final AvatarLook avatar;
  final Color ringColor;
  final double rating;
  final int productCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 5),
                AppAvatar(
                  initials: avatar.initials,
                  color: avatar.colorValue,
                  size: 60,
                  fontSize: 20,
                  display: true,
                  ringColor: ringColor,
                ),
                const SizedBox(height: 13),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppTypography.body(size: 14, weight: FontWeight.w700, height: 18 / 14),
                ),
                const SizedBox(height: 8),
                Text(location, style: AppTypography.body(size: 12, color: AppColors.muted)),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(AppIcons.star, size: 13, color: AppColors.orange500),
                    const SizedBox(width: 4),
                    Text(formatRating(rating), style: AppTypography.body(size: 12, weight: FontWeight.w700)),
                    Text(' · $productCount produits', style: AppTypography.body(size: 12, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
