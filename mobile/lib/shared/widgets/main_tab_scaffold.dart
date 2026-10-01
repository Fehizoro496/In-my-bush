import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'app_icons.dart';
import 'badges.dart';

/// Shell of the 5 tabs (StatefulShellRoute.indexedStack): Accueil ·
/// Messages · Vendre (raised) · Notifs · Paramètres.
class MainTabScaffold extends StatelessWidget {
  const MainTabScaffold({
    super.key,
    required this.navigationShell,
    this.messagesCount = 0,
    this.notificationsCount = 0,
  });

  final StatefulNavigationShell navigationShell;
  final int messagesCount;
  final int notificationsCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppTabBar(
        currentIndex: navigationShell.currentIndex,
        messagesCount: messagesCount,
        notificationsCount: notificationsCount,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

/// Bottom tab bar (MobileTabBar mockup). Index 2 is the raised "Vendre".
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.messagesCount = 0,
    this.notificationsCount = 0,
  });

  /// `-1` = no active tab.
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int messagesCount;
  final int notificationsCount;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final bottomPadding = bottomInset > 20 ? bottomInset : 20.0;
    return Container(
      height: AppSizes.mobileTabBar - 20 + bottomPadding,
      padding: EdgeInsets.fromLTRB(8, 6, 8, bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.tabBarBg,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [BoxShadow(color: Color(0x0A1F2318), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Accueil',
            icon: AppIcons.home,
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _TabItem(
            label: 'Messages',
            icon: AppIcons.message,
            active: currentIndex == 1,
            badge: messagesCount,
            semanticLabel: 'Messages, $messagesCount non lus',
            onTap: () => onTap(1),
          ),
          _SellTabItem(active: currentIndex == 2, onTap: () => onTap(2)),
          _TabItem(
            label: 'Notifs',
            icon: AppIcons.bell,
            active: currentIndex == 3,
            badge: notificationsCount,
            semanticLabel: 'Notifications, $notificationsCount non lues',
            onTap: () => onTap(3),
          ),
          _TabItem(
            label: 'Paramètres',
            icon: AppIcons.settings,
            active: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge = 0,
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final int badge;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.pomme700 : AppColors.muted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: semanticLabel ?? label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 32,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 24, color: color),
                  if (badge > 0)
                    Positioned(
                      top: -5,
                      right: -9,
                      child: CountBadge(count: badge, borderColor: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: AppTypography.body(
                  size: 11,
                  weight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellTabItem extends StatelessWidget {
  const _SellTabItem({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: 'Vendre',
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                top: -22,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.pomme500,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: AppShadows.primaryGlow,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(AppIcons.plus, size: 26, color: AppColors.onPrimary),
                ),
              ),
              Positioned(
                bottom: 4,
                child: Text(
                  'Vendre',
                  style: AppTypography.body(
                    size: 11,
                    weight: FontWeight.w700,
                    color: active ? AppColors.pomme700 : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
