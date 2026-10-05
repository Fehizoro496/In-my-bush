import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'cart_item.dart';
import 'cart_shop_group.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart {
  const Cart({this.items = const [], this.promoCode, this.deliveryFeePerShop = 3000});

  factory Cart.fromJson(JsonMap json) => _$CartFromJson(json);

  static const empty = Cart();

  /// Known promo codes and their rate (applied client-side, validated again
  /// by the API at checkout).
  static const Map<String, double> promoRates = {'BIENVENUE': 0.10};

  final List<CartItem> items;
  final String? promoCode;
  @JsonKey(fromJson: parseInt)
  final int deliveryFeePerShop;

  bool get isEmpty => items.isEmpty;

  /// Number of lines (badge on the cart icon).
  int get lineCount => items.length;

  /// Number of units ("Panier (5)").
  int get unitCount => items.fold(0, (sum, item) => sum + item.quantity);

  List<CartShopGroup> get groups {
    final map = <String, List<CartItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.product.shopId, () => []).add(item);
    }
    return [
      for (final entry in map.entries)
        CartShopGroup(
          shopId: entry.key,
          shopName: entry.value.first.product.shopName,
          shopSlug: entry.value.first.product.shopSlug,
          items: entry.value,
        ),
    ];
  }

  int get shopCount => groups.length;
  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
  int get deliveryFee => shopCount * deliveryFeePerShop;
  double get promoRate => promoRates[promoCode] ?? 0;
  int get discount => (subtotal * promoRate).round();
  int get total => subtotal + deliveryFee - discount;

  int quantityOf(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  Cart copyWith({List<CartItem>? items, String? promoCode, bool clearPromo = false}) => Cart(
        items: items ?? this.items,
        promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
        deliveryFeePerShop: deliveryFeePerShop,
      );

  JsonMap toJson() => _$CartToJson(this);
}
