import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';

/// "In my bush." logo: pomme-green 38px rounded square with a sprout +
/// wordmark with an orange dot. [dark] is for dark backgrounds (login).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.dark = false, this.scale = 1});

  final bool dark;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? const Color(0xFFF3F7EA) : AppColors.ink;
    return Semantics(
      label: 'In my bush',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38 * scale,
            height: 38 * scale,
            decoration: BoxDecoration(
              color: AppColors.pomme500,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            alignment: Alignment.center,
            child: Icon(AppIcons.sprout, size: 24 * scale, color: AppColors.onPrimary),
          ),
          SizedBox(width: 10 * scale),
          ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                text: 'In my bush',
                children: [
                  TextSpan(
                    text: '.',
                    style: AppTypography.display(
                      size: 27 * scale,
                      weight: FontWeight.w800,
                      color: AppColors.orange500,
                      height: 1,
                    ),
                  ),
                ],
              ),
              style: AppTypography.display(
                size: 27 * scale,
                weight: FontWeight.w800,
                color: ink,
                height: 1,
                letterSpacing: -0.81 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
