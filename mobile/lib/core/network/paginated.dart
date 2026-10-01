import 'dart:math' as math;

import '../utils/json.dart';

/// `{ items, page, size, totalItems, totalPages }` from the API.
class Paginated<T> {
  const Paginated({
    required this.items,
    this.page = 0,
    this.size = 20,
    this.totalItems = 0,
    this.totalPages = 1,
  });

  factory Paginated.fromJson(JsonMap json, T Function(JsonMap json) itemFromJson) {
    final items = readList(json['items'], itemFromJson);
    return Paginated<T>(
      items: items,
      page: readInt(json['page']),
      size: readInt(json['size'], 20),
      totalItems: readInt(json['totalItems'], items.length),
      totalPages: readInt(json['totalPages'], 1),
    );
  }

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
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;

  bool get hasMore => page + 1 < totalPages;
}
