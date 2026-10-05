import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/visual.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.unitLabel,
    required this.quantity,
    this.productSlug = '',
    this.visual = const Visual(),
    this.quantityLabel,
  });

  factory OrderItem.fromJson(JsonMap json) => _$OrderItemFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(fromJson: parseString)
  final String productId;
  @JsonKey(fromJson: parseString)
  final String productSlug;
  @JsonKey(fromJson: parseString)
  final String productName;
  @JsonKey(fromJson: parseInt)
  final int unitPrice;
  @JsonKey(fromJson: parseString)
  final String unitLabel;
  @JsonKey(defaultValue: 1, fromJson: parseInt)
  final int quantity;
  final Visual visual;

  /// Custom quantity text ("1 kg", "2 bottes").
  final String? quantityLabel;

  int get lineTotal => unitPrice * quantity;

  /// "2 × 18 000 Ar"
  String get quantityText => quantityLabel ?? '$quantity × ${formatAriary(unitPrice)}';

  JsonMap toJson() => _$OrderItemToJson(this);
}
