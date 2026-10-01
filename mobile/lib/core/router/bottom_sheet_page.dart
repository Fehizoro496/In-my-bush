import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// go_router page that presents its child as a modal bottom sheet
/// (used by `/filtres`).
class BottomSheetPage<T> extends Page<T> {
  const BottomSheetPage({required this.child, super.key, super.name});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return ModalBottomSheetRoute<T>(
      settings: this,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      modalBarrierColor: AppColors.scrim,
      builder: (context) => child,
    );
  }
}
