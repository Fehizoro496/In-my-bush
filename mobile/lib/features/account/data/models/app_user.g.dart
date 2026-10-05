// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: parseString(json['id']),
  firstName: parseString(json['firstName']),
  lastName: parseString(json['lastName']),
  phone: parseString(json['phone']),
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)
          ?.map(
            (e) =>
                $enumDecode(_$UserRoleEnumMap, e, unknownValue: UserRole.buyer),
          )
          .toSet() ??
      const {UserRole.buyer},
  city: json['city'] == null ? '' : parseString(json['city']),
  district: json['district'] == null ? '' : parseString(json['district']),
  createdAt: parseDate(json['createdAt']),
  phoneVerified: json['phoneVerified'] == null
      ? false
      : parseBool(json['phoneVerified']),
  emailVerified: json['emailVerified'] == null
      ? false
      : parseBool(json['emailVerified']),
  avatarColor: json['avatarColor'] == null
      ? '#365A10'
      : parseString(json['avatarColor']),
  shopName: json['shopName'] as String?,
  shopSlug: json['shopSlug'] as String?,
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'phone': instance.phone,
  'email': ?instance.email,
  'avatarUrl': ?instance.avatarUrl,
  'roles': instance.roles.map((e) => _$UserRoleEnumMap[e]!).toList(),
  'city': instance.city,
  'district': instance.district,
  'createdAt': ?dateToJson(instance.createdAt),
  'phoneVerified': instance.phoneVerified,
  'emailVerified': instance.emailVerified,
  'avatarColor': instance.avatarColor,
  'shopName': ?instance.shopName,
  'shopSlug': ?instance.shopSlug,
};

const _$UserRoleEnumMap = {
  UserRole.buyer: 'BUYER',
  UserRole.seller: 'SELLER',
  UserRole.admin: 'ADMIN',
};
