import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets.dart';
import '../data/messages_repository.dart';
import '../messages_providers.dart';

/// M-Messages — conversations split "Mes achats" / "Mes ventes".
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  MessageContext _context = MessageContext.purchase;
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider(_context));
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            title: 'Messages',
            titleSize: 28,
            leading: TopBarLeading.none,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            actions: [
              AppIconButton(
                icon: AppIcons.edit,
                semanticLabel: 'Nouveau message',
                onPressed: () => context.push(AppRoutes.search),
              ),
            ],
            bottom: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedSwitch<MessageContext>(
                  height: 40,
                  radius: 12,
                  fontSize: 14,
                  segments: [
                    SegmentItem(
                      value: MessageContext.purchase,
                      label: 'Mes achats',
                      count: ref.watch(unreadByContextProvider(MessageContext.purchase)),
                    ),
                    SegmentItem(
                      value: MessageContext.sale,
                      label: 'Mes ventes',
                      count: ref.watch(unreadByContextProvider(MessageContext.sale)),
                    ),
                  ],
                  selected: _context,
                  onChanged: (c) => setState(() => _context = c),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hint: 'Rechercher une conversation',
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 10),
                    child: Icon(AppIcons.search, size: 18, color: AppColors.muted),
                  ),
                  height: 44,
                  radius: 12,
                  fillColor: AppColors.bg,
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.pomme700,
              onRefresh: () async {
                ref.invalidate(conversationsProvider(_context));
                await ref.read(conversationsProvider(_context).future);
              },
              child: AsyncValueView<List<Conversation>>(
                value: conversations,
                onRetry: () => ref.invalidate(conversationsProvider(_context)),
                loading: () => const ListSkeleton(count: 4),
                data: (list) {
                  final needle = slugify(_filter);
                  final filtered = needle.isEmpty
                      ? list
                      : list.where((c) => slugify('${c.title} ${c.subject}').contains(needle)).toList();
                  if (filtered.isEmpty) {
                    return ListView(
                      children: const [
                        EmptyState(
                          icon: AppIcons.message,
                          title: 'Aucune conversation',
                          message: 'Vos échanges avec les producteurs et les clients apparaîtront ici.',
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ConversationTile(conversation: filtered[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final unread = c.unreadCount > 0;
    return Material(
      color: unread ? AppColors.surface : Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.chat(c.id)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAvatar(initials: c.avatar.initials, color: c.avatar.colorValue, size: 48, fontSize: 15, display: false, online: c.online),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(c.title, style: AppTypography.body(size: 15, weight: FontWeight.w700))),
                        const SizedBox(width: 8),
                        Text(
                          FrenchDates.relativeShort(c.lastMessageAt),
                          style: AppTypography.body(
                            size: 12,
                            weight: unread ? FontWeight.w700 : FontWeight.w500,
                            color: unread ? AppColors.pomme700 : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(AppIcons.byKey(c.subjectIcon), size: 12, color: AppColors.pomme700),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            c.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(size: 12, weight: FontWeight.w600, color: AppColors.pomme700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 14,
                              weight: unread ? FontWeight.w600 : FontWeight.w400,
                              color: unread ? AppColors.ink : AppColors.muted,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          CountBadge(
                            count: c.unreadCount,
                            size: 20,
                            background: AppColors.pomme500,
                            foreground: AppColors.onPrimary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
