// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shop _$ShopFromJson(Map<String, dynamic> json) => Shop(
  id: parseString(json['id']),
  name: parseString(json['name']),
  slug: parseString(json['slug']),
  avatar: AvatarLook.fromJson(
    _readShopAvatar(json, 'avatar') as Map<String, dynamic>,
  ),
  description: json['description'] == null
      ? ''
      : parseString(json['description']),
  region: json['region'] == null ? '' : parseString(json['region']),
  city: json['city'] == null ? '' : parseString(json['city']),
  logoUrl: json['logoUrl'] as String?,
  coverUrl: json['coverUrl'] as String?,
  cover: json['cover'] == null
      ? const Visual(tint: '#E6F3CC', ink: '#365A10')
      : Visual.fromJson(json['cover'] as Map<String, dynamic>),
  status: json['status'] == null ? 'ACTIVE' : parseString(json['status']),
  ratingAvg: json['ratingAvg'] == null ? 0 : parseDouble(json['ratingAvg']),
  ratingCount: json['ratingCount'] == null ? 0 : parseInt(json['ratingCount']),
  productCount: json['productCount'] == null
      ? 0
      : parseInt(json['productCount']),
  createdAt: parseDate(json['createdAt']),
  verified: json['verified'] == null ? true : parseBool(json['verified']),
  responseTime: json['responseTime'] as String?,
  distanceKm: parseIntOrNull(json['distanceKm']),
  tags: json['tags'] == null ? const [] : parseStringList(json['tags']),
  ringColor: json['ringColor'] as String?,
  pickup: json['pickup'] == null ? false : parseBool(json['pickup']),
  deliveryNote: json['deliveryNote'] as String?,
  ownerId: json['ownerId'] as String?,
);

Map<String, dynamic> _$ShopToJson(Shop instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': ?instance.ownerId,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'region': instance.region,
  'city': instance.city,
  'logoUrl': ?instance.logoUrl,
  'coverUrl': ?instance.coverUrl,
  'cover': instance.cover.toJson(),
  'avatar': instance.avatar.toJson(),
  'status': instance.status,
  'ratingAvg': instance.ratingAvg,
  'ratingCount': instance.ratingCount,
  'productCount': instance.productCount,
  'createdAt': ?dateToJson(instance.createdAt),
  'verified': instance.verified,
  'responseTime': ?instance.responseTime,
  'distanceKm': ?instance.distanceKm,
  'tags': instance.tags,
  'ringColor': ?instance.ringColor,
  'pickup': instance.pickup,
  'deliveryNote': ?instance.deliveryNote,
};
