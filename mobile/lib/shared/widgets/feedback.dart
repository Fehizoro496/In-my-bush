import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';
import 'buttons.dart';

/// Empty / zero-data state: icon disc, title, message and optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = AppIcons.leaf,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(color: AppColors.pomme100, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, size: 30, color: AppColors.pomme700),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.display(size: 20, weight: FontWeight.w700),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 15, color: AppColors.body, height: 22 / 15),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            AppButton(label: actionLabel!, onPressed: onAction, size: AppButtonSize.medium),
          ],
        ],
      ),
    );
  }
}

/// Error state with a retry button.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final apiError = error is ApiException ? error as ApiException : null;
    final offline = apiError?.title == 'Hors connexion';
    return EmptyState(
      icon: offline ? AppIcons.wifiOff : AppIcons.alert,
      title: apiError?.title ?? 'Oups, une erreur est survenue',
      message: apiError?.detail ?? 'Réessayez dans un instant.',
      actionLabel: onRetry == null ? null : 'Réessayer',
      onAction: onRetry,
    );
  }
}

/// Renders an [AsyncValue] with the standard loading / error states.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading?.call() ??
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
      error: (error, stack) => ErrorState(error: error, onRetry: onRetry),
    );
  }
}

/// Dark toast of the mockups ("Stock mis à jour · Annuler").
void showAppToast(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  IconData icon = AppIcons.check,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(color: AppColors.pomme500, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: AppColors.onPrimary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: AppTypography.body(size: 14, color: Colors.white)),
            ),
            if (actionLabel != null)
              GestureDetector(
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onAction?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Text(
                    actionLabel,
                    style: AppTypography.body(size: 14, weight: FontWeight.w700, color: AppColors.pommeLight),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
}
