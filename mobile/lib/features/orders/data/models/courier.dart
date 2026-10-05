import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/avatar_look.dart';

part 'courier.g.dart';

@JsonSerializable()
class Courier {
  const Courier({required this.name, required this.avatar, this.vehicle = 'Moto', this.distance});

  factory Courier.fromJson(JsonMap json) => _$CourierFromJson(json);

  @JsonKey(fromJson: parseString)
  final String name;
  @JsonKey(readValue: _readPartyAvatar)
  final AvatarLook avatar;
  @JsonKey(fromJson: parseString)
  final String vehicle;
  final String? distance;

  JsonMap toJson() => _$CourierToJson(this);
}

/// Counterparts have no avatar: initials of the name.
Object? _readPartyAvatar(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'initials': initialsOf(readString(json['name']))};
