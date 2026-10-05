import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/avatar_look.dart';
import '../../auth/auth_controller.dart';
import '../../catalog/data/catalog_mock_data.dart';
import 'models/models.dart';

export 'models/models.dart';

abstract class MessagesRepository {
  Future<List<Conversation>> getConversations(MessageContext context);

  Future<Conversation> getConversation(String id);

  Future<List<ChatMessage>> getMessages(String conversationId);

  Future<ChatMessage> send(String conversationId, String body);

  Future<void> markRead(String conversationId);
}

class MockMessagesRepository implements MessagesRepository {
  MockMessagesRepository() {
    DateTime today(int h, int m) => CatalogMockData.daysAgo(0, hour: h, minute: m);
    DateTime ago(int d) => CatalogMockData.daysAgo(d, hour: 17, minute: 40);
    _conversations.addAll([
      Conversation(
        id: 'conv-ra',
        context: MessageContext.purchase,
        title: 'Rucher d’Ambohimanga',
        avatar: const AvatarLook(initials: 'RA', color: '#D86F12'),
        subject: 'Commande IMB-24817',
        subjectIcon: 'package',
        lastMessage: 'Le livreur part à 9h30, bonne journée !',
        lastMessageAt: today(9, 28),
        unreadCount: 2,
        online: true,
        orderId: 'ord-24817-ra',
        orderNumber: 'IMB-24817',
        orderSummary: '2 × Miel de litchi cru · 36 000 Ar',
        orderStatus: 'En route',
        shopSlug: 'rucher-ambohimanga',
        statusLine: 'En ligne · répond en ~1 h',
      ),
      Conversation(
        id: 'conv-naina',
        context: MessageContext.purchase,
        title: 'Naina (livreur)',
        avatar: const AvatarLook(initials: 'NR', color: '#7A5A2E'),
        subject: 'Livraison en cours',
        subjectIcon: 'truck',
        lastMessage: 'Je suis devant le portail bleu ?',
        lastMessageAt: today(9, 41),
        unreadCount: 1,
        online: true,
        orderId: 'ord-24817-ra',
        statusLine: 'En ligne',
      ),
      Conversation(
        id: 'conv-hazo',
        context: MessageContext.purchase,
        title: 'Atelier Hazo',
        avatar: const AvatarLook(initials: 'AH', color: '#2F6DA8'),
        subject: 'Savon au ravintsara',
        lastMessage: 'Oui, nous faisons aussi une version sans parfum.',
        lastMessageAt: ago(1),
        shopSlug: 'atelier-hazo',
      ),
      Conversation(
        id: 'conv-tsara',
        context: MessageContext.purchase,
        title: 'Ferme Tsara',
        avatar: const AvatarLook(initials: 'FT', color: '#4A7A12'),
        subject: 'Tomates cœur de bœuf',
        lastMessage: 'Vous : Merci, à jeudi !',
        lastMessageAt: ago(3),
        shopSlug: 'ferme-tsara',
      ),
      Conversation(
        id: 'conv-mialy',
        context: MessageContext.sale,
        title: 'Mialy R.',
        avatar: const AvatarLook(initials: 'MR', color: '#2F6DA8'),
        subject: 'Commande IMB-24821',
        subjectIcon: 'package',
        lastMessage: 'Est-ce possible de livrer avant 10h ?',
        lastMessageAt: today(9, 15),
        unreadCount: 1,
        online: true,
        orderId: 'so-24821',
        orderNumber: 'IMB-24821',
        orderSummary: 'Brèdes ×3 · Tomates 2 kg · 12 000 Ar',
        orderStatus: 'Nouvelle',
      ),
      Conversation(
        id: 'conv-toky',
        context: MessageContext.sale,
        title: 'Toky A.',
        avatar: const AvatarLook(initials: 'TA', color: '#7A5A2E'),
        subject: 'Panier de saison',
        lastMessage: 'Vous : Il reste 2 paniers, je vous en garde un.',
        lastMessageAt: ago(1),
      ),
      Conversation(
        id: 'conv-team',
        context: MessageContext.sale,
        title: 'Équipe In my bush',
        avatar: const AvatarLook(initials: 'IB', color: '#1F2318'),
        subject: 'Vérification',
        subjectIcon: 'shield',
        lastMessage: 'Votre boutique est en cours de vérification.',
        lastMessageAt: ago(9),
      ),
    ]);

    _messages['conv-ra'] = [
      ChatMessage(id: 'm1', body: 'Bonjour ! Le miel sera-t-il bien livré ce matin ? Je pars à 11h30.', mine: true, createdAt: today(9, 2)),
      ChatMessage(id: 'm2', body: 'Bonjour Hery, oui : il est emballé et part avec Naina vers 9h30.', mine: false, createdAt: today(9, 20)),
      ChatMessage(
        id: 'm3',
        body: 'Vous devriez l’avoir entre 10h et 11h. Pensez à garder le pot à l’abri de la chaleur.',
        mine: false,
        createdAt: today(9, 21),
      ),
      ChatMessage(id: 'm4', body: 'Parfait, merci beaucoup !', mine: true, createdAt: today(9, 24)),
      ChatMessage(id: 'm5', body: 'Le livreur part à 9h30, bonne journée !', mine: false, createdAt: today(9, 28)),
    ];
  }

  final List<Conversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messages = {};

  @override
  Future<List<Conversation>> getConversations(MessageContext context) async {
    await MockLatency.wait();
    return _conversations.where((c) => c.context == context).toList();
  }

  @override
  Future<Conversation> getConversation(String id) async {
    await MockLatency.wait(const Duration(milliseconds: 100));
    return _conversations.firstWhere((c) => c.id == id, orElse: () => _conversations.first);
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    await MockLatency.wait();
    final existing = _messages[conversationId];
    if (existing != null) return List.unmodifiable(existing);
    final conv = _conversations.firstWhere((c) => c.id == conversationId, orElse: () => _conversations.first);
    final body = conv.lastMessage.startsWith('Vous : ') ? conv.lastMessage.substring(7) : conv.lastMessage;
    return [ChatMessage(id: '$conversationId-last', body: body, mine: conv.lastMessage.startsWith('Vous'), createdAt: conv.lastMessageAt)];
  }

  @override
  Future<ChatMessage> send(String conversationId, String body) async {
    await MockLatency.wait(const Duration(milliseconds: 120));
    final message = ChatMessage(id: 'm-${DateTime.now().microsecondsSinceEpoch}', body: body, mine: true, createdAt: DateTime.now(), read: false);
    _messages.putIfAbsent(conversationId, () => []).add(message);
    return message;
  }

  @override
  Future<void> markRead(String conversationId) async {
    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
  }
}

class ApiMessagesRepository implements MessagesRepository {
  ApiMessagesRepository(this._api, {this.myUserId = ''});

  final ApiClient _api;
  final String myUserId;

  /// `{ buyerId, shopName, buyerName, orderId, productId, lastMessagePreview… }`:
  /// the side (purchase / sale) and the counterpart are deduced from the buyer.
  Conversation _conversation(JsonMap json) {
    final purchase = readString(json['buyerId']) == myUserId;
    final title = readString(purchase ? json['shopName'] : json['buyerName']);
    final orderId = readStringOrNull(json['orderId']);
    return Conversation(
      id: readString(json['id']),
      context: purchase ? MessageContext.purchase : MessageContext.sale,
      title: title,
      avatar: AvatarLook(initials: initialsOf(title)),
      subject: orderId != null ? 'Commande' : 'Question sur un produit',
      subjectIcon: orderId != null ? 'package' : 'tag',
      lastMessage: readString(json['lastMessagePreview']),
      lastMessageAt: readDate(json['lastMessageAt']) ?? readDate(json['createdAt']) ?? DateTime.now(),
      orderId: orderId,
    );
  }

  Future<List<Conversation>> _all() async =>
      (await _api.getList(MessagesEndpoints.conversations, query: {'size': 50})).map((e) => _conversation(readMap(e))).toList();

  @override
  Future<List<Conversation>> getConversations(MessageContext context) async =>
      (await _all()).where((c) => c.context == context).toList();

  @override
  Future<Conversation> getConversation(String id) async =>
      (await _all()).firstWhere((c) => c.id == id, orElse: () => throw StateError('Conversation introuvable'));

  /// The API pages messages newest first; the chat shows them oldest first.
  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async =>
      (await _api.getList(MessagesEndpoints.messages(conversationId), query: {'size': 50}))
          .map((e) => ChatMessage.fromJson(readMap(e)).sentBy(myUserId))
          .toList()
          .reversed
          .toList();

  @override
  Future<ChatMessage> send(String conversationId, String body) async =>
      ChatMessage.fromJson(readMap(await _api.post(MessagesEndpoints.messages(conversationId), body: {'body': body})))
          .sentBy(myUserId);

  @override
  Future<void> markRead(String conversationId) async => _api.post(MessagesEndpoints.read(conversationId));
}

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockMessagesRepository();
  return ApiMessagesRepository(ref.watch(sessionApiClientProvider), myUserId: ref.watch(currentUserProvider)?.id ?? '');
});
