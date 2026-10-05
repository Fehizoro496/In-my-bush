import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../../core/utils/json.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/data/models/models.dart';
import 'models/models.dart';

abstract class CartRepository {
  Future<Cart> getCart();

  Future<Cart> addItem(Product product, int quantity);

  Future<Cart> updateQuantity(String itemId, int quantity);

  Future<Cart> removeItem(String itemId);

  Future<Cart> clear();
}

class MockCartRepository implements CartRepository {
  MockCartRepository()
      : _cart = Cart(
          items: [
            CartItem(id: 'ci-miel', product: CatalogMockData.mielLitchi, quantity: 2),
            CartItem(id: 'ci-tomates', product: CatalogMockData.tomates, quantity: 1),
            CartItem(id: 'ci-bredes', product: CatalogMockData.bredes, quantity: 2),
          ],
          promoCode: 'BIENVENUE',
        );

  Cart _cart;

  @override
  Future<Cart> getCart() async {
    await MockLatency.wait();
    return _cart;
  }

  @override
  Future<Cart> addItem(Product product, int quantity) async {
    await MockLatency.wait(const Duration(milliseconds: 150));
    final items = List<CartItem>.of(_cart.items);
    final index = items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + quantity);
    } else {
      items.add(CartItem(id: 'ci-${product.slug}', product: product, quantity: quantity));
    }
    return _cart = _cart.copyWith(items: items);
  }

  @override
  Future<Cart> updateQuantity(String itemId, int quantity) async {
    await MockLatency.wait(const Duration(milliseconds: 100));
    return _cart = _cart.copyWith(
      items: [
        for (final item in _cart.items) item.id == itemId ? item.copyWith(quantity: quantity) : item,
      ],
    );
  }

  @override
  Future<Cart> removeItem(String itemId) async {
    await MockLatency.wait(const Duration(milliseconds: 100));
    return _cart = _cart.copyWith(items: _cart.items.where((i) => i.id != itemId).toList());
  }

  @override
  Future<Cart> clear() async {
    await MockLatency.wait(const Duration(milliseconds: 100));
    return _cart = _cart.copyWith(items: const []);
  }
}

class ApiCartRepository implements CartRepository {
  ApiCartRepository(this._api, this._catalog);

  final ApiClient _api;
  final CatalogRepository _catalog;

  /// Cart lines only carry the product name and price: the full product
  /// (shop, unit, stock) is loaded once per slug.
  final Map<String, Product> _products = {};

  Future<Product?> _product(String slug) async {
    if (slug.isEmpty) return null;
    try {
      return _products[slug] ??= await _catalog.getProduct(slug);
    } on ApiException {
      return null;
    }
  }

  Future<Cart> _read(Future<dynamic> request) async {
    await request;
    return getCart();
  }

  @override
  Future<Cart> getCart() async {
    final lines = (await _api.getMap(CartEndpoints.cart))['items'];
    final items = await Future.wait([
      for (final line in lines is List ? lines : const <dynamic>[])
        () async {
          final json = readMap(line);
          return CartItem.fromJson(json).copyWith(product: await _product(readString(json['productSlug'])));
        }(),
    ]);
    return Cart(items: items);
  }

  @override
  Future<Cart> addItem(Product product, int quantity) {
    _products[product.slug] = product;
    return _read(_api.post(CartEndpoints.items, body: {'productId': product.id, 'quantity': quantity}));
  }

  @override
  Future<Cart> updateQuantity(String itemId, int quantity) =>
      _read(_api.patch(CartEndpoints.item(itemId), body: {'quantity': quantity}));

  @override
  Future<Cart> removeItem(String itemId) => _read(_api.delete(CartEndpoints.item(itemId)));

  @override
  Future<Cart> clear() => _read(_api.delete(CartEndpoints.cart));
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockCartRepository();
  return ApiCartRepository(ref.watch(sessionApiClientProvider), ref.watch(catalogRepositoryProvider));
});
