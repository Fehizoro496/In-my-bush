import 'dart:math' as math;

import 'package:json_annotation/json_annotation.dart';

import '../utils/json.dart';
import '../utils/parsers.dart';

part 'paginated.g.dart';

/// `{ items, page, size, totalItems, totalPages }` from the API.
@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class Paginated<T> {
  const Paginated({
    required this.items,
    this.page = 0,
    this.size = 20,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  factory Paginated.fromJson(JsonMap json, T Function(Object? json) fromJsonT) => _$PaginatedFromJson(json, fromJsonT);

  /// Local pagination (used by the mock repositories).
  factory Paginated.slice(List<T> all, {int page = 0, int size = 20}) {
    final start = math.min(math.max(page * size, 0), all.length);
    final end = math.min(start + size, all.length);
    return Paginated<T>(
      items: all.sublist(start, end),
      page: page,
      size: size,
      totalItems: all.length,
      totalPages: all.isEmpty ? 1 : (all.length / size).ceil(),
    );
  }

  final List<T> items;
  @JsonKey(fromJson: parseInt)
  final int page;
  @JsonKey(fromJson: parseInt)
  final int size;
  @JsonKey(fromJson: parseInt)
  final int totalItems;
  @JsonKey(fromJson: parseInt)
  final int totalPages;

  bool get hasMore => page + 1 < totalPages;
}
