/// Cart of the signed-in user (`/me/cart`).
abstract class CartEndpoints {
  static const cart = '/me/cart';
  static const items = '/me/cart/items';

  static String item(String id) => '/me/cart/items/$id';
}
