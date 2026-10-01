import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_models.dart';
import '../../orders/data/order_models.dart';
import 'seller_models.dart';

/// Seller space (`/seller/...`).
abstract class SellerRepository {
  Future<Shop> openShop({required String name, required String location, required String description, required Set<String> kinds});

  Future<SellerDashboard> getDashboard(SalesPeriod period);

  Future<List<Product>> getProducts();

  Future<Product> getProduct(String id);

  Future<Product> saveProduct(ProductDraft draft, {bool submit = true});

  Future<void> deleteProduct(String id);

  Future<Product> updateStock(String id, int stock);

  Future<Product> setVisibility(String id, bool visible);

  Future<List<Order>> getOrders();

  Future<Order> getOrder(String id);

  /// `accept | refuse | prepare | ship | deliver`
  Future<Order> transition(String id, String action);

  Future<SalesHistory> getSales(SalesPeriod period);

  Future<List<Review>> getReviews();

  Future<Review> reply(String reviewId, String text);

  Future<ShopSettings> getShopSettings();

  Future<ShopSettings> saveShopSettings(ShopSettings settings);
}

abstract class SellerMockData {
  static Shop get shop => CatalogMockData.jardinDeHery;

  static Product _product(String name, int price, String unit, String stockUnit, int stock, int threshold, String tint, String ink,
      {ProductStatus status = ProductStatus.published, bool visible = true, String icon = 'leaf'}) {
    final base = CatalogMockData.bredes;
    final slug = name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
    return Product(
      id: 'sp-$slug',
      slug: slug,
      name: name,
      description: name == 'Brèdes mafana'
          ? 'Brèdes fraîches cueillies le matin même, cultivées sans intrant chimique à Antsirabe. Idéales pour le romazava.'
          : '',
      price: price,
      unit: base.unit,
      unitLabel: unit,
      stock: stock,
      lowStockThreshold: threshold,
      status: status,
      shopId: shop.id,
      shopName: shop.name,
      shopSlug: shop.slug,
      shopCity: shop.city,
      originRegion: 'Antsirabe',
      visual: Visual(tint: tint, ink: ink, icon: icon),
      stockUnitLabel: stockUnit,
      visible: visible,
      soldCount: 64,
      createdAt: DateTime(DateTime.now().year, 6, 2),
    );
  }

  static List<Product> products() => [
        _product('Brèdes mafana', 1000, 'botte', 'bottes', 42, 5, '#DDEBC9', '#365A10'),
        _product('Carottes nouvelles', 2000, 'kg', 'kg', 3, 5, '#FCE3CF', '#B4500A'),
        _product('Tomates cerises', 6000, 'barquette', 'barq.', 18, 5, '#F6E3D6', '#B4500A'),
        _product('Panier de saison', 25000, 'panier', 'paniers', 2, 3, '#E6F3CC', '#365A10', icon: 'basket'),
        _product('Fraises de Behenjy', 8000, 'barquette', 'barq.', 0, 3, '#F8DADF', '#9A2F45', visible: false),
        _product('Salade batavia', 1500, 'pièce', 'pièces', 0, 5, '#DDEBC9', '#365A10', status: ProductStatus.draft),
        _product('Haricots verts', 3000, 'kg', 'kg', 0, 5, '#E6F3CC', '#365A10', status: ProductStatus.draft),
      ];

  static OrderParty _buyer(String name, String initials, String color, String meta) =>
      OrderParty(id: 'buyer-$initials', name: name, avatar: AvatarLook(initials: initials, color: color), meta: meta);

  static OrderItem _item(String id, String name, int price, int qty, String qtyLabel, String tint, String ink) => OrderItem(
        id: id,
        productId: 'sp-$id',
        productName: name,
        unitPrice: price,
        unitLabel: '',
        quantity: qty,
        quantityLabel: qtyLabel,
        visual: Visual(tint: tint, ink: ink),
      );

  static List<Order> orders() {
    DateTime at(int d, int h, int m) => CatalogMockData.daysAgo(d, hour: h, minute: m);
    final shopParty = OrderParty(id: shop.id, name: shop.name, slug: shop.slug, avatar: shop.avatar);
    List<OrderEvent> ev(List<OrderStatus> s, DateTime d) => [for (final x in s) OrderEvent(status: x, createdAt: d)];

    Order o(String num, OrderParty buyer, OrderStatus status, DateTime date, List<OrderItem> items,
            {DeliveryMode mode = DeliveryMode.home, String? slot, String? address}) {
      final subtotal = items.fold<int>(0, (sum, i) => sum + i.lineTotal);
      final commission = (subtotal * 0.10).round();
      final fee = mode == DeliveryMode.home ? 3000 : 0;
      return Order(
        id: 'so-${num.substring(4)}',
        number: num,
        shop: shopParty,
        buyer: buyer,
        status: status,
        createdAt: date,
        items: items,
        deliveryMode: mode,
        deliveryFee: fee,
        deliverySlot: slot,
        address: address,
        commission: commission,
        sellerNet: subtotal + fee - commission,
        acceptBefore: DateTime(date.year, date.month, date.day, 14),
        events: ev(OrderStatus.flow.where((s) => s.step <= status.step).toList(), date),
      );
    }

    return [
      o(
        'IMB-24821',
        _buyer('Mialy R.', 'MR', '#2F6DA8', 'Cliente depuis 2025 · 6 commandes'),
        OrderStatus.pendingConfirmation,
        at(0, 9, 12),
        [
          _item('bredes', 'Brèdes mafana', 1000, 3, '3 bottes', '#DDEBC9', '#365A10'),
          _item('tomates', 'Tomates cœur de bœuf', 4500, 2, '2 kg', '#F6E3D6', '#B4500A'),
        ],
        slot: 'demain 8h–12h',
        address: 'Lot IVG 12, Ambohijatovo, Antananarivo',
      ),
      o(
        'IMB-24819',
        _buyer('Toky A.', 'TA', '#7A5A2E', 'Client depuis 2024 · 3 commandes'),
        OrderStatus.accepted,
        at(1, 17, 40),
        [_item('panier', 'Panier de saison', 25000, 1, '×1', '#E6F3CC', '#365A10')],
        mode: DeliveryMode.pickup,
        slot: 'samedi',
      ),
      o(
        'IMB-24810',
        _buyer('Fara N.', 'FN', '#D86F12', 'Cliente depuis 2025 · 2 commandes'),
        OrderStatus.accepted,
        at(1, 11, 5),
        [_item('carottes', 'Carottes nouvelles', 2000, 3, '3 kg', '#FCE3CF', '#B4500A')],
        slot: 'demain 8h–12h',
        address: 'Lot II F 3, Ampasamadinika, Antananarivo',
      ),
      o(
        'IMB-24788',
        _buyer('Andry M.', 'AM', '#365A10', 'Client depuis 2025 · 4 commandes'),
        OrderStatus.inDelivery,
        at(6, 10, 0),
        [
          _item('cerises', 'Tomates cerises', 6000, 2, '×2', '#F6E3D6', '#B4500A'),
          _item('salade', 'Salade', 800, 3, '×3', '#DDEBC9', '#365A10'),
        ],
        slot: 'en route',
        address: 'Villa 8, Ivandry, Antananarivo',
      ),
      o(
        'IMB-24761',
        _buyer('Lova R.', 'LR', '#9A2F45', 'Cliente depuis 2024 · 9 commandes'),
        OrderStatus.delivered,
        at(8, 9, 30),
        [
          _item('carottes2', 'Carottes nouvelles', 2000, 2, '2 kg', '#FCE3CF', '#B4500A'),
          _item('bredes2', 'Brèdes mafana', 1000, 5, '×5', '#DDEBC9', '#365A10'),
        ],
        mode: DeliveryMode.pickup,
        slot: 'effectué',
      ),
    ];
  }

  static List<Review> reviews() => [
        Review(
          id: 'sr-1',
          productName: 'Panier de saison',
          rating: 5,
          authorName: 'Toky A.',
          author: const AvatarLook(initials: 'TA', color: '#7A5A2E'),
          comment: 'Panier très frais, brèdes impeccables. Merci !',
          createdAt: CatalogMockData.daysAgo(2),
        ),
        Review(
          id: 'sr-2',
          productName: 'Carottes nouvelles',
          rating: 4,
          authorName: 'Lova R.',
          author: const AvatarLook(initials: 'LR', color: '#9A2F45'),
          comment: 'Bonnes carottes, un peu terreuses mais c’est normal pour du bio.',
          createdAt: CatalogMockData.daysAgo(4),
        ),
        Review(
          id: 'sr-3',
          productName: 'Fraises de Behenjy',
          rating: 3,
          authorName: 'Rivo H.',
          author: const AvatarLook(initials: 'RH', color: '#2F6DA8'),
          comment: 'Bon goût mais quelques fraises abîmées à la livraison.',
          sellerReply: 'Désolé Rivo, nous avons changé nos barquettes. Un geste sur votre prochaine commande !',
          createdAt: CatalogMockData.daysAgo(7),
        ),
        Review(
          id: 'sr-4',
          productName: 'Tomates cœur de bœuf',
          rating: 5,
          authorName: 'Mialy R.',
          author: const AvatarLook(initials: 'MR', color: '#4A7A12'),
          comment: 'Les meilleures tomates de Tana, sans hésiter.',
          sellerReply: 'Merci Mialy, à bientôt au marché !',
          createdAt: CatalogMockData.daysAgo(14),
        ),
      ];

  static SalesHistory sales() {
    SaleRecord r(String client, String num, String items, int amount, PayoutState payout, int daysAgo, String tint, String ink) =>
        SaleRecord(
          orderId: 'so-${num.substring(4)}',
          number: num,
          client: client,
          itemsSummary: items,
          amount: amount,
          payout: payout,
          date: CatalogMockData.daysAgo(daysAgo),
          visual: Visual(tint: tint, ink: ink),
        );
    const months = [
      ['avr.', 620000],
      ['mai', 780000],
      ['juin', 840000],
      ['juil.', 1020000],
      ['août', 1100000],
      ['sept.', 1240000],
    ];
    return SalesHistory(
      gross: 5600000,
      commission: 560000,
      net: 5040000,
      bars: [for (final m in months) SalesBar(label: m[0] as String, value: m[1] as int)],
      records: [
        r('Andry M.', 'IMB-24788', 'Tomates cerises ×2 · Salade ×3', 14400, PayoutState.pending, 1, '#F6E3D6', '#B4500A'),
        r('Lova R.', 'IMB-24761', 'Carottes 2 kg · Brèdes ×5', 9000, PayoutState.paid, 2, '#FCE3CF', '#B4500A'),
        r('Nomena S.', 'IMB-24744', 'Panier de saison', 25000, PayoutState.paid, 3, '#E6F3CC', '#365A10'),
        r('Rivo H.', 'IMB-24702', 'Fraises ×2', 16000, PayoutState.paid, 8, '#F8DADF', '#9A2F45'),
        r('Tahina R.', 'IMB-24688', 'Brèdes ×4', 4000, PayoutState.refunded, 9, '#DDEBC9', '#365A10'),
        r('Mialy R.', 'IMB-24671', 'Tomates 3 kg', 13500, PayoutState.paid, 11, '#F6E3D6', '#B4500A'),
      ],
    );
  }
}

class MockSellerRepository implements SellerRepository {
  final List<Product> _products = SellerMockData.products();
  final List<Order> _orders = SellerMockData.orders();
  final List<Review> _reviews = SellerMockData.reviews();
  ShopSettings _settings = ShopSettings(
    name: SellerMockData.shop.name,
    description: SellerMockData.shop.description,
    location: 'Antsirabe, Vakinankaratra',
    pickupDays: const {'Me', 'Sa'},
    pickupFrom: '8h00',
    pickupTo: '12h00',
    zones: const ['Antsirabe', 'Antananarivo', 'Ambatolampy'],
  );

  @override
  Future<Shop> openShop({required String name, required String location, required String description, required Set<String> kinds}) async {
    await MockLatency.wait();
    return SellerMockData.shop;
  }

  @override
  Future<SellerDashboard> getDashboard(SalesPeriod period) async {
    await MockLatency.wait();
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    const heights = [42, 58, 35, 70, 64, 88, 76];
    final factor = period == SalesPeriod.week ? 0.25 : (period == SalesPeriod.year ? 11.0 : 1.0);
    return SellerDashboard(
      revenue: (1240000 * factor).round(),
      trendPercent: 12,
      bars: [for (var i = 0; i < 7; i++) SalesBar(label: days[i], value: heights[i] * 1000)],
      ordersReceived: 38,
      toPrepare: _orders.where((o) => o.status == OrderStatus.pendingConfirmation || o.status == OrderStatus.accepted).length,
      activeProducts: 12,
      drafts: _products.where((p) => p.status == ProductStatus.draft).length,
      lowStock: 3,
      ratingAvg: 4.8,
      ratingCount: 57,
    );
  }

  @override
  Future<List<Product>> getProducts() async {
    await MockLatency.wait();
    return List.unmodifiable(_products);
  }

  @override
  Future<Product> getProduct(String id) async {
    await MockLatency.wait();
    return _products.firstWhere((p) => p.id == id || p.slug == id, orElse: () => _products.first);
  }

  @override
  Future<Product> saveProduct(ProductDraft draft, {bool submit = true}) async {
    await MockLatency.wait();
    final index = draft.id == null ? -1 : _products.indexWhere((p) => p.id == draft.id);
    if (index >= 0) {
      final updated = _products[index].copyWith(
        name: draft.name.isEmpty ? null : draft.name,
        price: draft.price,
        stock: draft.stock,
        description: draft.description,
        visible: draft.visible,
      );
      _products[index] = updated;
      return updated;
    }
    final created = SellerMockData.products().first.copyWith(
      name: draft.name.isEmpty ? 'Nouveau produit' : draft.name,
      price: draft.price ?? 0,
      stock: draft.stock ?? 0,
      description: draft.description,
    );
    _products.insert(0, created);
    return created;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await MockLatency.wait();
    _products.removeWhere((p) => p.id == id);
  }

  @override
  Future<Product> updateStock(String id, int stock) async {
    final index = _products.indexWhere((p) => p.id == id);
    final updated = _products[index].copyWith(stock: stock);
    _products[index] = updated;
    return updated;
  }

  @override
  Future<Product> setVisibility(String id, bool visible) async {
    final index = _products.indexWhere((p) => p.id == id);
    final updated = _products[index].copyWith(visible: visible);
    _products[index] = updated;
    return updated;
  }

  @override
  Future<List<Order>> getOrders() async {
    await MockLatency.wait();
    return List.unmodifiable(_orders);
  }

  @override
  Future<Order> getOrder(String id) async {
    await MockLatency.wait();
    return _orders.firstWhere((o) => o.id == id || o.number == id, orElse: () => _orders.first);
  }

  @override
  Future<Order> transition(String id, String action) async {
    await MockLatency.wait(const Duration(milliseconds: 250));
    final index = _orders.indexWhere((o) => o.id == id);
    final order = _orders[index];
    const next = {
      'accept': OrderStatus.accepted,
      'prepare': OrderStatus.prepared,
      'ship': OrderStatus.inDelivery,
      'deliver': OrderStatus.delivered,
      'refuse': OrderStatus.refused,
    };
    final status = next[action] ?? order.status;
    final updated = order.copyWith(
      status: status,
      events: [...order.events, OrderEvent(status: status, createdAt: DateTime.now())],
    );
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<SalesHistory> getSales(SalesPeriod period) async {
    await MockLatency.wait();
    return SellerMockData.sales();
  }

  @override
  Future<List<Review>> getReviews() async {
    await MockLatency.wait();
    return List.unmodifiable(_reviews);
  }

  @override
  Future<Review> reply(String reviewId, String text) async {
    await MockLatency.wait(const Duration(milliseconds: 200));
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    final updated = _reviews[index].copyWith(sellerReply: text);
    _reviews[index] = updated;
    return updated;
  }

  @override
  Future<ShopSettings> getShopSettings() async {
    await MockLatency.wait();
    return _settings;
  }

  @override
  Future<ShopSettings> saveShopSettings(ShopSettings settings) async {
    await MockLatency.wait();
    return _settings = settings;
  }
}

class ApiSellerRepository implements SellerRepository {
  ApiSellerRepository(this._api);

  final ApiClient _api;

  @override
  Future<Shop> openShop({required String name, required String location, required String description, required Set<String> kinds}) async =>
      Shop.fromJson(readMap(await _api.post('/seller/shop', body: {
        'name': name,
        'city': location,
        'description': description,
        'tags': kinds.toList(),
      })));

  @override
  Future<SellerDashboard> getDashboard(SalesPeriod period) async =>
      SellerDashboard.fromJson(await _api.getMap('/seller/dashboard', query: {'period': period.name}));

  @override
  Future<List<Product>> getProducts() async =>
      (await _api.getList('/seller/products', query: {'size': 100})).map((e) => Product.fromJson(readMap(e))).toList();

  @override
  Future<Product> getProduct(String id) async => Product.fromJson(await _api.getMap('/seller/products/$id'));

  @override
  Future<Product> saveProduct(ProductDraft draft, {bool submit = true}) async {
    final data = draft.id == null
        ? await _api.post('/seller/products', body: draft.toJson())
        : await _api.patch('/seller/products/${draft.id}', body: draft.toJson());
    final product = Product.fromJson(readMap(data));
    if (submit && draft.id == null) await _api.post('/seller/products/${product.id}/submit');
    return product;
  }

  @override
  Future<void> deleteProduct(String id) async => _api.delete('/seller/products/$id');

  @override
  Future<Product> updateStock(String id, int stock) async =>
      Product.fromJson(readMap(await _api.patch('/seller/products/$id/stock', body: {'stock': stock})));

  @override
  Future<Product> setVisibility(String id, bool visible) async => Product.fromJson(
        readMap(await _api.patch('/seller/products/$id', body: {'status': visible ? 'PUBLISHED' : 'ARCHIVED'})),
      );

  @override
  Future<List<Order>> getOrders() async =>
      (await _api.getList('/seller/orders', query: {'size': 100})).map((e) => Order.fromJson(readMap(e))).toList();

  @override
  Future<Order> getOrder(String id) async => Order.fromJson(await _api.getMap('/seller/orders/$id'));

  @override
  Future<Order> transition(String id, String action) async =>
      Order.fromJson(readMap(await _api.post('/seller/orders/$id/$action')));

  @override
  Future<SalesHistory> getSales(SalesPeriod period) async {
    final json = await _api.getMap('/seller/sales', query: {'period': period.name});
    return SalesHistory(
      gross: readInt(json['gross']),
      commission: readInt(json['commission']),
      net: readInt(json['net']),
      bars: readList(json['bars'], (b) => SalesBar(label: readString(b['label']), value: readInt(b['value']))),
      records: readList(json['items'], SaleRecord.fromJson),
    );
  }

  @override
  Future<List<Review>> getReviews() async =>
      (await _api.getList('/seller/reviews')).map((e) => Review.fromJson(readMap(e))).toList();

  @override
  Future<Review> reply(String reviewId, String text) async =>
      Review.fromJson(readMap(await _api.post('/seller/reviews/$reviewId/reply', body: {'reply': text})));

  @override
  Future<ShopSettings> getShopSettings() async {
    final json = await _api.getMap('/seller/shop');
    return ShopSettings(
      name: readString(json['name']),
      description: readString(json['description']),
      location: [readString(json['city']), readString(json['region'])].where((s) => s.isNotEmpty).join(', '),
      pickupDays: readStringList(json['pickupDays']).toSet(),
      pickupFrom: readString(json['pickupFrom'], '8h00'),
      pickupTo: readString(json['pickupTo'], '12h00'),
      zones: readStringList(json['deliveryZones']),
      deliveryFee: readInt(json['deliveryFee'], 3000),
      paused: readString(json['status']) == 'PAUSED',
    );
  }

  @override
  Future<ShopSettings> saveShopSettings(ShopSettings settings) async {
    await _api.patch('/seller/shop', body: settings.toJson());
    return settings;
  }
}

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockSellerRepository();
  return ApiSellerRepository(ref.watch(apiClientProvider));
});
