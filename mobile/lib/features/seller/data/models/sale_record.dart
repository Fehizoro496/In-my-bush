import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/visual.dart';
import 'payout_state.dart';

part 'sale_record.g.dart';

/// One line of "Historique des ventes".
@JsonSerializable(createToJson: false)
class SaleRecord {
  const SaleRecord({
    required this.orderId,
    required this.number,
    required this.client,
    required this.itemsSummary,
    required this.amount,
    required this.payout,
    required this.date,
    this.visual = const Visual(),
  });

  factory SaleRecord.fromJson(JsonMap json) => _$SaleRecordFromJson(json);

  @JsonKey(fromJson: parseString)
  final String orderId;
  @JsonKey(fromJson: parseString)
  final String number;
  @JsonKey(fromJson: parseString)
  final String client;
  @JsonKey(fromJson: parseString)
  final String itemsSummary;
  @JsonKey(fromJson: parseInt)
  final int amount;
  @JsonKey(name: 'paymentStatus', fromJson: PayoutState.fromPaymentStatus)
  final PayoutState payout;
  @JsonKey(fromJson: parseDateOrNow, toJson: dateToJson)
  final DateTime date;
  final Visual visual;
}
