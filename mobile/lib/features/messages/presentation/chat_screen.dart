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

/// M-Chat — conversation with quick replies.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _quickReplies = ['Merci !', 'Je suis disponible', 'Pouvez-vous m’appeler ?'];
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _input.clear();
    await ref.read(chatControllerProvider(widget.conversationId).notifier).send(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider(widget.conversationId)).valueOrNull;
    final messages = ref.watch(chatControllerProvider(widget.conversationId));
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppColors.chatBg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTopBar(
            fallback: AppRoutes.messages,
            padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
            titleWidget: conversation == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      AppAvatar(
                        initials: conversation.avatar.initials,
                        color: conversation.avatar.colorValue,
                        size: 40,
                        fontSize: 13,
                        display: false,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.body(size: 15, weight: FontWeight.w700)),
                            if (conversation.online)
                              DotLabel(
                                label: conversation.statusLine ?? 'En ligne',
                                fontSize: 12,
                                dotSize: 7,
                                color: AppColors.pomme700,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
            actions: [
              if (conversation?.shopSlug != null)
                AppIconButton(
                  icon: AppIcons.store,
                  semanticLabel: 'Voir la boutique',
                  onPressed: () => context.push(AppRoutes.seller(conversation!.shopSlug!)),
                ),
            ],
          ),
          if (conversation?.orderNumber != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: AppCard(
                radius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                onTap: () => context.push(
                  conversation.context ==MessageContext.sale
                      ? AppRoutes.orderReceived(conversation.orderId!)
                      : AppRoutes.order(conversation.orderId!),
                ),
                child: Row(
                  children: [
                    const IconTile(
                      icon: AppIcons.package,
                      background: AppColors.orange200,
                      foreground: AppColors.orange700,
                      radius: 10,
                      iconSize: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Commande ${conversation!.orderNumber}', style: AppTypography.body(size: 13, weight: FontWeight.w700)),
                          Text(conversation.orderSummary ?? '', style: AppTypography.body(size: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (conversation.orderStatus != null)
                      StatusPill(label: conversation.orderStatus!, tone: StatusTone.info, dense: true),
                  ],
                ),
              ),
            ),
          Expanded(
            child: messages.when(
              data: (list) => ListView(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.chatDate, borderRadius: BorderRadius.circular(999)),
                      child: Text(
                        list.isNotEmpty && !FrenchDates.isSameDay(list.first.createdAt, DateTime.now())
                            ? FrenchDates.dayMonth(list.first.createdAt)
                            : 'Aujourd’hui',
                        style: AppTypography.body(size: 12, color: AppColors.muted),
                      ),
                    ),
                  ),
                  for (final m in list) _Bubble(message: m),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(chatControllerProvider(widget.conversationId))),
            ),
          ),
          ChipScroller(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            children: [
              for (final q in _quickReplies)
                Material(
                  color: AppColors.surface,
                  shape: const StadiumBorder(side: BorderSide(color: AppColors.pomme300, width: 1.5)),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: () => _send(q),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      child: Text(q, style: AppTypography.body(size: 13, weight: FontWeight.w600, color: AppColors.pomme800)),
                    ),
                  ),
                ),
            ],
          ),
          Container(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + (bottom > 16 ? bottom : 16)),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                AppIconButton(
                  icon: AppIcons.camera,
                  style: AppIconButtonStyle.sand,
                  semanticLabel: 'Joindre une photo',
                  onPressed: () => showAppToast(context, 'Envoi de photos bientôt disponible', icon: AppIcons.camera),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.lineStrong, width: 1.5),
                    ),
                    alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      style: AppTypography.body(size: 15),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Écrire un message…',
                        hintStyle: AppTypography.body(size: 15, color: AppColors.disabled),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppIconButton(
                  icon: AppIcons.arrowRight,
                  style: AppIconButtonStyle.primary,
                  radius: 999,
                  semanticLabel: 'Envoyer',
                  onPressed: () => _send(_input.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final mine = message.mine;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? AppColors.pommeSelected : AppColors.surface,
                border: mine ? null : Border.all(color: AppColors.line),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
              ),
              child: Text(message.body, style: AppTypography.body(size: 15, height: 21 / 15)),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateTime.now().difference(message.createdAt).inMinutes < 1 ? 'maintenant' : FrenchDates.clock(message.createdAt),
                style: AppTypography.body(size: 11, color: AppColors.muted),
              ),
              if (mine) ...[
                const SizedBox(width: 3),
                const Icon(AppIcons.check, size: 12, color: AppColors.pomme700),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
