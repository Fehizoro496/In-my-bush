
import '../../../../shared/models/visual.dart';

/// A product the buyer can review (delivered order line).
class ReviewTarget {
  const ReviewTarget({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.shopName,
    required this.visual,
    this.deliveredAt,
  });

  final String orderId;
  final String productId;
  final String productName;
  final String shopName;
  final Visual visual;
  final DateTime? deliveredAt;
}
