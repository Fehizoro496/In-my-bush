// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  id: parseString(json['id']),
  label: json['label'] == null ? 'Autre' : parseString(json['label']),
  recipient: parseString(json['recipient']),
  phone: parseString(json['phone']),
  line1: parseString(json['line1']),
  district: parseString(json['district']),
  city: parseString(json['city']),
  landmark: json['landmark'] == null ? '' : parseString(json['landmark']),
  isDefault: json['isDefault'] == null ? false : parseBool(json['isDefault']),
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'id': instance.id,
  'label': instance.label,
  'recipient': instance.recipient,
  'phone': instance.phone,
  'line1': instance.line1,
  'district': instance.district,
  'city': instance.city,
  'landmark': instance.landmark,
  'isDefault': instance.isDefault,
};
