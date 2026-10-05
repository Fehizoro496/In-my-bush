// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: parseString(json['id']),
  productId: parseString(json['productId']),
  productName: parseString(json['productName']),
  unitPrice: parseInt(json['unitPrice']),
  unitLabel: parseString(json['unitLabel']),
  quantity: json['quantity'] == null ? 1 : parseInt(json['quantity']),
  productSlug: json['productSlug'] == null
      ? ''
      : parseString(json['productSlug']),
  visual: json['visual'] == null
      ? const Visual()
      : Visual.fromJson(json['visual'] as Map<String, dynamic>),
  quantityLabel: json['quantityLabel'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'productSlug': instance.productSlug,
  'productName': instance.productName,
  'unitPrice': instance.unitPrice,
  'unitLabel': instance.unitLabel,
  'quantity': instance.quantity,
  'visual': instance.visual.toJson(),
  'quantityLabel': ?instance.quantityLabel,
};
