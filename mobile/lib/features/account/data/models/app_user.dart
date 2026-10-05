import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import 'user_role.dart';

part 'app_user.g.dart';

@JsonSerializable()
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.roles = const {UserRole.buyer},
    this.city = '',
    this.district = '',
    this.createdAt,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.avatarColor = '#365A10',
    this.shopName,
    this.shopSlug,
  });

  factory AppUser.fromJson(JsonMap json) => _$AppUserFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(fromJson: parseString)
  final String firstName;
  @JsonKey(fromJson: parseString)
  final String lastName;
  @JsonKey(fromJson: parseString)
  final String phone;
  final String? email;
  final String? avatarUrl;
  @JsonKey(unknownEnumValue: UserRole.buyer)
  final Set<UserRole> roles;
  @JsonKey(fromJson: parseString)
  final String city;
  @JsonKey(fromJson: parseString)
  final String district;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: parseBool)
  final bool phoneVerified;
  @JsonKey(fromJson: parseBool)
  final bool emailVerified;
  @JsonKey(fromJson: parseString)
  final String avatarColor;
  final String? shopName;
  final String? shopSlug;

  String get fullName => '$firstName $lastName'.trim();
  String get initials => initialsOf(fullName);
  bool get isSeller => roles.contains(UserRole.seller);

  /// "Acheteur & vendeur · Analakely"
  String get roleLine => '${isSeller ? 'Acheteur & vendeur' : 'Acheteur'}${district.isEmpty ? '' : ' · $district'}';

  /// "+261 34 •• ••• 12"
  String get maskedPhone {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return phone;
    final local = digits.startsWith('261') ? digits.substring(3) : digits;
    final prefix = local.length >= 2 ? local.substring(0, 2) : local;
    return '+261 $prefix •• ••• ${local.substring(local.length - 2)}';
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? city,
    Set<UserRole>? roles,
    String? shopName,
    String? shopSlug,
  }) =>
      AppUser(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone,
        email: email ?? this.email,
        avatarUrl: avatarUrl,
        roles: roles ?? this.roles,
        city: city ?? this.city,
        district: district,
        createdAt: createdAt,
        phoneVerified: phoneVerified,
        emailVerified: emailVerified,
        avatarColor: avatarColor,
        shopName: shopName ?? this.shopName,
        shopSlug: shopSlug ?? this.shopSlug,
      );

  JsonMap toJson() => _$AppUserToJson(this);
}
