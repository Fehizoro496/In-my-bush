import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/visual.dart';
import '../../../../shared/widgets/product_card.dart' show StockState;
import 'product_status.dart';
import 'product_unit.dart';

part 'product.g.dart';

/// Product (`products` + first images + shop summary).
@JsonSerializable()
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

  factory Product.fromJson(JsonMap json) => _$ProductFromJson(json);


  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(fromJson: parseString)
  final String slug;
  @JsonKey(fromJson: parseString)
  final String name;
  @JsonKey(fromJson: parseString)
  final String description;
  @JsonKey(fromJson: parseInt)
  final int price;
  @JsonKey(fromJson: parseIntOrNull)
  final int? compareAtPrice;
  @JsonKey(defaultValue: ProductUnit.piece, unknownEnumValue: ProductUnit.piece)
  final ProductUnit unit;

  /// "pot 500 g", "kg", "botte"
  @JsonKey(readValue: _readUnitLabel, fromJson: parseString)
  final String unitLabel;
  @JsonKey(fromJson: parseInt)
  final int stock;
  @JsonKey(readValue: _readLowStockThreshold, fromJson: parseInt)
  final int lowStockThreshold;
  @JsonKey(fromJson: parseString)
  final String originRegion;
  @JsonKey(unknownEnumValue: ProductStatus.published)
  final ProductStatus status;
  final String? rejectionReason;
  @JsonKey(fromJson: parseDouble)
  final double ratingAvg;
  @JsonKey(fromJson: parseInt)
  final int ratingCount;
  @JsonKey(fromJson: parseInt)
  final int soldCount;
  @JsonKey(readValue: _readFromShop, fromJson: parseString)
  final String shopId;
  @JsonKey(readValue: _readFromShop, fromJson: parseString)
  final String shopName;
  @JsonKey(readValue: _readFromShop, fromJson: parseString)
  final String shopSlug;
  @JsonKey(readValue: _readFromShop, fromJson: parseString)
  final String shopCity;
  @JsonKey(readValue: _readFromCategory, fromJson: parseString)
  final String categoryId;
  @JsonKey(readValue: _readFromCategory, fromJson: parseString)
  final String categorySlug;
  @JsonKey(readValue: _readImages, fromJson: parseStringList)
  final List<String> images;
  final Visual visual;

  /// Placeholder caption ("Tomates" → "PHOTO · TOMATES").
  final String? photoLabel;

  /// Stock unit shown to sellers ("bottes", "barq.").
  final String? stockUnitLabel;
  @JsonKey(fromJson: parseIntOrNull)
  final int? distanceKm;

  /// Seller visibility toggle ("Visible sur la marketplace").
  @JsonKey(readValue: _readVisible, fromJson: parseBool)
  final bool visible;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
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

  JsonMap toJson() => _$ProductToJson(this);
}

/// `shopId`, `shopName`… come from the nested `shop: { id, name, slug, city }`.
Object? _readFromShop(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? readMap(json['shop'])[const {'shopId': 'id', 'shopName': 'name', 'shopSlug': 'slug', 'shopCity': 'city'}[key]];

/// `categoryId`, `categorySlug` come from the nested `category: { id, slug }`.
Object? _readFromCategory(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? readMap(json['category'])[const {'categoryId': 'id', 'categorySlug': 'slug'}[key]];

/// Lists carry a single `imageUrl`, details an `images` array.
Object? _readImages(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? [if (json['imageUrl'] != null) json['imageUrl']];

Object? _readUnitLabel(Map<dynamic, dynamic> json, String key) => json[key] ?? ProductUnit.fromApi(json['unit']).label;

/// Public products expose `stockStatus` instead of the seller's threshold:
/// pick a threshold that gives the same `stockState`.
Object? _readLowStockThreshold(Map<dynamic, dynamic> json, String key) {
  if (json[key] != null) return json[key];
  if (json['stockStatus'] == 'LOW_STOCK') return json['stock'];
  return json['stockStatus'] == 'IN_STOCK' ? 0 : 5;
}

/// Archived products are the hidden ones.
Object? _readVisible(Map<dynamic, dynamic> json, String key) => json[key] ?? json['status'] != 'ARCHIVED';
