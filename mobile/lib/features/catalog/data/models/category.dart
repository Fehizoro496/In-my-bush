import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/json.dart';
import '../../../../core/utils/parsers.dart';
import '../../../../shared/models/visual.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.shortName,
    this.parentId,
    this.icon = 'leaf',
    this.position = 0,
    this.productCount = 0,
    this.visual = const Visual(),
    this.foreground,
  });

  factory Category.fromJson(JsonMap json) => _$CategoryFromJson(json);

  @JsonKey(fromJson: parseString)
  final String id;
  final String? parentId;
  @JsonKey(fromJson: parseString)
  final String name;

  /// Same category with the look of [preset] (the API only sends an icon).
  Category withLook(Category preset) => Category(
        id: id,
        parentId: parentId,
        name: name,
        shortName: shortName ?? preset.shortName,
        slug: slug,
        icon: icon,
        position: position,
        productCount: productCount,
        visual: preset.visual,
        foreground: foreground ?? preset.foreground,
      );

  /// Label used by the Home chips ("Laitiers" for "Produits laitiers").
  final String? shortName;
  @JsonKey(fromJson: parseString)
  final String slug;
  @JsonKey(fromJson: parseString)
  final String icon;
  @JsonKey(fromJson: parseInt)
  final int position;
  @JsonKey(fromJson: parseInt)
  final int productCount;
  @JsonKey(readValue: _readCategoryVisual)
  final Visual visual;

  /// Title color on the category tile (light text on dark tiles).
  final String? foreground;

  String get label => shortName ?? name;

  JsonMap toJson() => _$CategoryToJson(this);
}

/// Categories only carry an `icon`: it becomes the icon of the [Visual].
Object? _readCategoryVisual(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? <String, dynamic>{'icon': json['icon'] ?? 'leaf'};
