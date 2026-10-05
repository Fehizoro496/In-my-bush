// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: parseString(json['id']),
  name: parseString(json['name']),
  slug: parseString(json['slug']),
  shortName: json['shortName'] as String?,
  parentId: json['parentId'] as String?,
  icon: json['icon'] == null ? 'leaf' : parseString(json['icon']),
  position: json['position'] == null ? 0 : parseInt(json['position']),
  productCount: json['productCount'] == null
      ? 0
      : parseInt(json['productCount']),
  visual: _readCategoryVisual(json, 'visual') == null
      ? const Visual()
      : Visual.fromJson(
          _readCategoryVisual(json, 'visual') as Map<String, dynamic>,
        ),
  foreground: json['foreground'] as String?,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'parentId': ?instance.parentId,
  'name': instance.name,
  'shortName': ?instance.shortName,
  'slug': instance.slug,
  'icon': instance.icon,
  'position': instance.position,
  'productCount': instance.productCount,
  'visual': instance.visual.toJson(),
  'foreground': ?instance.foreground,
};
