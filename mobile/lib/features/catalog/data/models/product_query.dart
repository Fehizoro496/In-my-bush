import 'product_sort.dart';

/// Catalogue filters (Filtres sheet + Home chips).
class ProductQuery {
  const ProductQuery({
    this.q,
    this.categorySlug,
    this.sort = ProductSort.relevance,
    this.minPrice,
    this.maxPrice,
    this.maxDistanceKm,
    this.minRating,
    this.inStockOnly = false,
    this.deliveryToday = false,
    this.productTypes = const {},
    this.sellerOptions = const {},
    this.region,
  });

  final String? q;
  final String? categorySlug;
  final ProductSort sort;
  final int? minPrice;
  final int? maxPrice;
  final int? maxDistanceKm;
  final double? minRating;
  final bool inStockOnly;
  final bool deliveryToday;
  final Set<String> productTypes;
  final Set<String> sellerOptions;
  final String? region;

  /// Number of active filters (badge on the "Filtres" button).
  int get activeFilterCount =>
      (minPrice != null || maxPrice != null ? 1 : 0) +
      (maxDistanceKm != null ? 1 : 0) +
      (minRating != null ? 1 : 0) +
      (inStockOnly ? 1 : 0) +
      (deliveryToday ? 1 : 0) +
      productTypes.length +
      sellerOptions.length;

  ProductQuery copyWith({
    String? q,
    String? categorySlug,
    bool clearCategory = false,
    ProductSort? sort,
    int? minPrice,
    int? maxPrice,
    bool clearPrice = false,
    int? maxDistanceKm,
    bool clearDistance = false,
    double? minRating,
    bool clearRating = false,
    bool? inStockOnly,
    bool? deliveryToday,
    Set<String>? productTypes,
    Set<String>? sellerOptions,
  }) {
    return ProductQuery(
      q: q ?? this.q,
      categorySlug: clearCategory ? null : (categorySlug ?? this.categorySlug),
      sort: sort ?? this.sort,
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      maxDistanceKm: clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
      minRating: clearRating ? null : (minRating ?? this.minRating),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      deliveryToday: deliveryToday ?? this.deliveryToday,
      productTypes: productTypes ?? this.productTypes,
      sellerOptions: sellerOptions ?? this.sellerOptions,
      region: region,
    );
  }

  Map<String, dynamic> toQueryParameters({int page = 0, int size = 20}) => {
        'q': q,
        'category': categorySlug,
        'region': region,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'inStock': inStockOnly ? true : null,
        'sort': sort.apiName,
        'page': page,
        'size': size,
      };

  @override
  bool operator ==(Object other) =>
      other is ProductQuery &&
      other.q == q &&
      other.categorySlug == categorySlug &&
      other.sort == sort &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.maxDistanceKm == maxDistanceKm &&
      other.minRating == minRating &&
      other.inStockOnly == inStockOnly &&
      other.deliveryToday == deliveryToday &&
      _setEquals(other.productTypes, productTypes) &&
      _setEquals(other.sellerOptions, sellerOptions);

  @override
  int get hashCode => Object.hash(
        q,
        categorySlug,
        sort,
        minPrice,
        maxPrice,
        maxDistanceKm,
        minRating,
        inStockOnly,
        deliveryToday,
        Object.hashAllUnordered(productTypes),
        Object.hashAllUnordered(sellerOptions),
      );

  static bool _setEquals(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);
}
