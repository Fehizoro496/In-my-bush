import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../orders/data/order_models.dart';
import '../../orders/data/orders_repository.dart';

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

/// Buyer review form payload (`POST /me/orders/{id}/reviews`).
class ReviewDraft {
  const ReviewDraft({
    required this.productId,
    required this.rating,
    this.comment = '',
    this.tags = const {},
    this.communicationRating,
    this.preparationRating,
    this.showName = true,
  });

  final String productId;
  final int rating;
  final String comment;
  final Set<String> tags;
  final int? communicationRating;
  final int? preparationRating;
  final bool showName;

  JsonMap toJson() => compactJson({
        'productId': productId,
        'rating': rating,
        'comment': comment,
        'tags': tags.toList(),
        'communicationRating': communicationRating,
        'preparationRating': preparationRating,
        'showName': showName,
      });
}

abstract class ReviewsRepository {
  /// Products of an order that still need a review.
  Future<List<ReviewTarget>> getReviewTargets(String orderId);

  Future<void> submit(String orderId, ReviewDraft draft);
}

class MockReviewsRepository implements ReviewsRepository {
  MockReviewsRepository(this._orders);

  final OrdersRepository _orders;

  @override
  Future<List<ReviewTarget>> getReviewTargets(String orderId) async {
    final purchase = await _orders.getPurchase(orderId);
    return [
      for (final order in purchase.orders)
        for (final item in order.items)
          ReviewTarget(
            orderId: order.id,
            productId: item.productId,
            productName: item.productName,
            shopName: order.shop.name,
            visual: item.visual,
            deliveredAt: order.eventDate(OrderStatus.delivered),
          ),
    ];
  }

  @override
  Future<void> submit(String orderId, ReviewDraft draft) => MockLatency.wait();
}

class ApiReviewsRepository implements ReviewsRepository {
  ApiReviewsRepository(this._api, this._orders);

  final ApiClient _api;
  final OrdersRepository _orders;

  @override
  Future<List<ReviewTarget>> getReviewTargets(String orderId) async {
    final purchase = await _orders.getPurchase(orderId);
    return [
      for (final order in purchase.orders.where((o) => o.status == OrderStatus.delivered))
        for (final item in order.items)
          ReviewTarget(
            orderId: order.id,
            productId: item.productId,
            productName: item.productName,
            shopName: order.shop.name,
            visual: item.visual,
            deliveredAt: order.eventDate(OrderStatus.delivered),
          ),
    ];
  }

  @override
  Future<void> submit(String orderId, ReviewDraft draft) async =>
      _api.post('/me/orders/$orderId/reviews', body: draft.toJson());
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  final orders = ref.watch(ordersRepositoryProvider);
  if (ref.watch(useMockDataProvider)) return MockReviewsRepository(orders);
  return ApiReviewsRepository(ref.watch(apiClientProvider), orders);
});

final reviewTargetsProvider = FutureProvider.autoDispose.family<List<ReviewTarget>, String>(
  (ref, orderId) => ref.watch(reviewsRepositoryProvider).getReviewTargets(orderId),
);
