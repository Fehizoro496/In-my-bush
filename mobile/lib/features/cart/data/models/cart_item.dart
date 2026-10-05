import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../catalog/data/models/models.dart';

part 'cart_item.g.dart';

/// `cart_items` joined with the product.
@JsonSerializable()
class CartItem {
  const CartItem({required this.id, required this.product, required this.quantity});

  factory CartItem.fromJson(JsonMap json) => _$CartItemFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(readValue: _readCartProduct)
  final Product product;
  @JsonKey(defaultValue: 1, fromJson: parseInt)
  final int quantity;

  int get lineTotal => product.price * quantity;

  CartItem copyWith({Product? product, int? quantity}) =>
      CartItem(id: id, product: product ?? this.product, quantity: quantity ?? this.quantity);

  JsonMap toJson() => _$CartItemToJson(this);
}

/// `product` is embedded by the mock data; the API sends a flat line
/// (`productId`, `productName`, `unitPrice`…) turned into a minimal product.
Object? _readCartProduct(Map<dynamic, dynamic> json, String key) =>
    json[key] ??
    <String, dynamic>{
      'id': json['productId'],
      'slug': json['productSlug'],
      'name': json['productName'],
      'price': json['unitPrice'],
      'unitLabel': '',
      'stock': json['available'] == false ? 0 : 1,
      'lowStockThreshold': 0,
      'imageUrl': json['imageUrl'],
    };
