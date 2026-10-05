// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cart _$CartFromJson(Map<String, dynamic> json) => Cart(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  promoCode: json['promoCode'] as String?,
  deliveryFeePerShop: json['deliveryFeePerShop'] == null
      ? 3000
      : parseInt(json['deliveryFeePerShop']),
);

Map<String, dynamic> _$CartToJson(Cart instance) => <String, dynamic>{
  'items': instance.items.map((e) => e.toJson()).toList(),
  'promoCode': ?instance.promoCode,
  'deliveryFeePerShop': instance.deliveryFeePerShop,
};
