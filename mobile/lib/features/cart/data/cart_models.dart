import '../../../core/utils/json.dart';
import '../../catalog/data/catalog_models.dart';

/// `cart_items` joined with the product.
class CartItem {
  const CartItem({required this.id, required this.product, required this.quantity});

  factory CartItem.fromJson(JsonMap json) => CartItem(
        id: readString(json['id']),
        product: Product.fromJson(readMap(json['product'])),
        quantity: readInt(json['quantity'], 1),
      );

  final String id;
  final Product product;
  final int quantity;

  int get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(id: id, product: product, quantity: quantity ?? this.quantity);

  JsonMap toJson() => {'id': id, 'product': product.toJson(), 'quantity': quantity};
}

/// Items of one shop (each shop prepares and delivers its own part).
class CartShopGroup {
  const CartShopGroup({
    required this.shopId,
    required this.shopName,
    required this.shopSlug,
    required this.items,
  });

  final String shopId;
  final String shopName;
  final String shopSlug;
  final List<CartItem> items;

  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
}

class Cart {
  const Cart({this.items = const [], this.promoCode, this.deliveryFeePerShop = 3000});

  factory Cart.fromJson(JsonMap json) => Cart(
        items: readList(json['items'], CartItem.fromJson),
        promoCode: readStringOrNull(json['promoCode']),
        deliveryFeePerShop: readInt(json['deliveryFeePerShop'], 3000),
      );

  static const empty = Cart();

  /// Known promo codes and their rate (applied client-side, validated again
  /// by the API at checkout).
  static const Map<String, double> promoRates = {'BIENVENUE': 0.10};

  final List<CartItem> items;
  final String? promoCode;
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

  JsonMap toJson() => compactJson({
        'items': items.map((e) => e.toJson()).toList(),
        'promoCode': promoCode,
        'deliveryFeePerShop': deliveryFeePerShop,
      });
}
