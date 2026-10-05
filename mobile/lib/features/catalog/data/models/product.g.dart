// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: parseString(json['id']),
  slug: parseString(json['slug']),
  name: parseString(json['name']),
  price: parseInt(json['price']),
  unit:
      $enumDecodeNullable(
        _$ProductUnitEnumMap,
        json['unit'],
        unknownValue: ProductUnit.piece,
      ) ??
      ProductUnit.piece,
  unitLabel: parseString(_readUnitLabel(json, 'unitLabel')),
  shopId: parseString(_readFromShop(json, 'shopId')),
  shopName: parseString(_readFromShop(json, 'shopName')),
  shopSlug: parseString(_readFromShop(json, 'shopSlug')),
  shopCity: _readFromShop(json, 'shopCity') == null
      ? ''
      : parseString(_readFromShop(json, 'shopCity')),
  categoryId: _readFromCategory(json, 'categoryId') == null
      ? ''
      : parseString(_readFromCategory(json, 'categoryId')),
  categorySlug: _readFromCategory(json, 'categorySlug') == null
      ? ''
      : parseString(_readFromCategory(json, 'categorySlug')),
  description: json['description'] == null
      ? ''
      : parseString(json['description']),
  compareAtPrice: parseIntOrNull(json['compareAtPrice']),
  stock: json['stock'] == null ? 0 : parseInt(json['stock']),
  lowStockThreshold: _readLowStockThreshold(json, 'lowStockThreshold') == null
      ? 5
      : parseInt(_readLowStockThreshold(json, 'lowStockThreshold')),
  originRegion: json['originRegion'] == null
      ? ''
      : parseString(json['originRegion']),
  status:
      $enumDecodeNullable(
        _$ProductStatusEnumMap,
        json['status'],
        unknownValue: ProductStatus.published,
      ) ??
      ProductStatus.published,
  rejectionReason: json['rejectionReason'] as String?,
  ratingAvg: json['ratingAvg'] == null ? 0 : parseDouble(json['ratingAvg']),
  ratingCount: json['ratingCount'] == null ? 0 : parseInt(json['ratingCount']),
  soldCount: json['soldCount'] == null ? 0 : parseInt(json['soldCount']),
  images: _readImages(json, 'images') == null
      ? const []
      : parseStringList(_readImages(json, 'images')),
  visual: json['visual'] == null
      ? const Visual()
      : Visual.fromJson(json['visual'] as Map<String, dynamic>),
  photoLabel: json['photoLabel'] as String?,
  stockUnitLabel: json['stockUnitLabel'] as String?,
  distanceKm: parseIntOrNull(json['distanceKm']),
  visible: _readVisible(json, 'visible') == null
      ? true
      : parseBool(_readVisible(json, 'visible')),
  createdAt: parseDate(json['createdAt']),
  attributes:
      (json['attributes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'description': instance.description,
  'price': instance.price,
  'compareAtPrice': ?instance.compareAtPrice,
  'unit': _$ProductUnitEnumMap[instance.unit]!,
  'unitLabel': instance.unitLabel,
  'stock': instance.stock,
  'lowStockThreshold': instance.lowStockThreshold,
  'originRegion': instance.originRegion,
  'status': _$ProductStatusEnumMap[instance.status]!,
  'rejectionReason': ?instance.rejectionReason,
  'ratingAvg': instance.ratingAvg,
  'ratingCount': instance.ratingCount,
  'soldCount': instance.soldCount,
  'shopId': instance.shopId,
  'shopName': instance.shopName,
  'shopSlug': instance.shopSlug,
  'shopCity': instance.shopCity,
  'categoryId': instance.categoryId,
  'categorySlug': instance.categorySlug,
  'images': instance.images,
  'visual': instance.visual.toJson(),
  'photoLabel': ?instance.photoLabel,
  'stockUnitLabel': ?instance.stockUnitLabel,
  'distanceKm': ?instance.distanceKm,
  'visible': instance.visible,
  'createdAt': ?dateToJson(instance.createdAt),
  'attributes': instance.attributes,
};

const _$ProductUnitEnumMap = {
  ProductUnit.kg: 'KG',
  ProductUnit.g: 'G',
  ProductUnit.l: 'L',
  ProductUnit.piece: 'PIECE',
  ProductUnit.bunch: 'BUNCH',
  ProductUnit.jar: 'JAR',
  ProductUnit.pack: 'PACK',
};

const _$ProductStatusEnumMap = {
  ProductStatus.draft: 'DRAFT',
  ProductStatus.pendingReview: 'PENDING_REVIEW',
  ProductStatus.published: 'PUBLISHED',
  ProductStatus.rejected: 'REJECTED',
  ProductStatus.archived: 'ARCHIVED',
};
