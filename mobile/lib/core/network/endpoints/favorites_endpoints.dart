/// Favorite products (`/me/favorites`).
abstract class FavoritesEndpoints {
  static const favorites = '/me/favorites';

  static String favorite(String productId) => '/me/favorites/$productId';
}
