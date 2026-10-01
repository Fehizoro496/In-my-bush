import '../../../core/utils/formatters.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../../shared/widgets/product_card.dart' show StockState;

/// `products.unit`
enum ProductUnit {
  kg('KG', 'kg'),
  g('G', 'g'),
  l('L', 'litre'),
  piece('PIECE', 'pièce'),
  bunch('BUNCH', 'botte'),
  jar('JAR', 'pot'),
  pack('PACK', 'lot');

  const ProductUnit(this.apiName, this.label);

  final String apiName;
  final String label;

  static ProductUnit fromApi(Object? value) =>
      ProductUnit.values.firstWhere((u) => u.apiName == value, orElse: () => ProductUnit.piece);
}

/// `products.status`
enum ProductStatus {
  draft('DRAFT', 'Brouillon'),
  pendingReview('PENDING_REVIEW', 'En relecture'),
  published('PUBLISHED', 'En ligne'),
  rejected('REJECTED', 'Refusé'),
  archived('ARCHIVED', 'Archivé');

  const ProductStatus(this.apiName, this.label);

  final String apiName;
  final String label;

  static ProductStatus fromApi(Object? value) =>
      ProductStatus.values.firstWhere((s) => s.apiName == value, orElse: () => ProductStatus.published);
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.shortName,
    this.parentId,
    this.icon = 'leaf',
    this.position = 0,
    this.productCount = 0,
    this.visual = const Visual(),
    this.foreground,
  });

  factory Category.fromJson(JsonMap json) => Category(
        id: readString(json['id']),
        parentId: readStringOrNull(json['parentId']),
        name: readString(json['name']),
        shortName: readStringOrNull(json['shortName']),
        slug: readString(json['slug']),
        icon: readString(json['icon'], 'leaf'),
        position: readInt(json['position']),
        productCount: readInt(json['productCount']),
        visual: json['visual'] is Map
            ? Visual.fromJson(readMap(json['visual']))
            : Visual(icon: readString(json['icon'], 'leaf')),
        foreground: readStringOrNull(json['foreground']),
      );

  final String id;
  final String? parentId;
  final String name;

  /// Label used by the Home chips ("Laitiers" for "Produits laitiers").
  final String? shortName;
  final String slug;
  final String icon;
  final int position;
  final int productCount;
  final Visual visual;

  /// Title color on the category tile (light text on dark tiles).
  final String? foreground;

  String get label => shortName ?? name;

  JsonMap toJson() => compactJson({
        'id': id,
        'parentId': parentId,
        'name': name,
        'shortName': shortName,
        'slug': slug,
        'icon': icon,
        'position': position,
        'productCount': productCount,
        'visual': visual.toJson(),
        'foreground': foreground,
      });
}

/// Shop summary / profile (`shops`).
class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.avatar,
    this.description = '',
    this.region = '',
    this.city = '',
    this.logoUrl,
    this.coverUrl,
    this.cover = const Visual(tint: '#E6F3CC', ink: '#365A10'),
    this.status = 'ACTIVE',
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.productCount = 0,
    this.createdAt,
    this.verified = true,
    this.responseTime,
    this.distanceKm,
    this.tags = const [],
    this.ringColor,
    this.pickup = false,
    this.deliveryNote,
    this.ownerId,
  });

  factory Shop.fromJson(JsonMap json) {
    final name = readString(json['name']);
    return Shop(
      id: readString(json['id']),
      ownerId: readStringOrNull(json['ownerId']),
      name: name,
      slug: readString(json['slug']),
      description: readString(json['description']),
      region: readString(json['region']),
      city: readString(json['city']),
      logoUrl: readStringOrNull(json['logoUrl']),
      coverUrl: readStringOrNull(json['coverUrl']),
      status: readString(json['status'], 'ACTIVE'),
      ratingAvg: readDouble(json['ratingAvg']),
      ratingCount: readInt(json['ratingCount']),
      productCount: readInt(json['productCount']),
      createdAt: readDate(json['createdAt']),
      verified: readBool(json['verified'], true),
      responseTime: readStringOrNull(json['responseTime']),
      distanceKm: readIntOrNull(json['distanceKm']),
      tags: readStringList(json['tags']),
      avatar: json['avatar'] is Map
          ? AvatarLook.fromJson(readMap(json['avatar']))
          : AvatarLook(initials: initialsOf(name)),
      cover: json['cover'] is Map ? Visual.fromJson(readMap(json['cover'])) : const Visual(tint: '#E6F3CC', ink: '#365A10'),
      ringColor: readStringOrNull(json['ringColor']),
      pickup: readBool(json['pickup']),
      deliveryNote: readStringOrNull(json['deliveryNote']),
    );
  }

  final String id;
  final String? ownerId;
  final String name;
  final String slug;
  final String description;
  final String region;
  final String city;
  final String? logoUrl;
  final String? coverUrl;
  final Visual cover;
  final AvatarLook avatar;
  final String status;
  final double ratingAvg;
  final int ratingCount;
  final int productCount;
  final DateTime? createdAt;
  final bool verified;
  final String? responseTime;
  final int? distanceKm;
  final List<String> tags;
  final String? ringColor;
  final bool pickup;
  final String? deliveryNote;

  /// "Antsirabe, Vakinankaratra"
  String get location => region.isEmpty ? city : (city.isEmpty ? region : '$city, $region');

  String get since => createdAt == null ? '' : '${createdAt!.year}';

  JsonMap toJson() => compactJson({
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'slug': slug,
        'description': description,
        'region': region,
        'city': city,
        'logoUrl': logoUrl,
        'coverUrl': coverUrl,
        'status': status,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'productCount': productCount,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'verified': verified,
        'responseTime': responseTime,
        'distanceKm': distanceKm,
        'tags': tags,
        'avatar': avatar.toJson(),
        'cover': cover.toJson(),
        'ringColor': ringColor,
        'pickup': pickup,
        'deliveryNote': deliveryNote,
      });
}

/// Product (`products` + first images + shop summary).
class Product {
  const Product({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.unit,
    required this.unitLabel,
    required this.shopId,
    required this.shopName,
    required this.shopSlug,
    this.shopCity = '',
    this.categoryId = '',
    this.categorySlug = '',
    this.description = '',
    this.compareAtPrice,
    this.stock = 0,
    this.lowStockThreshold = 5,
    this.originRegion = '',
    this.status = ProductStatus.published,
    this.rejectionReason,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.soldCount = 0,
    this.images = const [],
    this.visual = const Visual(),
    this.photoLabel,
    this.stockUnitLabel,
    this.distanceKm,
    this.visible = true,
    this.createdAt,
    this.attributes = const {},
  });

  factory Product.fromJson(JsonMap json) {
    final shop = readMap(json['shop']);
    final images = json['images'] is List
        ? (json['images'] as List)
            .map((e) => e is Map ? readString(readMap(e)['url']) : e.toString())
            .where((url) => url.isNotEmpty)
            .toList()
        : const <String>[];
    final attributes = <String, String>{};
    readMap(json['attributes']).forEach((key, value) => attributes[key] = value.toString());
    return Product(
      id: readString(json['id']),
      slug: readString(json['slug']),
      name: readString(json['name']),
      description: readString(json['description']),
      price: readInt(json['price']),
      compareAtPrice: readIntOrNull(json['compareAtPrice']),
      unit: ProductUnit.fromApi(json['unit']),
      unitLabel: readString(json['unitLabel'], ProductUnit.fromApi(json['unit']).label),
      stock: readInt(json['stock']),
      lowStockThreshold: readInt(json['lowStockThreshold'], 5),
      originRegion: readString(json['originRegion']),
      status: ProductStatus.fromApi(json['status']),
      rejectionReason: readStringOrNull(json['rejectionReason']),
      ratingAvg: readDouble(json['ratingAvg']),
      ratingCount: readInt(json['ratingCount']),
      soldCount: readInt(json['soldCount']),
      shopId: readString(json['shopId'] ?? shop['id']),
      shopName: readString(json['shopName'] ?? shop['name']),
      shopSlug: readString(json['shopSlug'] ?? shop['slug']),
      shopCity: readString(json['shopCity'] ?? shop['city']),
      categoryId: readString(json['categoryId']),
      categorySlug: readString(json['categorySlug']),
      images: images,
      visual: json['visual'] is Map ? Visual.fromJson(readMap(json['visual'])) : const Visual(),
      photoLabel: readStringOrNull(json['photoLabel']),
      stockUnitLabel: readStringOrNull(json['stockUnitLabel']),
      distanceKm: readIntOrNull(json['distanceKm']),
      visible: readBool(json['visible'], true),
      createdAt: readDate(json['createdAt']),
      attributes: attributes,
    );
  }

  final String id;
  final String slug;
  final String name;
  final String description;
  final int price;
  final int? compareAtPrice;
  final ProductUnit unit;

  /// "pot 500 g", "kg", "botte"
  final String unitLabel;
  final int stock;
  final int lowStockThreshold;
  final String originRegion;
  final ProductStatus status;
  final String? rejectionReason;
  final double ratingAvg;
  final int ratingCount;
  final int soldCount;
  final String shopId;
  final String shopName;
  final String shopSlug;
  final String shopCity;
  final String categoryId;
  final String categorySlug;
  final List<String> images;
  final Visual visual;

  /// Placeholder caption ("Tomates" → "PHOTO · TOMATES").
  final String? photoLabel;

  /// Stock unit shown to sellers ("bottes", "barq.").
  final String? stockUnitLabel;
  final int? distanceKm;

  /// Seller visibility toggle ("Visible sur la marketplace").
  final bool visible;
  final DateTime? createdAt;

  /// Extra facts (Poids net, Conservation, Récolte…).
  final Map<String, String> attributes;

  String? get imageUrl => images.isEmpty ? null : images.first;
  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= lowStockThreshold;
  String? get promo => promoLabel(price, compareAtPrice);

  StockState get stockState =>
      isOutOfStock ? StockState.out : (isLowStock ? StockState.low : StockState.inStock);

  /// "Plus que 3", "Plus que 4 kg"
  String get stockLabel {
    final unitText = unit == ProductUnit.kg ? ' kg' : '';
    return 'Plus que $stock$unitText';
  }

  Product copyWith({int? stock, bool? visible, int? price, String? name, String? description}) => Product(
        id: id,
        slug: slug,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        compareAtPrice: compareAtPrice,
        unit: unit,
        unitLabel: unitLabel,
        stock: stock ?? this.stock,
        lowStockThreshold: lowStockThreshold,
        originRegion: originRegion,
        status: status,
        rejectionReason: rejectionReason,
        ratingAvg: ratingAvg,
        ratingCount: ratingCount,
        soldCount: soldCount,
        shopId: shopId,
        shopName: shopName,
        shopSlug: shopSlug,
        shopCity: shopCity,
        categoryId: categoryId,
        categorySlug: categorySlug,
        images: images,
        visual: visual,
        photoLabel: photoLabel,
        stockUnitLabel: stockUnitLabel,
        distanceKm: distanceKm,
        visible: visible ?? this.visible,
        createdAt: createdAt,
        attributes: attributes,
      );

  JsonMap toJson() => compactJson({
        'id': id,
        'slug': slug,
        'name': name,
        'description': description,
        'price': price,
        'compareAtPrice': compareAtPrice,
        'unit': unit.apiName,
        'unitLabel': unitLabel,
        'stock': stock,
        'lowStockThreshold': lowStockThreshold,
        'originRegion': originRegion,
        'status': status.apiName,
        'rejectionReason': rejectionReason,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'soldCount': soldCount,
        'shopId': shopId,
        'shopName': shopName,
        'shopSlug': shopSlug,
        'shopCity': shopCity,
        'categoryId': categoryId,
        'categorySlug': categorySlug,
        'images': images,
        'visual': visual.toJson(),
        'photoLabel': photoLabel,
        'stockUnitLabel': stockUnitLabel,
        'distanceKm': distanceKm,
        'visible': visible,
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'attributes': attributes,
      });
}

/// Review (`reviews`).
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.authorName,
    required this.createdAt,
    this.productId = '',
    this.productName = '',
    this.orderId,
    this.author = const AvatarLook(initials: '?'),
    this.sellerReply,
    this.repliedAt,
    this.verifiedPurchase = true,
  });

  factory Review.fromJson(JsonMap json) {
    final authorName = readString(json['authorName'], 'Client');
    return Review(
      id: readString(json['id']),
      productId: readString(json['productId']),
      productName: readString(json['productName']),
      orderId: readStringOrNull(json['orderId']),
      rating: readInt(json['rating'], 5),
      comment: readString(json['comment']),
      authorName: authorName,
      author: json['author'] is Map
          ? AvatarLook.fromJson(readMap(json['author']))
          : AvatarLook(initials: initialsOf(authorName)),
      sellerReply: readStringOrNull(json['sellerReply']),
      repliedAt: readDate(json['repliedAt']),
      createdAt: readDate(json['createdAt']) ?? DateTime.now(),
      verifiedPurchase: readBool(json['verifiedPurchase'], true),
    );
  }

  final String id;
  final String productId;
  final String productName;
  final String? orderId;
  final int rating;
  final String comment;
  final String authorName;
  final AvatarLook author;
  final String? sellerReply;
  final DateTime? repliedAt;
  final DateTime createdAt;
  final bool verifiedPurchase;

  Review copyWith({String? sellerReply}) => Review(
        id: id,
        productId: productId,
        productName: productName,
        orderId: orderId,
        rating: rating,
        comment: comment,
        authorName: authorName,
        author: author,
        sellerReply: sellerReply ?? this.sellerReply,
        repliedAt: sellerReply != null ? DateTime.now() : repliedAt,
        createdAt: createdAt,
        verifiedPurchase: verifiedPurchase,
      );

  JsonMap toJson() => compactJson({
        'id': id,
        'productId': productId,
        'productName': productName,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
        'authorName': authorName,
        'author': author.toJson(),
        'sellerReply': sellerReply,
        'repliedAt': repliedAt?.toUtc().toIso8601String(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'verifiedPurchase': verifiedPurchase,
      });
}

/// Sort order of the catalogue (`sort` query parameter).
enum ProductSort {
  relevance('relevance', 'Pertinence'),
  newest('newest', 'Nouveautés'),
  priceAsc('price_asc', 'Prix croissant'),
  priceDesc('price_desc', 'Prix décroissant'),
  rating('rating', 'Mieux notés');

  const ProductSort(this.apiName, this.label);

  final String apiName;
  final String label;
}

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

/// Everything shown above the catalogue on Home.
class HomeFeed {
  const HomeFeed({
    required this.recommended,
    required this.promotions,
    required this.newArrivals,
    required this.popular,
    required this.popularShops,
    this.nearbyProducerCount = 0,
    this.deliveryArea = 'Analakely, Antananarivo',
  });

  final List<Product> recommended;
  final List<Product> promotions;
  final List<Product> newArrivals;
  final List<Product> popular;
  final List<Shop> popularShops;
  final int nearbyProducerCount;
  final String deliveryArea;
}

/// Search suggestion row.
class SearchSuggestion {
  const SearchSuggestion({required this.text, required this.meta, this.icon = 'search', this.categorySlug});

  factory SearchSuggestion.fromJson(JsonMap json) => SearchSuggestion(
        text: readString(json['text']),
        meta: readString(json['meta']),
        icon: readString(json['type']) == 'CATEGORY' ? 'layers' : readString(json['icon'], 'search'),
        categorySlug: readStringOrNull(json['categorySlug']),
      );

  final String text;
  final String meta;
  final String icon;
  final String? categorySlug;
}
