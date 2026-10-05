// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Courier _$CourierFromJson(Map<String, dynamic> json) => Courier(
  name: parseString(json['name']),
  avatar: AvatarLook.fromJson(
    _readPartyAvatar(json, 'avatar') as Map<String, dynamic>,
  ),
  vehicle: json['vehicle'] == null ? 'Moto' : parseString(json['vehicle']),
  distance: json['distance'] as String?,
);

Map<String, dynamic> _$CourierToJson(Courier instance) => <String, dynamic>{
  'name': instance.name,
  'avatar': instance.avatar.toJson(),
  'vehicle': instance.vehicle,
  'distance': ?instance.distance,
};
