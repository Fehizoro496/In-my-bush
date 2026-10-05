// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_look.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvatarLook _$AvatarLookFromJson(Map<String, dynamic> json) => AvatarLook(
  initials: parseString(json['initials']),
  color: json['color'] == null ? '#4A7A12' : parseString(json['color']),
);

Map<String, dynamic> _$AvatarLookToJson(AvatarLook instance) =>
    <String, dynamic>{'initials': instance.initials, 'color': instance.color};
