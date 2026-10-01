import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_models.dart';

abstract class FavoritesRepository {
  Future<List<Product>> getFavoriteProducts();

  Future<List<Shop>> getFavoriteShops();

  Future<void> addProduct(String productId);

  Future<void> removeProduct(String productId);

  Future<void> followShop(String shopId, bool follow);
}

class MockFavoritesRepository implements FavoritesRepository {
  final List<Product> _products = [
    CatalogMockData.mielLitchi,
    CatalogMockData.avocats,
    CatalogMockData.litchis,
    CatalogMockData.vanille,
    CatalogMockData.confiture,
    CatalogMockData.savon,
  ];

  final List<Shop> _shops = [
    CatalogMockData.rucher,
    CatalogMockData.fermeTsara,
    CatalogMockData.atelierHazo,
  ];

  @override
  Future<List<Product>> getFavoriteProducts() async {
    await MockLatency.wait();
    return List.unmodifiable(_products);
  }

  @override
  Future<List<Shop>> getFavoriteShops() async {
    await MockLatency.wait();
    return List.unmodifiable(_shops);
  }

  @override
  Future<void> addProduct(String productId) async {
    await MockLatency.wait(const Duration(milliseconds: 80));
    if (_products.any((p) => p.id == productId)) return;
    for (final p in CatalogMockData.products) {
      if (p.id == productId) _products.insert(0, p);
    }
  }

  @override
  Future<void> removeProduct(String productId) async {
    await MockLatency.wait(const Duration(milliseconds: 80));
    _products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<void> followShop(String shopId, bool follow) async {
    await MockLatency.wait(const Duration(milliseconds: 80));
    _shops.removeWhere((s) => s.id == shopId);
    if (follow) {
      for (final s in CatalogMockData.shops) {
        if (s.id == shopId) _shops.insert(0, s);
      }
    }
  }
}

class ApiFavoritesRepository implements FavoritesRepository {
  ApiFavoritesRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Product>> getFavoriteProducts() async =>
      (await _api.getList('/me/favorites')).map((e) => Product.fromJson(readMap(e))).toList();

  /// Followed shops are not part of the v1 API yet: empty list.
  @override
  Future<List<Shop>> getFavoriteShops() async => const [];

  @override
  Future<void> addProduct(String productId) async => _api.put('/me/favorites/$productId');

  @override
  Future<void> removeProduct(String productId) async => _api.delete('/me/favorites/$productId');

  @override
  Future<void> followShop(String shopId, bool follow) async {}
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockFavoritesRepository();
  return ApiFavoritesRepository(ref.watch(apiClientProvider));
});
