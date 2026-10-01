import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/catalog_models.dart';
import 'data/catalog_repository.dart';

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).getCategories(),
);

final homeFeedProvider = FutureProvider<HomeFeed>(
  (ref) => ref.watch(catalogRepositoryProvider).getHomeFeed(),
);

/// Filters of the Home catalogue, edited by the chips and the Filtres sheet.
class CatalogQueryController extends Notifier<ProductQuery> {
  @override
  ProductQuery build() => const ProductQuery(maxDistanceKm: 15, minRating: 4.5, inStockOnly: true);

  void set(ProductQuery query) => state = query;

  void selectCategory(String? slug) =>
      state = slug == null ? state.copyWith(clearCategory: true) : state.copyWith(categorySlug: slug);

  void setSort(ProductSort sort) => state = state.copyWith(sort: sort);

  void clearDistance() => state = state.copyWith(clearDistance: true);

  void reset() => state = const ProductQuery();
}

final catalogQueryProvider = NotifierProvider<CatalogQueryController, ProductQuery>(CatalogQueryController.new);

class CatalogPageState {
  const CatalogPageState({
    required this.items,
    required this.totalItems,
    required this.page,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<Product> items;
  final int totalItems;
  final int page;
  final bool hasMore;
  final bool loadingMore;

  CatalogPageState copyWith({List<Product>? items, int? page, bool? hasMore, bool? loadingMore}) =>
      CatalogPageState(
        items: items ?? this.items,
        totalItems: totalItems,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// Paginated "Tous les produits" list (infinite scroll).
class CatalogListController extends AsyncNotifier<CatalogPageState> {
  static const pageSize = 6;

  @override
  Future<CatalogPageState> build() async {
    final query = ref.watch(catalogQueryProvider);
    final page = await ref.watch(catalogRepositoryProvider).getProducts(query, size: pageSize);
    return CatalogPageState(items: page.items, totalItems: page.totalItems, page: 0, hasMore: page.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));
    try {
      final next = await ref
          .read(catalogRepositoryProvider)
          .getProducts(ref.read(catalogQueryProvider), page: current.page + 1, size: pageSize);
      state = AsyncData(current.copyWith(
        items: [...current.items, ...next.items],
        page: next.page,
        hasMore: next.hasMore,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(loadingMore: false));
    }
  }
}

final catalogListProvider = AsyncNotifierProvider<CatalogListController, CatalogPageState>(CatalogListController.new);

/// Result count for a draft query (Filtres sheet "Afficher N produits").
final productCountProvider = FutureProvider.autoDispose.family<int, ProductQuery>((ref, query) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(query, size: 1);
  return page.totalItems;
});

final productProvider = FutureProvider.autoDispose.family<Product, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).getProduct(slug),
);

final productReviewsProvider = FutureProvider.autoDispose.family<List<Review>, String>(
  (ref, productId) => ref.watch(catalogRepositoryProvider).getProductReviews(productId),
);

final similarProductsProvider = FutureProvider.autoDispose.family<List<Product>, String>((ref, slug) async {
  final product = await ref.watch(productProvider(slug).future);
  return ref.watch(catalogRepositoryProvider).getSimilarProducts(product);
});

final shopProvider = FutureProvider.autoDispose.family<Shop, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).getShop(slug),
);

final shopProductsProvider = FutureProvider.autoDispose.family<List<Product>, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).getShopProducts(slug),
);

final shopLatestReviewProvider = FutureProvider.autoDispose.family<Review?, String>(
  (ref, slug) => ref.watch(catalogRepositoryProvider).getShopLatestReview(slug),
);

final searchSuggestionsProvider = FutureProvider.autoDispose.family<List<SearchSuggestion>, String>(
  (ref, q) => ref.watch(catalogRepositoryProvider).getSuggestions(q),
);

final searchProductsProvider = FutureProvider.autoDispose.family<List<Product>, String>((ref, q) async {
  final page = await ref.watch(catalogRepositoryProvider).getProducts(ProductQuery(q: q), size: 20);
  return page.items;
});

final searchShopsProvider = FutureProvider.autoDispose.family<List<Shop>, String>(
  (ref, q) => ref.watch(catalogRepositoryProvider).searchShops(q),
);

/// Recent searches (kept in memory for the session).
class RecentSearchesController extends Notifier<List<String>> {
  @override
  List<String> build() => ['vanille', 'riz rouge', 'brèdes', 'savon'];

  void add(String q) {
    final value = q.trim();
    if (value.isEmpty) return;
    state = [value, ...state.where((s) => s != value)].take(8).toList();
  }

  void remove(String q) => state = state.where((s) => s != q).toList();

  void clear() => state = const [];
}

final recentSearchesProvider = NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);
