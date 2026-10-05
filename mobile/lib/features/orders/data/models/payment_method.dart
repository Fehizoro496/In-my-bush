import 'package:json_annotation/json_annotation.dart';


/// `payments.method` (+ card, shown by the checkout mockup).
@JsonEnum(valueField: 'apiName')
enum PaymentMethod {
  mvola('MVOLA', 'MVola'),
  orangeMoney('ORANGE_MONEY', 'Orange Money'),
  airtelMoney('AIRTEL_MONEY', 'Airtel Money'),
  card('CARD', 'Carte bancaire'),
  cashOnDelivery('CASH_ON_DELIVERY', 'Paiement à la réception');

  const PaymentMethod(this.apiName, this.label);

  final String apiName;
  final String label;

  bool get isMobileMoney =>
      this == PaymentMethod.mvola || this == PaymentMethod.orangeMoney || this == PaymentMethod.airtelMoney;

  /// "Mobile Money" for the three wallets.
  String get family => isMobileMoney ? 'Mobile Money' : label;

  static PaymentMethod fromApi(Object? value) =>
      PaymentMethod.values.firstWhere((m) => m.apiName == value, orElse: () => PaymentMethod.mvola);
}
