import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../catalog/data/catalog_mock_data.dart';

enum NotificationContext {
  purchase('PURCHASE'),
  sale('SALE'),
  system('SYSTEM');

  const NotificationContext(this.apiName);

  final String apiName;

  static NotificationContext fromApi(Object? v) =>
      NotificationContext.values.firstWhere((c) => c.apiName == v, orElse: () => NotificationContext.system);
}

/// `notifications.type` → icon and colors of the list row.
enum NotificationType {
  order('ORDER', 'truck', '#E8F1FA', '#2F6DA8'),
  sale('SALE', 'store', '#F0F6E6', '#4A7A12'),
  promo('PROMO', 'percent', '#FFF4E8', '#D86F12'),
  message('MESSAGE', 'msg', '#F4F0E6', '#4A4A42'),
  stock('STOCK', 'alert', '#FFF1E0', '#B4500A'),
  review('REVIEW', 'starO', '#FFF4E8', '#D86F12'),
  payout('PAYOUT', 'wallet', '#F0F6E6', '#4A7A12');

  const NotificationType(this.apiName, this.icon, this.background, this.foreground);

  final String apiName;
  final String icon;
  final String background;
  final String foreground;

  static NotificationType fromApi(Object? v) =>
      NotificationType.values.firstWhere((t) => t.apiName == v, orElse: () => NotificationType.order);
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.context,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.link,
    this.readAt,
    this.cta,
  });

  factory AppNotification.fromJson(JsonMap json) => AppNotification(
        id: readString(json['id']),
        context: NotificationContext.fromApi(json['context']),
        type: NotificationType.fromApi(json['type']),
        title: readString(json['title']),
        body: readString(json['body']),
        link: readStringOrNull(json['link']),
        createdAt: readDate(json['createdAt']) ?? DateTime.now(),
        readAt: readDate(json['readAt']),
        cta: readStringOrNull(json['cta']),
      );

  final String id;
  final NotificationContext context;
  final NotificationType type;
  final String title;
  final String body;

  /// In-app route (e.g. `/commandes/ord-24817-ra`).
  final String? link;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Inline action label ("Confirmer", "Laisser un avis").
  final String? cta;

  bool get unread => readAt == null;

  AppNotification markRead() => AppNotification(
        id: id,
        context: context,
        type: type,
        title: title,
        body: body,
        link: link,
        createdAt: createdAt,
        readAt: readAt ?? DateTime.now(),
        cta: cta,
      );
}

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}

class MockNotificationsRepository implements NotificationsRepository {
  MockNotificationsRepository() {
    DateTime today(int h, int m) => CatalogMockData.daysAgo(0, hour: h, minute: m);
    final read = DateTime.now();
    _items = [
      AppNotification(
        id: 'n1',
        context: NotificationContext.purchase,
        type: NotificationType.order,
        title: 'Votre commande est en route',
        body: 'IMB-24817 · Naina arrive entre 10h et 11h.',
        createdAt: today(9, 32),
        link: '/commandes/ord-24817-ra',
      ),
      AppNotification(
        id: 'n2',
        context: NotificationContext.sale,
        type: NotificationType.sale,
        title: 'Nouvelle commande reçue',
        body: 'Mialy R. · Brèdes ×3, Tomates 2 kg · à confirmer avant 14h.',
        createdAt: today(9, 12),
        link: '/vendre/commandes/so-24821',
        cta: 'Confirmer',
      ),
      AppNotification(
        id: 'n3',
        context: NotificationContext.purchase,
        type: NotificationType.message,
        title: 'Rucher d’Ambohimanga vous a écrit',
        body: '« Le livreur part à 9h30, bonne journée ! »',
        createdAt: today(9, 28),
        link: '/messages/conv-ra',
      ),
      AppNotification(
        id: 'n4',
        context: NotificationContext.sale,
        type: NotificationType.stock,
        title: 'Stock faible',
        body: 'Carottes nouvelles : plus que 3 kg en stock.',
        createdAt: today(8, 0),
        readAt: read,
        link: '/vendre/produits',
      ),
      AppNotification(
        id: 'n5',
        context: NotificationContext.purchase,
        type: NotificationType.review,
        title: 'Donnez votre avis',
        body: 'Comment était le Savon au ravintsara d’Atelier Hazo ?',
        createdAt: CatalogMockData.daysAgo(3, hour: 10),
        link: '/commandes/ord-24655/avis',
        cta: 'Laisser un avis',
      ),
      AppNotification(
        id: 'n6',
        context: NotificationContext.system,
        type: NotificationType.promo,
        title: 'Un favori est en promotion',
        body: 'Avocats Hass : −20 % jusqu’à dimanche.',
        createdAt: CatalogMockData.daysAgo(4, hour: 11),
        readAt: read,
        link: '/produits/avocats-hass',
      ),
      AppNotification(
        id: 'n7',
        context: NotificationContext.sale,
        type: NotificationType.payout,
        title: 'Paiement versé',
        body: 'Le paiement de la commande IMB-24761 a été versé.',
        createdAt: CatalogMockData.daysAgo(5, hour: 16),
        readAt: read,
        link: '/vendre/historique',
      ),
    ];
  }

  late List<AppNotification> _items;

  @override
  Future<List<AppNotification>> getNotifications() async {
    await MockLatency.wait();
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markRead(String id) async {
    _items = [for (final n in _items) n.id == id ? n.markRead() : n];
  }

  @override
  Future<void> markAllRead() async {
    _items = [for (final n in _items) n.markRead()];
  }
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<AppNotification>> getNotifications() async =>
      (await _api.getList('/notifications')).map((e) => AppNotification.fromJson(readMap(e))).toList();

  @override
  Future<void> markRead(String id) async => _api.post('/notifications/$id/read');

  @override
  Future<void> markAllRead() async => _api.post('/notifications/read-all');
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockNotificationsRepository();
  return ApiNotificationsRepository(ref.watch(apiClientProvider));
});

class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() => ref.watch(notificationsRepositoryProvider).getNotifications();

  Future<void> markRead(AppNotification notification) async {
    if (!notification.unread) return;
    final current = state.valueOrNull ?? const <AppNotification>[];
    state = AsyncData([for (final n in current) n.id == notification.id ? n.markRead() : n]);
    await ref.read(notificationsRepositoryProvider).markRead(notification.id);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull ?? const <AppNotification>[];
    state = AsyncData([for (final n in current) n.markRead()]);
    await ref.read(notificationsRepositoryProvider).markAllRead();
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(NotificationsController.new);

/// Badge of the "Notifs" tab.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsControllerProvider).valueOrNull ?? const <AppNotification>[];
  return list.where((n) => n.unread).length;
});
