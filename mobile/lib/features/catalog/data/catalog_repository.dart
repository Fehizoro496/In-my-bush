import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/paginated.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import 'catalog_mock_data.dart';
import 'catalog_models.dart';

/// Public catalogue: categories, products, shops, search.
abstract class CatalogRepository {
  Future<List<Category>> getCategories();

  Future<HomeFeed> getHomeFeed();

  Future<Paginated<Product>> getProducts(ProductQuery query, {int page = 0, int size = 6});

  Future<Product> getProduct(String slug);

  Future<List<Review>> getProductReviews(String productId);

  Future<List<Product>> getSimilarProducts(Product product);

  Future<Shop> getShop(String slug);

  Future<List<Product>> getShopProducts(String slug);

  Future<Review?> getShopLatestReview(String slug);

  Future<List<SearchSuggestion>> getSuggestions(String q);

  Future<List<Shop>> searchShops(String q);
}

class MockCatalogRepository implements CatalogRepository {
  @override
  Future<List<Category>> getCategories() async {
    await MockLatency.wait();
    return CatalogMockData.categories;
  }

  @override
  Future<HomeFeed> getHomeFeed() async {
    await MockLatency.wait();
    return CatalogMockData.homeFeed;
  }

  @override
  Future<Paginated<Product>> getProducts(ProductQuery query, {int page = 0, int size = 6}) async {
    await MockLatency.wait();
    var items = CatalogMockData.catalogue.where((p) {
      if (query.categorySlug != null && p.categorySlug != query.categorySlug) return false;
      if (query.q != null && query.q!.trim().isNotEmpty) {
        final needle = slugify(query.q!);
        if (!slugify('${p.name} ${p.shopName}').contains(needle)) return false;
      }
      if (query.minPrice != null && p.price < query.minPrice!) return false;
      if (query.maxPrice != null && p.price > query.maxPrice!) return false;
      if (query.minRating != null && p.ratingAvg < query.minRating!) return false;
      if (query.inStockOnly && p.isOutOfStock) return false;
      if (query.maxDistanceKm != null && p.distanceKm != null && p.distanceKm! > query.maxDistanceKm!) {
        return false;
      }
      return true;
    }).toList();

    switch (query.sort) {
      case ProductSort.relevance:
        break;
      case ProductSort.newest:
        items.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
      case ProductSort.priceAsc:
        items.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDesc:
        items.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.rating:
        items.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
    }
    items = List<Product>.of(items);
    return Paginated<Product>.slice(items, page: page, size: size);
  }

  @override
  Future<Product> getProduct(String slug) async {
    await MockLatency.wait();
    final product = CatalogMockData.productBySlug(slug);
    if (product == null) throw StateError('Produit introuvable');
    return product;
  }

  @override
  Future<List<Review>> getProductReviews(String productId) async {
    await MockLatency.wait();
    return CatalogMockData.reviewsFor(productId);
  }

  @override
  Future<List<Product>> getSimilarProducts(Product product) async {
    await MockLatency.wait();
    final same = CatalogMockData.products
        .where((p) => p.categorySlug == product.categorySlug && p.id != product.id)
        .take(4)
        .toList();
    return same;
  }

  @override
  Future<Shop> getShop(String slug) async {
    await MockLatency.wait();
    final shop = CatalogMockData.shopBySlug(slug);
    if (shop == null) throw StateError('Boutique introuvable');
    return shop;
  }

  @override
  Future<List<Product>> getShopProducts(String slug) async {
    await MockLatency.wait();
    final shop = CatalogMockData.shopBySlug(slug);
    return CatalogMockData.products.where((p) => p.shopSlug == shop?.slug).toList();
  }

  @override
  Future<Review?> getShopLatestReview(String slug) async {
    await MockLatency.wait();
    return CatalogMockData.shopLatestReview(slug);
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String q) async {
    await MockLatency.wait(const Duration(milliseconds: 120));
    final needle = slugify(q);
    if (needle.isEmpty) return const [];
    final names = <String, int>{};
    for (final p in CatalogMockData.products) {
      if (slugify(p.name).contains(needle)) names[p.name] = (names[p.name] ?? 0) + 1;
    }
    final result = <SearchSuggestion>[
      for (final entry in names.entries.take(4))
        SearchSuggestion(text: entry.key, meta: plural(entry.value, 'produit')),
    ];
    for (final c in CatalogMockData.categories) {
      if (slugify(c.name).contains(needle)) {
        result.add(SearchSuggestion(text: c.name, meta: 'Catégorie', icon: 'layers', categorySlug: c.slug));
      }
    }
    result.add(SearchSuggestion(text: '$q près de chez vous', meta: '< 15 km', icon: 'pin'));
    return result;
  }

  @override
  Future<List<Shop>> searchShops(String q) async {
    await MockLatency.wait(const Duration(milliseconds: 120));
    final needle = slugify(q);
    final matches = CatalogMockData.products
        .where((p) => slugify(p.name).contains(needle))
        .map((p) => p.shopSlug)
        .toSet();
    return CatalogMockData.shops.where((s) => matches.contains(s.slug)).take(3).toList();
  }
}

class ApiCatalogRepository implements CatalogRepository {
  ApiCatalogRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<Category>> getCategories() async =>
      (await _api.getList('/categories')).map((e) => Category.fromJson(readMap(e))).toList();

  @override
  Future<HomeFeed> getHomeFeed() async {
    Future<List<Product>> list(Map<String, dynamic> query) async =>
        (await _api.getList('/products', query: query)).map((e) => Product.fromJson(readMap(e))).toList();

    final results = await Future.wait([
      list({'sort': 'relevance', 'size': 4}),
      list({'sort': 'promo', 'size': 6}),
      list({'sort': 'newest', 'size': 6}),
      list({'sort': 'popular', 'size': 3}),
    ]);
    final shops = (await _api.getList('/shops', query: {'sort': 'popular', 'size': 6}))
        .map((e) => Shop.fromJson(readMap(e)))
        .toList();
    return HomeFeed(
      recommended: results[0],
      promotions: results[1],
      newArrivals: results[2],
      popular: results[3],
      popularShops: shops,
    );
  }

  @override
  Future<Paginated<Product>> getProducts(ProductQuery query, {int page = 0, int size = 6}) async {
    final json = await _api.getMap('/products', query: query.toQueryParameters(page: page, size: size));
    return Paginated<Product>.fromJson(json, Product.fromJson);
  }

  @override
  Future<Product> getProduct(String slug) async => Product.fromJson(await _api.getMap('/products/$slug'));

  @override
  Future<List<Review>> getProductReviews(String productId) async =>
      (await _api.getList('/products/$productId/reviews')).map((e) => Review.fromJson(readMap(e))).toList();

  @override
  Future<List<Product>> getSimilarProducts(Product product) async {
    final page = await getProducts(ProductQuery(categorySlug: product.categorySlug), size: 5);
    return page.items.where((p) => p.id != product.id).take(4).toList();
  }

  @override
  Future<Shop> getShop(String slug) async => Shop.fromJson(await _api.getMap('/shops/$slug'));

  @override
  Future<List<Product>> getShopProducts(String slug) async =>
      (await _api.getList('/shops/$slug/products')).map((e) => Product.fromJson(readMap(e))).toList();

  @override
  Future<Review?> getShopLatestReview(String slug) async {
    final shop = await getShop(slug);
    final products = await getShopProducts(shop.slug);
    if (products.isEmpty) return null;
    final reviews = await getProductReviews(products.first.id);
    return reviews.isEmpty ? null : reviews.first;
  }

  @override
  Future<List<SearchSuggestion>> getSuggestions(String q) async =>
      (await _api.getList('/search/suggestions', query: {'q': q}))
          .map((e) => SearchSuggestion.fromJson(readMap(e)))
          .toList();

  @override
  Future<List<Shop>> searchShops(String q) async =>
      (await _api.getList('/shops', query: {'q': q, 'size': 3})).map((e) => Shop.fromJson(readMap(e))).toList();
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockCatalogRepository();
  return ApiCatalogRepository(ref.watch(apiClientProvider));
});
