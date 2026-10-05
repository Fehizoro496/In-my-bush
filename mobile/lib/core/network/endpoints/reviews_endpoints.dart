/// Buyer reviews.
abstract class ReviewsEndpoints {
  static String orderReviews(String orderId) => '/me/orders/$orderId/reviews';
}
