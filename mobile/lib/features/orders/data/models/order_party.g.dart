// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_party.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderParty _$OrderPartyFromJson(Map<String, dynamic> json) => OrderParty(
  id: parseString(json['id']),
  name: parseString(json['name']),
  avatar: AvatarLook.fromJson(
    _readPartyAvatar(json, 'avatar') as Map<String, dynamic>,
  ),
  slug: json['slug'] == null ? '' : parseString(json['slug']),
  meta: json['meta'] as String?,
);

Map<String, dynamic> _$OrderPartyToJson(OrderParty instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'avatar': instance.avatar.toJson(),
      'meta': ?instance.meta,
    };
