import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/avatar_look.dart';
import '../../../../shared/models/visual.dart';

part 'shop.g.dart';

/// Shop summary / profile (`shops`).
@JsonSerializable()
class Shop {
  const Shop({
    required this.id,
    required this.name,
    required this.slug,
    required this.avatar,
    this.description = '',
    this.region = '',
    this.city = '',
    this.logoUrl,
    this.coverUrl,
    this.cover = const Visual(tint: '#E6F3CC', ink: '#365A10'),
    this.status = 'ACTIVE',
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.productCount = 0,
    this.createdAt,
    this.verified = true,
    this.responseTime,
    this.distanceKm,
    this.tags = const [],
    this.ringColor,
    this.pickup = false,
    this.deliveryNote,
    this.ownerId,
  });

  factory Shop.fromJson(JsonMap json) => _$ShopFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  final String? ownerId;
  @JsonKey(fromJson: parseString)
  final String name;
  @JsonKey(fromJson: parseString)
  final String slug;
  @JsonKey(fromJson: parseString)
  final String description;
  @JsonKey(fromJson: parseString)
  final String region;
  @JsonKey(fromJson: parseString)
  final String city;
  final String? logoUrl;
  final String? coverUrl;
  final Visual cover;
  @JsonKey(readValue: _readShopAvatar)
  final AvatarLook avatar;
  @JsonKey(fromJson: parseString)
  final String status;
  @JsonKey(fromJson: parseDouble)
  final double ratingAvg;
  @JsonKey(fromJson: parseInt)
  final int ratingCount;
  @JsonKey(fromJson: parseInt)
  final int productCount;
  @JsonKey(fromJson: parseDate, toJson: dateToJson)
  final DateTime? createdAt;
  @JsonKey(fromJson: parseBool)
  final bool verified;
  final String? responseTime;
  @JsonKey(fromJson: parseIntOrNull)
  final int? distanceKm;
  @JsonKey(fromJson: parseStringList)
  final List<String> tags;
  final String? ringColor;
  @JsonKey(fromJson: parseBool)
  final bool pickup;
  final String? deliveryNote;

  /// "Antsirabe, Vakinankaratra"
  String get location => region.isEmpty ? city : (city.isEmpty ? region : '$city, $region');

  String get since => createdAt == null ? '' : '${createdAt!.year}';

  JsonMap toJson() => _$ShopToJson(this);
}

/// Shops have no avatar: initials of the name.
Object? _readShopAvatar(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'initials': initialsOf(readString(json['name']))};
