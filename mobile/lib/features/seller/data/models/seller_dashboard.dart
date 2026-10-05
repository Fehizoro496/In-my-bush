import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'sales_bar.dart';

part 'seller_dashboard.g.dart';

@JsonSerializable(createToJson: false)
class SellerDashboard {
  const SellerDashboard({
    required this.revenue,
    required this.trendPercent,
    required this.bars,
    required this.ordersReceived,
    required this.toPrepare,
    required this.activeProducts,
    required this.drafts,
    required this.lowStock,
    required this.ratingAvg,
    required this.ratingCount,
  });

  factory SellerDashboard.fromJson(JsonMap json) => _$SellerDashboardFromJson(json);

  @JsonKey(fromJson: parseInt)
  final int revenue;
  @JsonKey(fromJson: parseDouble)
  final double trendPercent;
  final List<SalesBar> bars;
  @JsonKey(fromJson: parseInt)
  final int ordersReceived;
  @JsonKey(fromJson: parseInt)
  final int toPrepare;
  @JsonKey(fromJson: parseInt)
  final int activeProducts;
  @JsonKey(fromJson: parseInt)
  final int drafts;
  @JsonKey(fromJson: parseInt)
  final int lowStock;
  @JsonKey(fromJson: parseDouble)
  final double ratingAvg;
  @JsonKey(fromJson: parseInt)
  final int ratingCount;
}
