import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_models.dart';
import 'cart_models.dart';

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
  ApiCartRepository(this._api);

  final ApiClient _api;

  Future<Cart> _read(Future<dynamic> request) async {
    await request;
    return getCart();
  }

  @override
  Future<Cart> getCart() async => Cart.fromJson(await _api.getMap('/me/cart'));

  @override
  Future<Cart> addItem(Product product, int quantity) =>
      _read(_api.post('/me/cart/items', body: {'productId': product.id, 'quantity': quantity}));

  @override
  Future<Cart> updateQuantity(String itemId, int quantity) =>
      _read(_api.patch('/me/cart/items/$itemId', body: {'quantity': quantity}));

  @override
  Future<Cart> removeItem(String itemId) => _read(_api.delete('/me/cart/items/$itemId'));

  @override
  Future<Cart> clear() => _read(_api.delete('/me/cart'));
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockCartRepository();
  return ApiCartRepository(ref.watch(apiClientProvider));
});
