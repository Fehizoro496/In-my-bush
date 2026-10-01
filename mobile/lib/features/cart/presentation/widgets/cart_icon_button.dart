import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../cart_providers.dart';

/// Cart icon with the orange count badge (top bar of Home and Settings).
class CartIconButton extends ConsumerWidget {
  const CartIconButton({super.key, this.badgeBorderColor = AppColors.bg});

  final Color badgeBorderColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return AppIconButton(
      icon: AppIcons.cart,
      iconSize: 22,
      badgeCount: count,
      badgeBorderColor: badgeBorderColor,
      semanticLabel: 'Panier, $count article${count > 1 ? 's' : ''}',
      onPressed: () => context.push(AppRoutes.cart),
    );
  }
}
