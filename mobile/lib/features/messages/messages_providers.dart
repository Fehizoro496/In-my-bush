import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/messages_repository.dart';

final conversationsProvider = FutureProvider.family<List<Conversation>, MessageContext>(
  (ref, context) => ref.watch(messagesRepositoryProvider).getConversations(context),
);

/// Unread conversations per context (badges on "Mes achats" / "Mes ventes").
final unreadByContextProvider = Provider.family<int, MessageContext>((ref, context) {
  final list = ref.watch(conversationsProvider(context)).valueOrNull ?? const <Conversation>[];
  return list.fold(0, (sum, c) => sum + c.unreadCount);
});

/// Badge of the "Messages" tab.
final unreadMessagesCountProvider = Provider<int>(
  (ref) => ref.watch(unreadByContextProvider(MessageContext.purchase)) + ref.watch(unreadByContextProvider(MessageContext.sale)),
);

final conversationProvider = FutureProvider.autoDispose.family<Conversation, String>(
  (ref, id) => ref.watch(messagesRepositoryProvider).getConversation(id),
);

/// Messages of one conversation, with optimistic sending.
class ChatController extends AutoDisposeFamilyAsyncNotifier<List<ChatMessage>, String> {
  @override
  Future<List<ChatMessage>> build(String arg) async {
    final repo = ref.watch(messagesRepositoryProvider);
    final messages = await repo.getMessages(arg);
    await repo.markRead(arg);
    ref.invalidate(conversationsProvider);
    return messages;
  }

  Future<void> send(String body) async {
    final text = body.trim();
    if (text.isEmpty) return;
    final sent = await ref.read(messagesRepositoryProvider).send(arg, text);
    state = AsyncData([...(state.valueOrNull ?? const <ChatMessage>[]), sent]);
  }
}

final chatControllerProvider =
    AsyncNotifierProvider.autoDispose.family<ChatController, List<ChatMessage>, String>(ChatController.new);
