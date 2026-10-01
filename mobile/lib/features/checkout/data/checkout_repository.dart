import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/visual.dart';
import '../../cart/data/cart_models.dart';
import '../../orders/data/order_models.dart';

class CheckoutRequest {
  const CheckoutRequest({
    required this.addressId,
    required this.deliveryMode,
    required this.slot,
    required this.paymentMethod,
    this.phone,
    this.promoCode,
  });

  final String addressId;
  final DeliveryMode deliveryMode;
  final String slot;
  final PaymentMethod paymentMethod;
  final String? phone;
  final String? promoCode;

  JsonMap toJson() => compactJson({
        'addressId': addressId,
        'deliveryMode': deliveryMode.apiName,
        'deliverySlot': slot,
        'payment': compactJson({'method': paymentMethod.apiName, 'phone': phone}),
        'promoCode': promoCode,
      });
}

/// One shop's part of the confirmed checkout (confirmation screen).
class CheckoutDelivery {
  const CheckoutDelivery({required this.shopName, required this.avatar, required this.itemsSummary, required this.when});

  final String shopName;
  final AvatarLook avatar;
  final String itemsSummary;
  final String when;
}

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

abstract class CheckoutRepository {
  Future<CheckoutResult> checkout(CheckoutRequest request, Cart cart);
}

String _itemsSummary(CartShopGroup group) {
  if (group.items.length == 1) {
    final i = group.items.first;
    return '${i.quantity} × ${i.product.name}';
  }
  return group.items.map((i) => i.product.name.split(' ').first).join(' · ');
}

class MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<CheckoutResult> checkout(CheckoutRequest request, Cart cart) async {
    await MockLatency.wait(const Duration(milliseconds: 700));
    final shipping = request.deliveryMode == DeliveryMode.home ? cart.deliveryFee : 0;
    final colors = ['#D86F12', '#4A7A12', '#2F6DA8', '#7A5A2E'];
    final groups = cart.groups;
    return CheckoutResult(
      checkoutId: 'chk-24817',
      orderNumber: 'IMB-24817',
      firstOrderId: 'ord-24817-ra',
      total: cart.subtotal + shipping - cart.discount,
      paymentMethod: request.paymentMethod,
      deliveries: [
        for (var i = 0; i < groups.length; i++)
          CheckoutDelivery(
            shopName: groups[i].shopName,
            avatar: AvatarLook(
              initials: groups[i].shopName.contains('Rucher') ? 'RA' : groups[i].shopName.substring(0, 1) + groups[i].shopName.split(' ').last.substring(0, 1),
              color: colors[i % colors.length],
            ),
            itemsSummary: _itemsSummary(groups[i]),
            when: i == 0 ? request.slot : 'Jeudi 8h–12h',
          ),
      ],
    );
  }
}

class ApiCheckoutRepository implements CheckoutRepository {
  ApiCheckoutRepository(this._api);

  final ApiClient _api;

  @override
  Future<CheckoutResult> checkout(CheckoutRequest request, Cart cart) async {
    final json = readMap(await _api.post('/checkouts', body: request.toJson()));
    final orders = readList(json['orders'], Order.fromJson);
    return CheckoutResult(
      checkoutId: readString(json['id']),
      orderNumber: orders.isEmpty ? readString(json['number']) : orders.first.number,
      firstOrderId: orders.isEmpty ? null : orders.first.id,
      total: readInt(json['total']),
      paymentMethod: request.paymentMethod,
      deliveries: [
        for (final o in orders)
          CheckoutDelivery(
            shopName: o.shop.name,
            avatar: o.shop.avatar,
            itemsSummary: o.itemsSummary,
            when: o.deliverySlot ?? request.slot,
          ),
      ],
    );
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  if (ref.watch(useMockDataProvider)) return MockCheckoutRepository();
  return ApiCheckoutRepository(ref.watch(apiClientProvider));
});

/// Result of the last successful checkout (read by the confirmation screen).
final lastCheckoutProvider = StateProvider<CheckoutResult?>((ref) => null);
