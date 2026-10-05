// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem(
  id: parseString(json['id']),
  product: Product.fromJson(
    _readCartProduct(json, 'product') as Map<String, dynamic>,
  ),
  quantity: json['quantity'] == null ? 1 : parseInt(json['quantity']),
);

Map<String, dynamic> _$CartItemToJson(CartItem instance) => <String, dynamic>{
  'id': instance.id,
  'product': instance.product.toJson(),
  'quantity': instance.quantity,
};
