import 'package:json_annotation/json_annotation.dart';


@JsonEnum(valueField: 'apiName')
enum UserRole {
  buyer('BUYER'),
  seller('SELLER'),
  admin('ADMIN');

  const UserRole(this.apiName);

  final String apiName;

  static UserRole fromApi(Object? v) => UserRole.values.firstWhere((r) => r.apiName == v, orElse: () => UserRole.buyer);
}
