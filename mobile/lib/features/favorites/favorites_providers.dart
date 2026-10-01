import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../catalog/data/catalog_models.dart';
import 'data/favorites_repository.dart';

/// Favorite products (full list, used by the Favoris screen). Toggling keeps
/// the list and the heart icons everywhere in sync.
class FavoritesController extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() => ref.watch(favoritesRepositoryProvider).getFavoriteProducts();

  bool isFavorite(String productId) => (state.valueOrNull ?? const []).any((p) => p.id == productId);

  Future<void> toggle(Product product) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final current = state.valueOrNull ?? const <Product>[];
    if (isFavorite(product.id)) {
      state = AsyncData(current.where((p) => p.id != product.id).toList());
      await repo.removeProduct(product.id);
    } else {
      state = AsyncData([product, ...current]);
      await repo.addProduct(product.id);
    }
  }
}

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<Product>>(FavoritesController.new);

final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  final list = ref.watch(favoritesControllerProvider).valueOrNull ?? const <Product>[];
  return list.any((p) => p.id == productId);
});

/// Followed producers (Favoris › Producteurs).
class FollowedShopsController extends AsyncNotifier<List<Shop>> {
  @override
  Future<List<Shop>> build() => ref.watch(favoritesRepositoryProvider).getFavoriteShops();

  bool isFollowing(String shopId) => (state.valueOrNull ?? const []).any((s) => s.id == shopId);

  Future<void> toggle(Shop shop) async {
    final following = isFollowing(shop.id);
    final current = state.valueOrNull ?? const <Shop>[];
    state = AsyncData(following ? current.where((s) => s.id != shop.id).toList() : [shop, ...current]);
    await ref.read(favoritesRepositoryProvider).followShop(shop.id, !following);
  }
}

final followedShopsProvider = AsyncNotifierProvider<FollowedShopsController, List<Shop>>(FollowedShopsController.new);
