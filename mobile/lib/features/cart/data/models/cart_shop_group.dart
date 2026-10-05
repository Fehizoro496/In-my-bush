import 'cart_item.dart';

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
