/// Seller space (`/seller`).
abstract class SellerEndpoints {
  static const shop = '/seller/shop';
  static const products = '/seller/products';
  static const orders = '/seller/orders';
  static const reviews = '/seller/reviews';

  static String product(String id) => '/seller/products/$id';
  static String productStock(String id) => '/seller/products/$id/stock';
  static String order(String id) => '/seller/orders/$id';

  /// [action]: `accept | refuse | prepare | ship | deliver`.
  static String orderAction(String id, String action) => '/seller/orders/$id/$action';
  static String reviewReply(String id) => '/seller/reviews/$id/reply';
}
