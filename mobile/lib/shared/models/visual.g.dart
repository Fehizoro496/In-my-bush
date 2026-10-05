// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visual.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Visual _$VisualFromJson(Map<String, dynamic> json) => Visual(
  tint: json['tint'] == null ? '#F4F0E6' : parseString(json['tint']),
  ink: json['ink'] == null ? '#5B4526' : parseString(json['ink']),
  icon: json['icon'] == null ? 'leaf' : parseString(json['icon']),
);

Map<String, dynamic> _$VisualToJson(Visual instance) => <String, dynamic>{
  'tint': instance.tint,
  'ink': instance.ink,
  'icon': instance.icon,
};
