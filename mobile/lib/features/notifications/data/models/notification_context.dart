import 'package:json_annotation/json_annotation.dart';


@JsonEnum(valueField: 'apiName')
enum NotificationContext {
  purchase('PURCHASE'),
  sale('SALE'),
  system('SYSTEM');

  const NotificationContext(this.apiName);

  final String apiName;

  static NotificationContext fromApi(Object? v) =>
      NotificationContext.values.firstWhere((c) => c.apiName == v, orElse: () => NotificationContext.system);
}
