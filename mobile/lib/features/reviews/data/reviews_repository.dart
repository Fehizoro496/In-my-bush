import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../orders/data/models/models.dart';
import '../../orders/data/orders_repository.dart';
import 'models/models.dart';

export 'models/models.dart';

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
      _api.post(ReviewsEndpoints.orderReviews(orderId), body: draft.toJson());
}

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  final orders = ref.watch(ordersRepositoryProvider);
  if (ref.watch(useMockDataProvider)) return MockReviewsRepository(orders);
  return ApiReviewsRepository(ref.watch(sessionApiClientProvider), orders);
});

final reviewTargetsProvider = FutureProvider.autoDispose.family<List<ReviewTarget>, String>(
  (ref, orderId) => ref.watch(reviewsRepositoryProvider).getReviewTargets(orderId),
);
