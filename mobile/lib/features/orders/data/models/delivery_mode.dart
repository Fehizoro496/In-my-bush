import 'package:json_annotation/json_annotation.dart';


@JsonEnum(valueField: 'apiName')
enum DeliveryMode {
  home('HOME', 'Livraison à domicile', 'Domicile'),
  pickup('PICKUP', 'Retrait chez les producteurs', 'Retrait');

  const DeliveryMode(this.apiName, this.label, this.shortLabel);

  final String apiName;
  final String label;
  final String shortLabel;

  static DeliveryMode fromApi(Object? value) =>
      DeliveryMode.values.firstWhere((m) => m.apiName == value, orElse: () => DeliveryMode.home);
}
