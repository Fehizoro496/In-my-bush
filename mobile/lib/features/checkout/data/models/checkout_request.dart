import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../orders/data/models/models.dart';

part 'checkout_request.g.dart';

@JsonSerializable(createFactory: false)
class CheckoutRequest {
  const CheckoutRequest({
    required this.addressId,
    required this.deliveryMode,
    required this.slot,
    required this.paymentMethod,
    this.phone,
    this.promoCode,
  });

  /// Empty for a pick-up: not sent.
  @JsonKey(toJson: _emptyToNull)
  final String addressId;
  final DeliveryMode deliveryMode;

  @JsonKey(name: 'deliverySlot')
  final String slot;
  final PaymentMethod paymentMethod;

  @JsonKey(name: 'paymentPhone')
  final String? phone;

  /// Promo codes are not handled by the API yet: not sent.
  @JsonKey(includeToJson: false)
  final String? promoCode;

  JsonMap toJson() => _$CheckoutRequestToJson(this);
}

String? _emptyToNull(String value) => value.isEmpty ? null : value;
