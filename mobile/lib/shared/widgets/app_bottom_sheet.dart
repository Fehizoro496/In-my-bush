import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';
import 'buttons.dart';

/// Grey drag handle (40×5).
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        decoration: BoxDecoration(color: AppColors.switchOff, borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

/// Bottom sheet scaffold: handle, header (close · title · action), scrollable
/// body and sticky footer (Filtres, Tri…).
class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
    this.actionLabel,
    this.onAction,
    this.footer,
    this.expand = true,
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 18, 16, 8),
  });

  final String title;
  final Widget child;
  final VoidCallback? onClose;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? footer;

  /// Take the available height (minus 64px top gap) instead of wrapping.
  final bool expand;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewPadding.bottom;
    final body = SingleChildScrollView(padding: bodyPadding, child: child);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height - 64),
      height: expand ? media.size.height - 64 : null,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x331F2318), blurRadius: 40, offset: Offset(0, -12))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const SheetHandle(),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 8, 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                children: [
                  AppIconButton(
                    icon: AppIcons.close,
                    iconSize: 22,
                    semanticLabel: 'Fermer',
                    onPressed: onClose ?? () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.display(size: 20, weight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: actionLabel == null
                          ? const SizedBox(width: 44)
                          : AppTextLink(label: actionLabel!, onTap: onAction, minHeight: 44),
                    ),
                  ),
                ],
              ),
            ),
            if (expand) Expanded(child: body) else Flexible(child: body),
            if (footer != null)
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + (bottomInset > 16 ? bottomInset : 16)),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens a modal sheet with the app's barrier color and transparent
/// background (the child draws its own rounded surface).
Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: builder,
  );
}

/// Confirmation sheet (delete product…): icon tile, title, text, buttons.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Annuler',
    this.icon = AppIcons.trash,
    this.destructive = true,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool destructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 30 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: destructive ? AppColors.dangerSoft : AppColors.pomme100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: destructive ? AppColors.dangerFg : AppColors.pomme700),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTypography.display(size: 22, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(message, style: AppTypography.body(size: 15, color: AppColors.body, height: 22 / 15)),
          const SizedBox(height: 14),
          AppButton(
            label: confirmLabel,
            expand: true,
            variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
            onPressed: onConfirm,
          ),
          const SizedBox(height: 14),
          AppButton(
            label: cancelLabel,
            expand: true,
            variant: AppButtonVariant.outline,
            onPressed: onCancel ?? () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}

/// Simple list of options in a sheet (sort order, unit, category picker).
Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T option) labelOf,
  T? selected,
}) {
  return showAppSheet<T>(
    context,
    (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(8, 10, 8, 16 + MediaQuery.of(sheetContext).viewPadding.bottom),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
              child: Text(title, style: AppTypography.display(size: 20, weight: FontWeight.w700)),
            ),
            for (final option in options)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.of(sheetContext).pop(option),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: option == selected ? AppColors.pomme100 : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labelOf(option),
                          style: AppTypography.body(
                            size: 15,
                            weight: option == selected ? FontWeight.w700 : FontWeight.w400,
                            color: option == selected ? AppColors.pomme800 : AppColors.ink,
                          ),
                        ),
                      ),
                      if (option == selected) const Icon(AppIcons.check, size: 18, color: AppColors.pomme800),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
