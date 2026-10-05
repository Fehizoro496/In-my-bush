import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';

part 'sales_bar.g.dart';

@JsonSerializable(createToJson: false)
class SalesBar {
  const SalesBar({required this.label, required this.value, this.valueLabel});

  factory SalesBar.fromJson(JsonMap json) => _$SalesBarFromJson(json);

  @JsonKey(fromJson: parseString)
  final String label;

  /// Amount in Ariary.
  @JsonKey(fromJson: parseInt)
  final int value;

  /// "1,24" (millions) on the history chart.
  final String? valueLabel;
}
