import 'package:json_annotation/json_annotation.dart';


/// `PURCHASE` = "Mes achats" (J’achète), `SALE` = "Mes ventes" (Je vends).
@JsonEnum(valueField: 'apiName')
enum MessageContext {
  purchase('PURCHASE'),
  sale('SALE');

  const MessageContext(this.apiName);

  final String apiName;

  static MessageContext fromApi(Object? v) => v == 'SALE' ? MessageContext.sale : MessageContext.purchase;
}
