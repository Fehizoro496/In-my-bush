import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/json.dart';
import '../../core/utils/parsers.dart';

part 'visual.g.dart';

/// Placeholder "photo" look used by the mockups (a tinted square with an
/// icon). Products, categories and shops fall back to it when they have no
/// image URL. Optional on the API side (`visual: { tint, ink, icon }`).
@immutable
@JsonSerializable()
class Visual {
  const Visual({this.tint = '#F4F0E6', this.ink = '#5B4526', this.icon = 'leaf'});

  factory Visual.fromJson(JsonMap json) => _$VisualFromJson(json);

  /// Hex colors, e.g. `#F6E3D6`.
  @JsonKey(fromJson: parseString)
  final String tint;
  @JsonKey(fromJson: parseString)
  final String ink;

  /// Icon key from [AppIcons.byKey].
  @JsonKey(fromJson: parseString)
  final String icon;

  Color get tintColor => hexColor(tint);
  Color get inkColor => hexColor(ink, fallback: AppColors.body);

  Visual copyWith({String? tint, String? ink, String? icon}) =>
      Visual(tint: tint ?? this.tint, ink: ink ?? this.ink, icon: icon ?? this.icon);

  JsonMap toJson() => _$VisualToJson(this);
}
