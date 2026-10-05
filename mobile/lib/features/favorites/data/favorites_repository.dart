import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../../core/utils/json.dart';
import '../../catalog/data/catalog_mock_data.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/data/models/models.dart';

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
  ApiFavoritesRepository(this._api, this._catalog);

  final ApiClient _api;
  final CatalogRepository _catalog;

  /// Favorites are flat rows (`productId`, `productName`, `price`…): the full
  /// product is loaded by slug, with the row itself as a fallback.
  Future<Product> _product(JsonMap json) async {
    try {
      return await _catalog.getProduct(readString(json['productSlug']));
    } on ApiException {
      return Product(
        id: readString(json['productId']),
        slug: readString(json['productSlug']),
        name: readString(json['productName']),
        price: readInt(json['price']),
        unit: ProductUnit.piece,
        unitLabel: '',
        shopId: '',
        shopName: readString(json['shopName']),
        shopSlug: readString(json['shopSlug']),
        images: [if (readStringOrNull(json['imageUrl']) != null) readString(json['imageUrl'])],
      );
    }
  }

  @override
  Future<List<Product>> getFavoriteProducts() async => Future.wait([
        for (final e in await _api.getList(FavoritesEndpoints.favorites, query: {'size': 50})) _product(readMap(e)),
      ]);

  /// Followed shops are not part of the v1 API yet: empty list.
  @override
  Future<List<Shop>> getFavoriteShops() async => const [];

  @override
  Future<void> addProduct(String productId) async => _api.put(FavoritesEndpoints.favorite(productId));

  @override
  Future<void> removeProduct(String productId) async => _api.delete(FavoritesEndpoints.favorite(productId));

  @override
  Future<void> followShop(String shopId, bool follow) async {}
}

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockFavoritesRepository();
  return ApiFavoritesRepository(ref.watch(sessionApiClientProvider), ref.watch(catalogRepositoryProvider));
});
