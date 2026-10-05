import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/visual.dart';
import '../../../orders/data/models/models.dart' show PaymentMethod;

part 'saved_payment_method.g.dart';

/// Saved payment method (buyer) — Mobile Money wallet or card.
@JsonSerializable()
class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.method,
    required this.label,
    required this.detail,
    this.isDefault = false,
  });

  factory SavedPaymentMethod.fromJson(JsonMap json) => _$SavedPaymentMethodFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(defaultValue: PaymentMethod.mvola, unknownEnumValue: PaymentMethod.mvola)
  final PaymentMethod method;
  @JsonKey(readValue: _readPaymentLabel, fromJson: parseString)
  final String label;

  /// "+261 34 •• ••• 12", "•••• 4242 · exp. 08/28"
  @JsonKey(readValue: _readPaymentDetail, fromJson: parseString)
  final String detail;
  @JsonKey(fromJson: parseBool)
  final bool isDefault;

  Visual get look => method == PaymentMethod.card
      ? const Visual(tint: '#E8F1FA', ink: '#22527E', icon: 'card')
      : const Visual(tint: '#FFF4E8', ink: '#B4500A', icon: 'wallet');

  JsonMap toJson() => _$SavedPaymentMethodToJson(this);
}

/// The wallet name is the default label of a payout method.
Object? _readPaymentLabel(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? PaymentMethod.fromApi(json['method']).label;

/// Payout methods expose `phoneMasked` ("+261 34 •• ••• 12").
Object? _readPaymentDetail(Map<dynamic, dynamic> json, String key) => json['phoneMasked'] ?? json[key] ?? '';
