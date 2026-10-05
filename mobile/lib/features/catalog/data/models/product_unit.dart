import 'package:json_annotation/json_annotation.dart';


/// `products.unit`
@JsonEnum(valueField: 'apiName')
enum ProductUnit {
  kg('KG', 'kg'),
  g('G', 'g'),
  l('L', 'litre'),
  piece('PIECE', 'pièce'),
  bunch('BUNCH', 'botte'),
  jar('JAR', 'pot'),
  pack('PACK', 'lot');

  const ProductUnit(this.apiName, this.label);

  final String apiName;
  final String label;

  static ProductUnit fromApi(Object? value) =>
      ProductUnit.values.firstWhere((u) => u.apiName == value, orElse: () => ProductUnit.piece);
}
