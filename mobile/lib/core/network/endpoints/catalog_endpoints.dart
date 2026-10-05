/// Public catalogue: categories, products, shops, search.
abstract class CatalogEndpoints {
  static const categories = '/categories';
  static const products = '/products';
  static const searchSuggestions = '/search/suggestions';

  static String product(String slug) => '/products/$slug';
  static String shop(String slug) => '/shops/$slug';
  static String shopProducts(String slug) => '/shops/$slug/products';
}
