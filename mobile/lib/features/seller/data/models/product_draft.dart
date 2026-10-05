import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';

part 'product_draft.g.dart';

/// Draft of the add / edit product form.
@JsonSerializable(createFactory: false)
class ProductDraft {
  const ProductDraft({
    this.id,
    this.name = '',
    this.categoryPath = '',
    this.description = '',
    this.price,
    this.unitLabel = 'Botte',
    this.stock,
    this.lowStockThreshold,
    this.origin = '',
    this.homeDelivery = true,
    this.pickup = true,
    this.nationalShipping = false,
    this.visible = true,
  });

  final String? id;
  final String name;
  final String categoryPath;
  final String description;
  final int? price;
  final String unitLabel;
  final int? stock;
  final int? lowStockThreshold;
  @JsonKey(name: 'originRegion')
  final String origin;
  final bool homeDelivery;
  final bool pickup;
  final bool nationalShipping;
  final bool visible;

  JsonMap toJson() => _$ProductDraftToJson(this);
}
