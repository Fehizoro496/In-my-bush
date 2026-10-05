// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ShopSettingsToJson(ShopSettings instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'pickupDays': instance.pickupDays.toList(),
      'pickupFrom': instance.pickupFrom,
      'pickupTo': instance.pickupTo,
      'zones': instance.zones,
      'deliveryFee': instance.deliveryFee,
      'paused': instance.paused,
    };
