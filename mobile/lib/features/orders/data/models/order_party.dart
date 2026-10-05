import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/avatar_look.dart';

part 'order_party.g.dart';

/// Counterpart summary (shop for the buyer, buyer for the seller).
@JsonSerializable()
class OrderParty {
  const OrderParty({required this.id, required this.name, required this.avatar, this.slug = '', this.meta});

  factory OrderParty.fromJson(JsonMap json) => _$OrderPartyFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  @JsonKey(fromJson: parseString)
  final String name;
  @JsonKey(fromJson: parseString)
  final String slug;
  @JsonKey(readValue: _readPartyAvatar)
  final AvatarLook avatar;

  /// "Cliente depuis 2025 · 6 commandes"
  final String? meta;

  JsonMap toJson() => _$OrderPartyToJson(this);
}

/// Counterparts have no avatar: initials of the name.
Object? _readPartyAvatar(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'initials': initialsOf(readString(json['name']))};
