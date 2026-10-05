import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';

part 'payout_summary.g.dart';

/// Seller payout info ("Pour recevoir mes ventes").
@JsonSerializable(createToJson: false)
class PayoutSummary {
  const PayoutSummary({required this.nextAmount, required this.nextDate, required this.destination});

  factory PayoutSummary.fromJson(JsonMap json) => _$PayoutSummaryFromJson(json);

  @JsonKey(fromJson: parseInt)
  final int nextAmount;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime nextDate;

  /// "MVola •• 12"
  @JsonKey(fromJson: parseString)
  final String destination;
}
