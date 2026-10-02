import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_models.dart';
import 'order_models.dart';

/// Buyer side of the orders (`/me/orders`).
abstract class OrdersRepository {
  Future<List<Purchase>> getPurchases();

  Future<Purchase> getPurchase(String id);

  Future<void> cancelOrder(String orderId);

  Future<void> confirmDelivery(String orderId);
}

abstract class OrdersMockData {
  static const hery = OrderParty(id: 'user-hery', name: 'Hery Rakoto', avatar: AvatarLook(initials: 'HR', color: '#365A10'));

  static OrderParty party(Shop shop) =>
      OrderParty(id: shop.id, name: shop.name, slug: shop.slug, avatar: shop.avatar);

  static DateTime _at(int daysAgo, int hour, int minute) => CatalogMockData.daysAgo(daysAgo, hour: hour, minute: minute);

  static List<OrderEvent> _events(List<OrderStatus> statuses, List<DateTime> dates) => [
        for (var i = 0; i < statuses.length; i++) OrderEvent(status: statuses[i], createdAt: dates[i]),
      ];

  static List<Purchase> purchases() {
    final created = _at(4, 18, 2);
    final rucherOrder = Order(
      id: 'ord-24817-ra',
      number: 'IMB-24817',
      checkoutId: 'chk-24817',
      shop: party(CatalogMockData.rucher),
      buyer: hery,
      status: OrderStatus.inDelivery,
      createdAt: created,
      deliverySlot: 'Aujourd’hui 10h–11h',
      eta: 'Arrivée 10h – 11h',
      courier: const Courier(
        name: 'Naina',
        avatar: AvatarLook(initials: 'NR', color: '#7A5A2E'),
        distance: 'à 3,2 km',
      ),
      events: _events(
        [OrderStatus.pendingConfirmation, OrderStatus.accepted, OrderStatus.prepared, OrderStatus.inDelivery],
        [created, created, _at(3, 16, 10), _at(0, 9, 32)],
      ),
      items: [
        OrderItem(
          id: 'oi-1',
          productId: CatalogMockData.mielLitchi.id,
          productName: 'Miel de litchi cru',
          unitPrice: 18000,
          unitLabel: 'pot 500 g',
          quantity: 2,
          visual: CatalogMockData.mielLitchi.visual,
        ),
      ],
    );
    final tsaraOrder = Order(
      id: 'ord-24817-ft',
      number: 'IMB-24817',
      checkoutId: 'chk-24817',
      shop: party(CatalogMockData.fermeTsara),
      buyer: hery,
      status: OrderStatus.accepted,
      createdAt: created,
      deliverySlot: 'Jeudi 8h–12h',
      events: _events([OrderStatus.pendingConfirmation, OrderStatus.accepted], [created, created]),
      items: [
        OrderItem(
          id: 'oi-2',
          productId: CatalogMockData.tomates.id,
          productName: 'Tomates cœur de bœuf',
          unitPrice: 4500,
          unitLabel: 'kg',
          quantity: 1,
          quantityLabel: '1 kg',
          visual: CatalogMockData.tomates.visual,
        ),
        OrderItem(
          id: 'oi-3',
          productId: CatalogMockData.bredes.id,
          productName: 'Brèdes mafana',
          unitPrice: 1000,
          unitLabel: 'botte',
          quantity: 2,
          quantityLabel: '2 bottes',
          visual: CatalogMockData.bredes.visual,
        ),
      ],
    );

    final cafeDate = _at(11, 11, 20);
    final hazoDate = _at(28, 9, 5);
    final tsaraDate = _at(43, 8, 40);
    final vanilleDate = _at(50, 19, 15);

    return [
      Purchase(
        id: 'ord-24817-ra',
        number: 'IMB-24817',
        createdAt: created,
        orders: [rucherOrder, tsaraOrder],
        discount: 4250,
        promoCode: 'BIENVENUE',
        note: 'Arrivée prévue aujourd’hui, 10h–11h',
      ),
      Purchase(
        id: 'ord-24790',
        number: 'IMB-24790',
        createdAt: cafeDate,
        note: 'Café des Hautes Terres · livraison lundi',
        orders: [
          Order(
            id: 'ord-24790',
            number: 'IMB-24790',
            checkoutId: 'chk-24790',
            shop: party(CatalogMockData.cafeHautesTerres),
            buyer: hery,
            status: OrderStatus.accepted,
            createdAt: cafeDate,
            deliverySlot: 'Lundi 8h–12h',
            events: _events([OrderStatus.pendingConfirmation, OrderStatus.accepted], [cafeDate, cafeDate]),
            items: [
              OrderItem(
                id: 'oi-4',
                productId: CatalogMockData.cafe.id,
                productName: 'Café arabica torréfié',
                unitPrice: 9000,
                unitLabel: '250 g',
                quantity: 1,
                visual: CatalogMockData.cafe.visual,
              ),
              OrderItem(
                id: 'oi-5',
                productId: CatalogMockData.rizRouge.id,
                productName: 'Riz rouge bio',
                unitPrice: 7500,
                unitLabel: 'kg',
                quantity: 2,
                visual: CatalogMockData.rizRouge.visual,
              ),
            ],
          ),
        ],
      ),
      Purchase(
        id: 'ord-24655',
        number: 'IMB-24655',
        createdAt: hazoDate,
        note: 'Livrée le ${FrenchDates.dayMonth(hazoDate.add(const Duration(days: 1)))} · Atelier Hazo',
        orders: [
          Order(
            id: 'ord-24655',
            number: 'IMB-24655',
            checkoutId: 'chk-24655',
            shop: party(CatalogMockData.atelierHazo),
            buyer: hery,
            status: OrderStatus.delivered,
            createdAt: hazoDate,
            deliveryFee: 1500,
            events: _events(OrderStatus.flow, [
              hazoDate,
              hazoDate,
              hazoDate.add(const Duration(hours: 5)),
              hazoDate.add(const Duration(hours: 20)),
              hazoDate.add(const Duration(hours: 26)),
            ]),
            items: [
              OrderItem(
                id: 'oi-6',
                productId: CatalogMockData.savon.id,
                productName: 'Savon au ravintsara',
                unitPrice: 7000,
                unitLabel: 'pièce',
                quantity: 2,
                visual: CatalogMockData.savon.visual,
              ),
              OrderItem(
                id: 'oi-7',
                productId: CatalogMockData.bougie.id,
                productName: 'Bougie à la cire d’abeille',
                unitPrice: 0,
                unitLabel: 'pièce',
                quantity: 1,
                quantityLabel: 'offerte',
                visual: const Visual(tint: '#F4F0E6', ink: '#5B4526', icon: 'store'),
              ),
            ],
          ),
        ],
      ),
      Purchase(
        id: 'ord-24512',
        number: 'IMB-24512',
        createdAt: tsaraDate,
        reviewed: true,
        note: 'Livrée le ${FrenchDates.dayMonth(tsaraDate.add(const Duration(days: 1)))} · Ferme Tsara',
        orders: [
          Order(
            id: 'ord-24512',
            number: 'IMB-24512',
            checkoutId: 'chk-24512',
            shop: party(CatalogMockData.fermeTsara),
            buyer: hery,
            status: OrderStatus.delivered,
            createdAt: tsaraDate,
            events: _events(OrderStatus.flow, List<DateTime>.filled(5, tsaraDate)),
            items: [
              OrderItem(
                id: 'oi-8',
                productId: CatalogMockData.tomates.id,
                productName: 'Tomates cœur de bœuf',
                unitPrice: 4500,
                unitLabel: 'kg',
                quantity: 4,
                quantityLabel: '4 kg',
                visual: CatalogMockData.tomates.visual,
              ),
              const OrderItem(
                id: 'oi-9',
                productId: 'prd-panier-de-saison',
                productName: 'Panier de saison',
                unitPrice: 10000,
                unitLabel: 'panier',
                quantity: 1,
                visual: Visual(tint: '#E6F3CC', ink: '#365A10', icon: 'basket'),
              ),
            ],
          ),
        ],
      ),
      Purchase(
        id: 'ord-24480',
        number: 'IMB-24480',
        createdAt: vanilleDate,
        note: 'Annulée par vous · remboursée le ${FrenchDates.dayMonth(vanilleDate.add(const Duration(days: 1)))}',
        orders: [
          Order(
            id: 'ord-24480',
            number: 'IMB-24480',
            checkoutId: 'chk-24480',
            shop: party(CatalogMockData.savaVanille),
            buyer: hery,
            status: OrderStatus.cancelled,
            createdAt: vanilleDate,
            deliveryFee: 0,
            events: [
              OrderEvent(status: OrderStatus.pendingConfirmation, createdAt: vanilleDate),
              OrderEvent(status: OrderStatus.cancelled, createdAt: vanilleDate.add(const Duration(hours: 2))),
            ],
            items: [
              OrderItem(
                id: 'oi-10',
                productId: CatalogMockData.vanille.id,
                productName: 'Vanille Bourbon, gousses',
                unitPrice: 12000,
                unitLabel: 'lot de 5',
                quantity: 1,
                visual: CatalogMockData.vanille.visual,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

class MockOrdersRepository implements OrdersRepository {
  final List<Purchase> _purchases = OrdersMockData.purchases();

  @override
  Future<List<Purchase>> getPurchases() async {
    await MockLatency.wait();
    return List.unmodifiable(_purchases);
  }

  @override
  Future<Purchase> getPurchase(String id) async {
    await MockLatency.wait();
    return _purchases.firstWhere(
      (p) => p.id == id || p.number == id || p.orders.any((o) => o.id == id),
      orElse: () => throw StateError('Commande introuvable'),
    );
  }

  @override
  Future<void> cancelOrder(String orderId) async => MockLatency.wait();

  @override
  Future<void> confirmDelivery(String orderId) async => MockLatency.wait();
}

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Purchase>> getPurchases() async {
    final orders = (await _api.getList('/me/orders', query: {'size': 50})).map((e) => Order.fromJson(readMap(e))).toList();
    return Purchase.groupOrders(orders);
  }

  @override
  Future<Purchase> getPurchase(String id) async {
    final order = Order.fromJson(await _api.getMap('/me/orders/$id'));
    final all = await getPurchases();
    return all.firstWhere(
      (p) => p.orders.any((o) => o.id == order.id),
      orElse: () => Purchase(id: order.id, number: order.number, createdAt: order.createdAt, orders: [order]),
    );
  }

  @override
  Future<void> cancelOrder(String orderId) async => _api.post('/me/orders/$orderId/cancel');

  @override
  Future<void> confirmDelivery(String orderId) async => _api.post('/me/orders/$orderId/confirm-delivery');
}

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockOrdersRepository();
  return ApiOrdersRepository(ref.watch(apiClientProvider));
});

final purchasesProvider = FutureProvider<List<Purchase>>((ref) => ref.watch(ordersRepositoryProvider).getPurchases());

final purchaseProvider = FutureProvider.autoDispose.family<Purchase, String>(
  (ref, id) => ref.watch(ordersRepositoryProvider).getPurchase(id),
);
