// Forgiving parsers for json_serializable: `@JsonKey(fromJson: parseInt)`.
//
// The API may send a number as a string, omit a field or send `null`: these
// functions never throw, they fall back to a neutral value (or to `null` for
// the `…OrNull` variants, used on nullable fields).

import 'json.dart';

int parseInt(Object? value) => readInt(value);

int? parseIntOrNull(Object? value) => readIntOrNull(value);

double parseDouble(Object? value) => readDouble(value);

double? parseDoubleOrNull(Object? value) => value == null ? null : readDouble(value);

bool parseBool(Object? value) => readBool(value);

String parseString(Object? value) => readString(value);

List<String> parseStringList(Object? value) => readStringList(value);

/// ISO-8601 timestamp of the API (UTC) → local time, `null` when absent.
DateTime? parseDate(Object? value) => readDate(value);

/// Same as [parseDate] for mandatory dates: falls back to now.
DateTime parseDateOrNow(Object? value) => readDate(value) ?? DateTime.now();

/// Local [DateTime] → ISO-8601 UTC timestamp (`toJson` side of [parseDate]).
String? dateToJson(DateTime? value) => value?.toUtc().toIso8601String();
