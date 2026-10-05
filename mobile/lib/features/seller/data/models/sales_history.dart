import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'sale_record.dart';
import 'sales_bar.dart';

part 'sales_history.g.dart';

@JsonSerializable(createToJson: false)
class SalesHistory {
  const SalesHistory({
    required this.gross,
    required this.commission,
    required this.net,
    required this.bars,
    required this.records,
  });

  factory SalesHistory.fromJson(JsonMap json) => _$SalesHistoryFromJson(json);

  @JsonKey(fromJson: parseInt)
  final int gross;
  @JsonKey(fromJson: parseInt)
  final int commission;
  @JsonKey(fromJson: parseInt)
  final int net;
  final List<SalesBar> bars;
  final List<SaleRecord> records;
}
