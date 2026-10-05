import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'order_status.dart';

part 'order_event.g.dart';

@JsonSerializable()
class OrderEvent {
  const OrderEvent({required this.status, required this.createdAt, this.note});

  factory OrderEvent.fromJson(JsonMap json) => _$OrderEventFromJson(json);

  @JsonKey(unknownEnumValue: OrderStatus.pendingConfirmation)
  final OrderStatus status;
  final String? note;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime createdAt;

  JsonMap toJson() => _$OrderEventToJson(this);
}
