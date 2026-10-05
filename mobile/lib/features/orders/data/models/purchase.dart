import 'order.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'payment_method.dart';

/// A buyer's purchase = one checkout, i.e. the orders of several shops paid
/// together ("Mes commandes").
class Purchase {
  const Purchase({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.orders,
    this.discount = 0,
    this.promoCode,
    this.paymentMethod = PaymentMethod.mvola,
    this.note,
    this.reviewed = false,
  });

  /// Groups `/me/orders` by `checkoutId`.
  static List<Purchase> groupOrders(List<Order> orders) {
    final map = <String, List<Order>>{};
    for (final o in orders) {
      map.putIfAbsent(o.checkoutId.isEmpty ? o.id : o.checkoutId, () => []).add(o);
    }
    final purchases = [
      for (final entry in map.entries)
        Purchase(
          id: entry.value.first.id,
          number: entry.value.first.number,
          createdAt: entry.value.first.createdAt,
          orders: entry.value,
          discount: entry.value.fold(0, (sum, o) => sum + o.discount),
          paymentMethod: entry.value.first.paymentMethod,
        ),
    ];
    purchases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return purchases;
  }

  final String id;
  final String number;
  final DateTime createdAt;
  final List<Order> orders;
  final int discount;
  final String? promoCode;
  final PaymentMethod paymentMethod;

  /// Info line ("Arrivée prévue aujourd’hui, 10h–11h").
  final String? note;

  /// All products of the purchase already reviewed.
  final bool reviewed;

  int get subtotal => orders.fold(0, (sum, o) => sum + o.subtotal);
  int get deliveryFee => orders.fold(0, (sum, o) => sum + o.deliveryFee);
  int get total => subtotal + deliveryFee - discount;
  int get itemCount => orders.fold(0, (sum, o) => sum + o.itemCount);
  List<OrderItem> get items => [for (final o in orders) ...o.items];

  /// Aggregated status shown on the list.
  OrderStatus get status {
    const priority = [
      OrderStatus.inDelivery,
      OrderStatus.prepared,
      OrderStatus.accepted,
      OrderStatus.pendingConfirmation,
      OrderStatus.delivered,
      OrderStatus.refused,
      OrderStatus.cancelled,
    ];
    for (final s in priority) {
      if (orders.any((o) => o.status == s)) return s;
    }
    return OrderStatus.pendingConfirmation;
  }

  bool get isActive => orders.any((o) => o.status.isActive);
  bool get canReview => orders.any((o) => o.status == OrderStatus.delivered);
}
