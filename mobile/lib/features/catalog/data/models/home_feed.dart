import 'product.dart';
import 'shop.dart';

/// Everything shown above the catalogue on Home.
class HomeFeed {
  const HomeFeed({
    required this.recommended,
    required this.promotions,
    required this.newArrivals,
    required this.popular,
    required this.popularShops,
    this.nearbyProducerCount = 0,
    this.deliveryArea = 'Analakely, Antananarivo',
  });

  final List<Product> recommended;
  final List<Product> promotions;
  final List<Product> newArrivals;
  final List<Product> popular;
  final List<Shop> popularShops;
  final int nearbyProducerCount;
  final String deliveryArea;
}
