// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paginated<T> _$PaginatedFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Paginated<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  page: json['page'] == null ? 0 : parseInt(json['page']),
  size: json['size'] == null ? 20 : parseInt(json['size']),
  totalItems: json['totalItems'] == null ? 0 : parseInt(json['totalItems']),
  totalPages: json['totalPages'] == null ? 1 : parseInt(json['totalPages']),
);
