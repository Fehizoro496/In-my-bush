import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../data/notifications_repository.dart';

enum _Filter {
  all('Tout'),
  purchases('Achats'),
  sales('Ventes'),
  promos('Promos'),
  messages('Messages');

  const _Filter(this.label);

  final String label;

  bool matches(AppNotification n) {
    switch (this) {
      case _Filter.all:
        return true;
      case _Filter.purchases:
        return n.context == NotificationContext.purchase && n.type != NotificationType.message;
      case _Filter.sales:
        return n.context == NotificationContext.sale;
      case _Filter.promos:
        return n.type == NotificationType.promo;
      case _Filter.messages:
        return n.type == NotificationType.message;
    }
  }
}

/// M-Notifications — purchase / sale / promo notifications grouped by day.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Notifications',
            leading: TopBarLeading.none,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            bottomGap: 10,
            actions: [AppTextLink(label: 'Tout lire', fontSize: 13, minHeight: 40, onTap: controller.markAllRead)],
            bottom: ChipScroller(
              padding: EdgeInsets.zero,
              children: [
                for (final f in _Filter.values)
                  AppChoiceChip(
                    label: f.label,
                    tone: ChipTone.ink,
                    height: 36,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    selected: _filter == f,
                    onTap: () => setState(() => _filter = f),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<AppNotification>>(
              value: notifications,
              onRetry: () => ref.invalidate(notificationsControllerProvider),
              loading: () => const ListSkeleton(count: 5, circle: false, leadingSize: 42),
              data: (all) {
                final list = all.where(_filter.matches).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                if (list.isEmpty) {
                  return const EmptyState(
                    icon: AppIcons.bell,
                    title: 'Rien de neuf',
                    message: 'Vos notifications de commandes, ventes et promotions apparaîtront ici.',
                  );
                }
                final groups = <String, List<AppNotification>>{};
                for (final n in list) {
                  final key = FrenchDates.group(n.createdAt) == 'Aujourd’hui' ? 'Aujourd’hui' : 'Cette semaine';
                  groups.putIfAbsent(key, () => []).add(n);
                }
                return RefreshIndicator(
                  color: AppColors.pomme700,
                  onRefresh: () async {
                    ref.invalidate(notificationsControllerProvider);
                    await ref.read(notificationsControllerProvider.future);
                  },
                  child: ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    children: [
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          child: Text(entry.key.toUpperCase(), style: AppTypography.overline()),
                        ),
                        for (final n in entry.value)
                          _NotificationTile(
                            notification: n,
                            onTap: () {
                              controller.markRead(n);
                              if (n.link != null) context.push(n.link!);
                            },
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return Material(
      color: n.unread ? AppColors.surface : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTile(
                icon: AppIcons.byKey(n.type.icon),
                background: hexColor(n.type.background),
                foreground: hexColor(n.type.foreground),
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(n.title, style: AppTypography.body(size: 14, weight: FontWeight.w700))),
                        const SizedBox(width: 8),
                        Text(FrenchDates.relativeShort(n.createdAt), style: AppTypography.body(size: 12, color: AppColors.muted)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(n.body, style: AppTypography.body(size: 13, color: AppColors.body, height: 18 / 13)),
                    if (n.cta != null) ...[
                      const SizedBox(height: 8),
                      AppButton(
                        label: n.cta!,
                        size: AppButtonSize.small,
                        height: 34,
                        onPressed: onTap,
                      ),
                    ],
                  ],
                ),
              ),
              if (n.unread) ...[
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(color: AppColors.orange500, shape: BoxShape.circle),
                  child: Semantics(label: 'Non lue'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
