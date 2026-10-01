// Small, forgiving JSON readers used by the hand-written `fromJson`
// factories (no code generation in this project).


typedef JsonMap = Map<String, dynamic>;

int readInt(Object? value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? readIntOrNull(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double readDouble(Object? value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  return fallback;
}

bool readBool(Object? value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is num) return value != 0;
  return fallback;
}

String readString(Object? value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

String? readStringOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

DateTime? readDate(Object? value) {
  if (value is String) return DateTime.tryParse(value)?.toLocal();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return null;
}

JsonMap readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, v) => MapEntry(key.toString(), v));
  return <String, dynamic>{};
}

List<T> readList<T>(Object? value, T Function(JsonMap json) fromJson) {
  if (value is! List) return <T>[];
  return value.whereType<Map<dynamic, dynamic>>().map((e) => fromJson(readMap(e))).toList();
}

List<String> readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((e) => e.toString()).toList();
}

/// Removes `null` values before sending a body to the API.
JsonMap compactJson(JsonMap json) {
  json.removeWhere((key, value) => value == null);
  return json;
}
