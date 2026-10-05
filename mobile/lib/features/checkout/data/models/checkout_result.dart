
import '../../../orders/data/models/models.dart';
import 'checkout_delivery.dart';

class CheckoutResult {
  const CheckoutResult({
    required this.checkoutId,
    required this.orderNumber,
    required this.total,
    required this.paymentMethod,
    required this.deliveries,
    this.firstOrderId,
  });

  final String checkoutId;
  final String orderNumber;
  final int total;
  final PaymentMethod paymentMethod;
  final List<CheckoutDelivery> deliveries;
  final String? firstOrderId;
}
