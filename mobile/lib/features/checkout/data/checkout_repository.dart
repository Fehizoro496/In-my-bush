import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/data_source.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/endpoints/endpoints.dart';
import '../../../core/utils/json.dart';
import '../../../shared/models/avatar_look.dart';
import '../../cart/data/models/models.dart';
import '../../orders/data/models/models.dart';
import 'models/models.dart';

export 'models/models.dart';

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
    // `{ checkoutId, orderIds, total }`: one order per shop.
    final json = readMap(await _api.post(CheckoutEndpoints.checkouts, body: request.toJson()));
    final orders = await Future.wait([
      for (final id in readStringList(json['orderIds'])) _api.getMap(OrdersEndpoints.order(id)).then(Order.fromJson),
    ]);
    return CheckoutResult(
      checkoutId: readString(json['checkoutId']),
      orderNumber: orders.isEmpty ? '' : orders.first.number,
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
  return ApiCheckoutRepository(ref.watch(sessionApiClientProvider));
});

/// Result of the last successful checkout (read by the confirmation screen).
final lastCheckoutProvider = StateProvider<CheckoutResult?>((ref) => null);
