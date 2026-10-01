/// Route names (for `context.goNamed`) of every mobile screen (docs §4).
abstract class RouteNames {
  static const home = 'home';
  static const filters = 'filters';
  static const categories = 'categories';
  static const search = 'search';
  static const product = 'product';
  static const seller = 'seller';
  static const cart = 'cart';
  static const checkout = 'checkout';
  static const confirmation = 'confirmation';
  static const login = 'login';
  static const messages = 'messages';
  static const chat = 'chat';
  static const notifications = 'notifications';
  static const settings = 'settings';
  static const profile = 'profile';
  static const favorites = 'favorites';
  static const orders = 'orders';
  static const orderDetail = 'orderDetail';
  static const review = 'review';
  static const addresses = 'addresses';
  static const payments = 'payments';
  static const sell = 'sell';
  static const becomeSeller = 'becomeSeller';
  static const myProducts = 'myProducts';
  static const addProduct = 'addProduct';
  static const editProduct = 'editProduct';
  static const ordersReceived = 'ordersReceived';
  static const orderReceived = 'orderReceived';
  static const salesHistory = 'salesHistory';
  static const reviewsReceived = 'reviewsReceived';
  static const shopProfile = 'shopProfile';
}

/// Paths (French, as in the architecture doc) and builders for
/// parameterised routes.
abstract class AppRoutes {
  static const home = '/';
  static const filters = '/filtres';
  static const categories = '/categories';
  static const search = '/recherche';
  static const cart = '/panier';
  static const checkout = '/commande';
  static const confirmation = '/commande/confirmation';
  static const login = '/connexion';
  static const messages = '/messages';
  static const notifications = '/notifications';
  static const settings = '/parametres';
  static const profile = '/profil';
  static const favorites = '/favoris';
  static const orders = '/commandes';
  static const addresses = '/adresses';
  static const payments = '/paiements';
  static const sell = '/vendre';
  static const becomeSeller = '/vendre/ouvrir-ma-boutique';
  static const myProducts = '/vendre/produits';
  static const addProduct = '/vendre/produits/nouveau';
  static const ordersReceived = '/vendre/commandes';
  static const salesHistory = '/vendre/historique';
  static const reviewsReceived = '/vendre/avis';
  static const shopProfile = '/vendre/boutique';

  static String product(String slug) => '/produits/$slug';
  static String seller(String slug) => '/vendeurs/$slug';
  static String chat(String id) => '/messages/$id';
  static String order(String id) => '/commandes/$id';
  static String orderReview(String id) => '/commandes/$id/avis';
  static String editProduct(String id) => '/vendre/produits/$id';
  static String orderReceived(String id) => '/vendre/commandes/$id';
}
