import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/json.dart';

/// Placeholder "photo" look used by the mockups (a tinted square with an
/// icon). Products, categories and shops fall back to it when they have no
/// image URL. Optional on the API side (`visual: { tint, ink, icon }`).
@immutable
class Visual {
  const Visual({this.tint = '#F4F0E6', this.ink = '#5B4526', this.icon = 'leaf'});

  factory Visual.fromJson(JsonMap json) => Visual(
        tint: readString(json['tint'], '#F4F0E6'),
        ink: readString(json['ink'], '#5B4526'),
        icon: readString(json['icon'], 'leaf'),
      );

  /// Hex colors, e.g. `#F6E3D6`.
  final String tint;
  final String ink;

  /// Icon key from [AppIcons.byKey].
  final String icon;

  Color get tintColor => hexColor(tint);
  Color get inkColor => hexColor(ink, fallback: AppColors.body);

  Visual copyWith({String? tint, String? ink, String? icon}) =>
      Visual(tint: tint ?? this.tint, ink: ink ?? this.ink, icon: icon ?? this.icon);

  JsonMap toJson() => {'tint': tint, 'ink': ink, 'icon': icon};
}

/// Avatar look for shops / people (initials on a colored disc).
@immutable
class AvatarLook {
  const AvatarLook({required this.initials, this.color = '#4A7A12'});

  factory AvatarLook.fromJson(JsonMap json) => AvatarLook(
        initials: readString(json['initials'], '?'),
        color: readString(json['color'], '#4A7A12'),
      );

  final String initials;
  final String color;

  Color get colorValue => hexColor(color, fallback: AppColors.pomme700);

  JsonMap toJson() => {'initials': initials, 'color': color};
}
