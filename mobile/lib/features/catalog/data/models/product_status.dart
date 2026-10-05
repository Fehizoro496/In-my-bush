import 'package:json_annotation/json_annotation.dart';


/// `products.status`
@JsonEnum(valueField: 'apiName')
enum ProductStatus {
  draft('DRAFT', 'Brouillon'),
  pendingReview('PENDING_REVIEW', 'En relecture'),
  published('PUBLISHED', 'En ligne'),
  rejected('REJECTED', 'Refusé'),
  archived('ARCHIVED', 'Archivé');

  const ProductStatus(this.apiName, this.label);

  final String apiName;
  final String label;

  static ProductStatus fromApi(Object? value) =>
      ProductStatus.values.firstWhere((s) => s.apiName == value, orElse: () => ProductStatus.published);
}
