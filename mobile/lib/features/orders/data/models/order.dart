import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'courier.dart';
import 'delivery_mode.dart';
import 'order_event.dart';
import 'order_item.dart';
import 'order_party.dart';
import 'order_status.dart';
import 'payment_method.dart';

part 'order.g.dart';

/// One order = the part of a checkout prepared by one shop.
@JsonSerializable()
class Order {
  const Order({
    required this.id,
    required this.number,
    required this.shop,
    required this.buyer,
    required this.status,
    required this.items,
    required this.createdAt,
    this.checkoutId = '',
    this.deliveryFee = 3000,
    this.discount = 0,
    this.commission,
    this.sellerNet,
    this.deliveryMode = DeliveryMode.home,
    this.deliverySlot,
    this.acceptBefore,
    this.events = const [],
    this.address,
    this.paymentMethod = PaymentMethod.mvola,
    this.paymentStatus = '',
    this.courier,
    this.eta,
  });

  factory Order.fromJson(JsonMap json) => _$OrderFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;

  /// `IMB-24821`
  @JsonKey(fromJson: parseString)
  final String number;
  @JsonKey(fromJson: parseString)
  final String checkoutId;
  @JsonKey(readValue: _readShopParty)
  final OrderParty shop;
  @JsonKey(readValue: _readBuyerParty)
  final OrderParty buyer;
  @JsonKey(defaultValue: OrderStatus.pendingConfirmation, unknownEnumValue: OrderStatus.pendingConfirmation)
  final OrderStatus status;
  @JsonKey(defaultValue: <OrderItem>[])
  final List<OrderItem> items;
  @JsonKey(fromJson: parseInt)
  final int deliveryFee;
  @JsonKey(fromJson: parseInt)
  final int discount;
  @JsonKey(fromJson: parseIntOrNull)
  final int? commission;
  @JsonKey(fromJson: parseIntOrNull)
  final int? sellerNet;
  @JsonKey(unknownEnumValue: DeliveryMode.home)
  final DeliveryMode deliveryMode;

  /// "demain 8h–12h"
  final String? deliverySlot;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
  final DateTime? acceptBefore;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime createdAt;
  final List<OrderEvent> events;
  final String? address;
  @JsonKey(unknownEnumValue: PaymentMethod.mvola)
  final PaymentMethod paymentMethod;

  /// `payments.status` (PENDING, HELD, RELEASED, REFUNDED, FAILED).
  @JsonKey(fromJson: parseString)
  final String paymentStatus;
  final Courier? courier;

  /// "Arrivée 10h – 11h"
  final String? eta;

  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get total => subtotal + deliveryFee - discount;
  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// "Brèdes mafana ×3 · Tomates 2 kg"
  String get itemsSummary => items
      .map((i) => i.quantityLabel != null ? '${i.productName} ${i.quantityLabel}' : '${i.productName} ×${i.quantity}')
      .join(' · ');

  DateTime? eventDate(OrderStatus s) {
    for (final e in events) {
      if (e.status == s) return e.createdAt;
    }
    return null;
  }

  Order copyWith({OrderStatus? status, List<OrderEvent>? events}) => Order(
        id: id,
        number: number,
        checkoutId: checkoutId,
        shop: shop,
        buyer: buyer,
        status: status ?? this.status,
        items: items,
        deliveryFee: deliveryFee,
        discount: discount,
        commission: commission,
        sellerNet: sellerNet,
        deliveryMode: deliveryMode,
        deliverySlot: deliverySlot,
        acceptBefore: acceptBefore,
        createdAt: createdAt,
        events: events ?? this.events,
        address: address,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        courier: courier,
        eta: eta,
      );

  JsonMap toJson() => _$OrderToJson(this);
}

/// The API sends the counterparts flat (`shopName`, `shopSlug`,
/// `buyerName`); the mock data embeds `shop` / `buyer` objects.
Object? _readShopParty(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'name': json['shopName'], 'slug': json['shopSlug']};

Object? _readBuyerParty(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'name': json['buyerName']};
