// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderEvent _$OrderEventFromJson(Map<String, dynamic> json) => OrderEvent(
  status: $enumDecode(
    _$OrderStatusEnumMap,
    json['status'],
    unknownValue: OrderStatus.pendingConfirmation,
  ),
  createdAt: parseDateOrNow(json['createdAt']),
  note: json['note'] as String?,
);

Map<String, dynamic> _$OrderEventToJson(OrderEvent instance) =>
    <String, dynamic>{
      'status': _$OrderStatusEnumMap[instance.status]!,
      'note': ?instance.note,
      'createdAt': ?dateToJson(instance.createdAt),
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
