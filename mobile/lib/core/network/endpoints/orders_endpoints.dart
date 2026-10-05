/// Buyer orders (`/me/orders`).
abstract class OrdersEndpoints {
  static const orders = '/me/orders';

  static String order(String id) => '/me/orders/$id';
  static String cancel(String id) => '/me/orders/$id/cancel';
  static String confirmDelivery(String id) => '/me/orders/$id/confirm-delivery';
}
