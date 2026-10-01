import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../catalog/data/catalog_mock_data.dart';

/// `PURCHASE` = "Mes achats" (J’achète), `SALE` = "Mes ventes" (Je vends).
enum MessageContext {
  purchase('PURCHASE'),
  sale('SALE');

  const MessageContext(this.apiName);

  final String apiName;

  static MessageContext fromApi(Object? v) => v == 'SALE' ? MessageContext.sale : MessageContext.purchase;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.context,
    required this.title,
    required this.avatar,
    required this.subject,
    required this.lastMessage,
    required this.lastMessageAt,
    this.subjectIcon = 'tag',
    this.unreadCount = 0,
    this.online = false,
    this.orderId,
    this.orderNumber,
    this.orderSummary,
    this.orderStatus,
    this.shopSlug,
    this.statusLine,
  });

  factory Conversation.fromJson(JsonMap json) {
    final title = readString(json['title']);
    return Conversation(
      id: readString(json['id']),
      context: MessageContext.fromApi(json['context']),
      title: title,
      avatar: json['avatar'] is Map
          ? AvatarLook.fromJson(readMap(json['avatar']))
          : AvatarLook(initials: title.isEmpty ? '?' : title.substring(0, 1).toUpperCase()),
      subject: readString(json['subject']),
      subjectIcon: readString(json['subjectIcon'], 'tag'),
      lastMessage: readString(json['lastMessage']),
      lastMessageAt: readDate(json['lastMessageAt']) ?? DateTime.now(),
      unreadCount: readInt(json['unreadCount']),
      online: readBool(json['online']),
      orderId: readStringOrNull(json['orderId']),
      orderNumber: readStringOrNull(json['orderNumber']),
      orderSummary: readStringOrNull(json['orderSummary']),
      orderStatus: readStringOrNull(json['orderStatus']),
      shopSlug: readStringOrNull(json['shopSlug']),
      statusLine: readStringOrNull(json['statusLine']),
    );
  }

  final String id;
  final MessageContext context;

  /// Counterpart name.
  final String title;
  final AvatarLook avatar;

  /// "Commande IMB-24817", "Savon au ravintsara"…
  final String subject;
  final String subjectIcon;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final bool online;
  final String? orderId;
  final String? orderNumber;
  final String? orderSummary;
  final String? orderStatus;
  final String? shopSlug;

  /// "En ligne · répond en ~1 h"
  final String? statusLine;

  Conversation copyWith({int? unreadCount, String? lastMessage, DateTime? lastMessageAt}) => Conversation(
        id: id,
        context: context,
        title: title,
        avatar: avatar,
        subject: subject,
        subjectIcon: subjectIcon,
        lastMessage: lastMessage ?? this.lastMessage,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        online: online,
        orderId: orderId,
        orderNumber: orderNumber,
        orderSummary: orderSummary,
        orderStatus: orderStatus,
        shopSlug: shopSlug,
        statusLine: statusLine,
      );
}

class ChatMessage {
  const ChatMessage({required this.id, required this.body, required this.mine, required this.createdAt, this.read = true});

  factory ChatMessage.fromJson(JsonMap json, {required String myUserId}) => ChatMessage(
        id: readString(json['id']),
        body: readString(json['body']),
        mine: readString(json['senderId']) == myUserId || readBool(json['mine']),
        createdAt: readDate(json['createdAt']) ?? DateTime.now(),
        read: json['readAt'] != null,
      );

  final String id;
  final String body;
  final bool mine;
  final DateTime createdAt;
  final bool read;
}

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

  @override
  Future<List<Conversation>> getConversations(MessageContext context) async =>
      (await _api.getList('/conversations', query: {'context': context.apiName}))
          .map((e) => Conversation.fromJson(readMap(e)))
          .toList();

  @override
  Future<Conversation> getConversation(String id) async {
    for (final context in MessageContext.values) {
      final list = await getConversations(context);
      for (final c in list) {
        if (c.id == id) return c;
      }
    }
    throw StateError('Conversation introuvable');
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async =>
      (await _api.getList('/conversations/$conversationId/messages'))
          .map((e) => ChatMessage.fromJson(readMap(e), myUserId: myUserId))
          .toList();

  @override
  Future<ChatMessage> send(String conversationId, String body) async => ChatMessage.fromJson(
        readMap(await _api.post('/conversations/$conversationId/messages', body: {'body': body})),
        myUserId: myUserId,
      );

  @override
  Future<void> markRead(String conversationId) async => _api.post('/conversations/$conversationId/read');
}

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockMessagesRepository();
  return ApiMessagesRepository(ref.watch(apiClientProvider));
});
