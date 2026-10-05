import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/json.dart';
import '../../core/utils/parsers.dart';

part 'avatar_look.g.dart';

/// Avatar look for shops / people (initials on a colored disc).
@immutable
@JsonSerializable()
class AvatarLook {
  const AvatarLook({required this.initials, this.color = '#4A7A12'});

  factory AvatarLook.fromJson(JsonMap json) => _$AvatarLookFromJson(json);

  @JsonKey(fromJson: parseString)
  final String initials;
  @JsonKey(fromJson: parseString)
  final String color;

  Color get colorValue => hexColor(color, fallback: AppColors.pomme700);

  JsonMap toJson() => _$AvatarLookToJson(this);
}
