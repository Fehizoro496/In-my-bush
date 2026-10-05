// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: parseString(json['id']),
  number: parseString(json['number']),
  shop: OrderParty.fromJson(
    _readShopParty(json, 'shop') as Map<String, dynamic>,
  ),
  buyer: OrderParty.fromJson(
    _readBuyerParty(json, 'buyer') as Map<String, dynamic>,
  ),
  status:
      $enumDecodeNullable(
        _$OrderStatusEnumMap,
        json['status'],
        unknownValue: OrderStatus.pendingConfirmation,
      ) ??
      OrderStatus.pendingConfirmation,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  createdAt: parseDateOrNow(json['createdAt']),
  checkoutId: json['checkoutId'] == null ? '' : parseString(json['checkoutId']),
  deliveryFee: json['deliveryFee'] == null
      ? 3000
      : parseInt(json['deliveryFee']),
  discount: json['discount'] == null ? 0 : parseInt(json['discount']),
  commission: parseIntOrNull(json['commission']),
  sellerNet: parseIntOrNull(json['sellerNet']),
  deliveryMode:
      $enumDecodeNullable(
        _$DeliveryModeEnumMap,
        json['deliveryMode'],
        unknownValue: DeliveryMode.home,
      ) ??
      DeliveryMode.home,
  deliverySlot: json['deliverySlot'] as String?,
  acceptBefore: parseDate(json['acceptBefore']),
  events:
      (json['events'] as List<dynamic>?)
          ?.map((e) => OrderEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  address: json['address'] as String?,
  paymentMethod:
      $enumDecodeNullable(
        _$PaymentMethodEnumMap,
        json['paymentMethod'],
        unknownValue: PaymentMethod.mvola,
      ) ??
      PaymentMethod.mvola,
  paymentStatus: json['paymentStatus'] == null
      ? ''
      : parseString(json['paymentStatus']),
  courier: json['courier'] == null
      ? null
      : Courier.fromJson(json['courier'] as Map<String, dynamic>),
  eta: json['eta'] as String?,
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'number': instance.number,
  'checkoutId': instance.checkoutId,
  'shop': instance.shop.toJson(),
  'buyer': instance.buyer.toJson(),
  'status': _$OrderStatusEnumMap[instance.status]!,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'deliveryFee': instance.deliveryFee,
  'discount': instance.discount,
  'commission': ?instance.commission,
  'sellerNet': ?instance.sellerNet,
  'deliveryMode': _$DeliveryModeEnumMap[instance.deliveryMode]!,
  'deliverySlot': ?instance.deliverySlot,
  'acceptBefore': ?dateToJson(instance.acceptBefore),
  'createdAt': ?dateToJson(instance.createdAt),
  'events': instance.events.map((e) => e.toJson()).toList(),
  'address': ?instance.address,
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
  'paymentStatus': instance.paymentStatus,
  'courier': ?instance.courier?.toJson(),
  'eta': ?instance.eta,
};

const _$OrderStatusEnumMap = {
  OrderStatus.pendingConfirmation: 'PENDING_CONFIRMATION',
  OrderStatus.accepted: 'ACCEPTED',
  OrderStatus.prepared: 'PREPARED',
  OrderStatus.inDelivery: 'IN_DELIVERY',
  OrderStatus.delivered: 'DELIVERED',
  OrderStatus.refused: 'REFUSED',
  OrderStatus.cancelled: 'CANCELLED',
};

const _$DeliveryModeEnumMap = {
  DeliveryMode.home: 'HOME',
  DeliveryMode.pickup: 'PICKUP',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.mvola: 'MVOLA',
  PaymentMethod.orangeMoney: 'ORANGE_MONEY',
  PaymentMethod.airtelMoney: 'AIRTEL_MONEY',
  PaymentMethod.card: 'CARD',
  PaymentMethod.cashOnDelivery: 'CASH_ON_DELIVERY',
};
