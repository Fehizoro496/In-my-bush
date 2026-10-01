import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';
import 'buttons.dart';

enum TopBarLeading { back, close, none }

/// Pops the current route or, when there is nothing to pop (deep link),
/// goes to [fallback].
void popOrGo(BuildContext context, String fallback) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

/// 44px back / close button with the mockups' -10px left offset.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.fallback = '/',
    this.close = false,
    this.onPressed,
    this.semanticLabel,
  });

  final String fallback;
  final bool close;
  final VoidCallback? onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: close ? AppIcons.close : AppIcons.arrowLeft,
      iconSize: 22,
      semanticLabel: semanticLabel ?? (close ? 'Fermer' : 'Retour'),
      onPressed: onPressed ?? () => popOrGo(context, fallback),
    );
  }
}

/// White header with bottom border used by most pushed screens:
/// back arrow · title (+ subtitle) · actions, and an optional bottom slot
/// (tabs, search, progress).
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading = TopBarLeading.back,
    this.fallback = '/',
    this.onLeading,
    this.actions = const [],
    this.bottom,
    this.titleSize = 22,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 12),
    this.bottomGap = 12,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final TopBarLeading leading;
  final String fallback;
  final VoidCallback? onLeading;
  final List<Widget> actions;
  final Widget? bottom;
  final double titleSize;
  final EdgeInsets padding;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        leading == TopBarLeading.none ? padding.left : padding.left - 10,
        padding.top + top,
        padding.right,
        padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              children: [
                if (leading != TopBarLeading.none)
                  AppBackButton(
                    close: leading == TopBarLeading.close,
                    fallback: fallback,
                    onPressed: onLeading,
                  ),
                if (leading != TopBarLeading.none) const SizedBox(width: 4),
                Expanded(
                  child: titleWidget ??
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (title != null)
                            Text(
                              title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.display(
                                size: titleSize,
                                weight: FontWeight.w700,
                                letterSpacing: titleSize >= 28 ? -0.56 : 0,
                              ),
                            ),
                          if (subtitle != null)
                            Text(subtitle!, style: AppTypography.body(size: 12, color: AppColors.muted)),
                        ],
                      ),
                ),
                ...actions,
              ],
            ),
          ),
          if (bottom != null) ...[
            SizedBox(height: bottomGap),
            Padding(
              padding: EdgeInsets.only(left: leading == TopBarLeading.none ? 0 : 10),
              child: bottom,
            ),
          ],
        ],
      ),
    );
  }
}

/// Transparent page header with a big Bricolage title (Paramètres,
/// Catégories) and trailing actions.
class LargeTitleBar extends StatelessWidget {
  const LargeTitleBar({super.key, required this.title, this.actions = const [], this.leading});

  final String title;
  final List<Widget> actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: [
          if (leading != null) leading!,
          Expanded(child: Text(title, style: AppTypography.pageTitle)),
          ...actions,
        ],
      ),
    );
  }
}

/// Sticky white bottom bar holding the screen's main actions.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.shadow = false, this.padding});

  final Widget child;
  final bool shadow;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    final base = padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 12);
    return Container(
      padding: base.copyWith(bottom: base.bottom + (bottom > 14 ? bottom : 14)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: shadow
            ? const [BoxShadow(color: Color(0x0F1F2318), blurRadius: 20, offset: Offset(0, -6))]
            : null,
      ),
      child: child,
    );
  }
}
