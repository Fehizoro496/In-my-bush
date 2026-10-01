import 'package:dio/dio.dart';

import '../utils/json.dart';

/// Error raised by the API layer, built from an RFC 7807
/// `application/problem+json` body when there is one.
class ApiException implements Exception {
  const ApiException({
    required this.title,
    this.status,
    this.detail,
    this.type,
    this.fieldErrors = const {},
  });

  /// Parses a problem+json body: `{ type, title, status, detail, errors }`.
  factory ApiException.fromProblem(JsonMap json, {int? status}) {
    final errors = <String, String>{};
    final rawErrors = json['errors'] ?? json['invalidParams'] ?? json['fieldErrors'];
    if (rawErrors is Map) {
      rawErrors.forEach((key, value) => errors[key.toString()] = value.toString());
    } else if (rawErrors is List) {
      for (final item in rawErrors.whereType<Map<dynamic, dynamic>>()) {
        final map = readMap(item);
        final field = readString(map['field'] ?? map['name']);
        if (field.isNotEmpty) errors[field] = readString(map['message'] ?? map['reason']);
      }
    }
    return ApiException(
      status: readIntOrNull(json['status']) ?? status,
      title: readString(json['title'], 'Erreur'),
      detail: readStringOrNull(json['detail']),
      type: readStringOrNull(json['type']),
      fieldErrors: errors,
    );
  }

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    if (data is Map) {
      return ApiException.fromProblem(readMap(data), status: response?.statusCode);
    }
    final type = error.type;
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const ApiException(
        title: 'Délai dépassé',
        detail: 'Le serveur met trop de temps à répondre. Réessayez.',
      );
    }
    if (type == DioExceptionType.connectionError) {
      return const ApiException(
        title: 'Hors connexion',
        detail: 'Vérifiez votre connexion internet puis réessayez.',
      );
    }
    if (type == DioExceptionType.cancel) {
      return const ApiException(title: 'Requête annulée');
    }
    return ApiException(
      status: response?.statusCode,
      title: 'Erreur ${response?.statusCode ?? ''}'.trim(),
      detail: 'Une erreur inattendue est survenue.',
    );
  }

  final int? status;
  final String title;
  final String? detail;
  final String? type;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => status == 401;
  bool get isNotFound => status == 404;

  /// Human readable message for snackbars and error states.
  String get message => detail ?? title;

  @override
  String toString() => 'ApiException($status, $title${detail != null ? ': $detail' : ''})';
}
