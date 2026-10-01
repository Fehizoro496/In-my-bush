// Formatting helpers (Ariary amounts, French numbers and dates).
///
// Dates are formatted by hand (no locale data to initialise), so they work
/// identically in the app, in tests and in isolates.


/// `12000` → `"12 000 Ar"`, `-4250` → `"−4 250 Ar"`. Amounts are whole Ariary.
String formatAriary(num amount) => '${formatThousands(amount)} Ar';

/// `12000` → `"12 000"` (space as thousands separator, minus sign U+2212).
String formatThousands(num value) {
  final n = value.round();
  final digits = n.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return n < 0 ? '−$buffer' : buffer.toString();
}

/// `5860000` → `"5,86 M Ar"`, `1240000` → `"1,24 M Ar"`, `12000` → `"12 000 Ar"`.
String formatCompactAriary(num amount) {
  if (amount.abs() >= 1000000) {
    return '${formatDecimal(amount / 1000000, digits: 2)} M Ar';
  }
  return formatAriary(amount);
}

/// French decimal: `4.8` → `"4,8"`, `5` → `"5,0"` (with [digits] = 1).
String formatDecimal(num value, {int digits = 1}) {
  var text = value.toStringAsFixed(digits);
  if (digits > 1) {
    // Trim useless trailing zeros but keep at least one decimal: 1.20 → 1,2
    while (text.endsWith('0') && text.indexOf('.') < text.length - 2) {
      text = text.substring(0, text.length - 1);
    }
  }
  return text.replaceAll('.', ',');
}

/// Rating as displayed in the mockups: `4.9` → `"4,9"`.
String formatRating(num rating) => formatDecimal(rating, digits: 1);

/// `"+12 %"`, `"−20 %"`.
String formatPercent(num value, {bool signed = false}) {
  final rounded = value.round();
  final sign = rounded < 0 ? '−' : (signed && rounded > 0 ? '+' : '');
  return '$sign${rounded.abs()} %';
}

/// Promo label from price / compare-at price: 2400 vs 3000 → `"−20 %"`.
String? promoLabel(int price, int? compareAtPrice) {
  if (compareAtPrice == null || compareAtPrice <= price || compareAtPrice == 0) return null;
  final pct = ((compareAtPrice - price) * 100 / compareAtPrice).round();
  return '−$pct %';
}

/// Plural helper: `plural(3, 'article')` → `"3 articles"`.
String plural(int count, String singular, [String? pluralForm]) =>
    '$count ${count > 1 ? (pluralForm ?? '${singular}s') : singular}';

abstract class FrenchDates {
  static const List<String> months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  static const List<String> shortMonths = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  static const List<String> weekdays = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
  ];

  static const List<String> shortWeekdays = [
    'Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.',
  ];

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// `"26 sept."`
  static String dayMonth(DateTime d) => '${d.day} ${shortMonths[d.month - 1]}';

  /// `"26 septembre 2026"`
  static String longDate(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

  /// `"9h12"`, `"18h02"`, `"8h"` when minutes are 0 and [compact].
  static String hour(DateTime d, {bool compact = false}) =>
      compact && d.minute == 0 ? '${d.hour}h' : '${d.hour}h${_two(d.minute)}';

  /// `"9:28"` (message timestamps).
  static String clock(DateTime d) => '${d.hour}:${_two(d.minute)}';

  /// `"26 sept., 18h02"`
  static String dayMonthTime(DateTime d) => '${dayMonth(d)}, ${hour(d)}';

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static int daysBetween(DateTime from, DateTime to) =>
      _day(to).difference(_day(from)).inDays;

  static bool isSameDay(DateTime a, DateTime b) => daysBetween(a, b) == 0;

  /// Conversation / notification list: `"9:28"` today, `"Hier"`, `"Lun."`
  /// within a week, then `"26 sept."`.
  static String relativeShort(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final days = daysBetween(d, ref);
    if (days <= 0) return clock(d);
    if (days == 1) return 'Hier';
    if (days < 7) return shortWeekdays[d.weekday - 1];
    return dayMonth(d);
  }

  /// Relative day with time: `"Aujourd’hui, 9h32"`, `"Hier, 16h10"`,
  /// `"26 sept., 18h02"`.
  static String relativeDayTime(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final days = daysBetween(d, ref);
    if (days == 0) return 'Aujourd’hui, ${hour(d)}';
    if (days == 1) return 'Hier, ${hour(d)}';
    return dayMonthTime(d);
  }

  /// Relative day only: `"aujourd’hui"`, `"hier"`, `"24 sept."`.
  static String relativeDay(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final days = daysBetween(d, ref);
    if (days == 0) return 'aujourd’hui';
    if (days == 1) return 'hier';
    return dayMonth(d);
  }

  /// Reviews: `"il y a 3 j"`, `"il y a 2 sem."`, `"il y a 5 min"`.
  static String ago(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final diff = ref.difference(d);
    if (diff.inMinutes < 1) return 'à l’instant';
    if (diff.inHours < 1) return 'il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'il y a ${diff.inDays} j';
    if (diff.inDays < 31) return 'il y a ${diff.inDays ~/ 7} sem.';
    if (diff.inDays < 365) return 'il y a ${diff.inDays ~/ 30} mois';
    return 'il y a ${diff.inDays ~/ 365} an${diff.inDays >= 730 ? 's' : ''}';
  }

  /// Section header for grouped lists: `"Aujourd’hui"`, `"Cette semaine"`,
  /// `"Semaine dernière"`, `"Plus ancien"`.
  static String group(DateTime d, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final days = daysBetween(d, ref);
    if (days <= 0) return 'Aujourd’hui';
    if (days < 7) return 'Cette semaine';
    if (days < 14) return 'Semaine dernière';
    return 'Plus ancien';
  }
}

/// `"Hery Rakoto"` → `"HR"`.
String initialsOf(String name) {
  final parts = name
      .replaceAll(RegExp('[’\'.]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty && p[0].toUpperCase() != p[0].toLowerCase())
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

/// URL slug: `"Miel de litchi cru"` → `"miel-de-litchi-cru"`.
String slugify(String input) {
  const from = 'àáâäãåçèéêëìíîïñòóôöõùúûüýÿœæ’\'';
  const to = 'aaaaaaceeeeiiiinooooouuuuyyoa--';
  final buffer = StringBuffer();
  for (final char in input.toLowerCase().split('')) {
    final index = from.indexOf(char);
    buffer.write(index >= 0 ? to[index] : char);
  }
  return buffer
      .toString()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
