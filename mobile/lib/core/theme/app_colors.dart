import 'package:flutter/material.dart';

/// Colors from `docs/design-tokens.json` (keep the three copies in sync:
/// tokens JSON, web `tokens.css` and this file), plus a few tints used by
/// the mockups that are not tokenised yet (grouped under "Mockup extras").
abstract class AppColors {
  // Pomme (primary)
  static const Color pomme50 = Color(0xFFF4FAE8);
  static const Color pomme100 = Color(0xFFF0F6E6);
  static const Color pomme200 = Color(0xFFDDEBC9);
  static const Color pomme300 = Color(0xFFCFE89E);
  static const Color pomme500 = Color(0xFF8CC63F);
  static const Color pomme600 = Color(0xFF74AE2C);
  static const Color pomme700 = Color(0xFF4A7A12);
  static const Color pomme800 = Color(0xFF365A10);
  static const Color pomme900 = Color(0xFF1F3608);

  // Orange (secondary, promos, count badges)
  static const Color orange50 = Color(0xFFFFF4E8);
  static const Color orange100 = Color(0xFFFFF1E0);
  static const Color orange200 = Color(0xFFFEE4C7);
  static const Color orange300 = Color(0xFFFBC98F);
  static const Color orange500 = Color(0xFFF28C28);
  static const Color orange600 = Color(0xFFD86F12);
  static const Color orange700 = Color(0xFFB4500A);
  static const Color orange800 = Color(0xFF8A3D06);
  static const Color orange900 = Color(0xFF3A1E05);

  // Neutrals
  static const Color bg = Color(0xFFFBFAF6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color sand = Color(0xFFF4F0E6);
  static const Color line = Color(0xFFEAE6DB);
  static const Color lineStrong = Color(0xFFE6E2D6);
  static const Color divider = Color(0xFFF1EEE5);
  static const Color disabled = Color(0xFFA3A094);
  static const Color muted = Color(0xFF66655B);
  static const Color body = Color(0xFF4A4A42);
  static const Color ink = Color(0xFF1F2318);

  // Feedback
  static const Color infoBg = Color(0xFFE8F1FA);
  static const Color infoFg = Color(0xFF22527E);
  static const Color infoStrong = Color(0xFF2F6DA8);
  static const Color successBg = Color(0xFFEAF4DA);
  static const Color successFg = Color(0xFF365A10);
  static const Color dangerBg = Color(0xFFFDECEA);
  static const Color dangerBorder = Color(0xFFE6B8B3);
  static const Color dangerFg = Color(0xFFC0352B);

  static const Color onPrimary = Color(0xFF1F3608);
  static const Color onSecondary = Color(0xFF3A1E05);

  // Mockup extras
  static const Color pommeSelected = Color(0xFFE6F3CC);
  static const Color pommeLight = Color(0xFFB2DA6A);
  static const Color pommeDeep = Color(0xFF2A4A0C);
  static const Color pommeMist = Color(0xFFD6E4C2);
  static const Color pommeInk = Color(0xFF22380A);
  static const Color switchOff = Color(0xFFD8D3C4);
  static const Color lineDashed = Color(0xFFC9C4B5);
  static const Color bodyStrong = Color(0xFF33342C);
  static const Color skeleton = Color(0xFFEFECE3);
  static const Color skeletonHighlight = Color(0xFFF8F6F0);
  static const Color chatBg = Color(0xFFF6F4EE);
  static const Color chatDate = Color(0xFFEDEAE1);
  static const Color dangerSoft = Color(0xFFFCEBE9);
  static const Color orangeInk = Color(0xFF6B3208);
  static const Color orangeBorderStrong = Color(0xFFF7AA5A);
  static const Color mapBg = Color(0xFFEEF3E4);
  static const Color mapPatch = Color(0xFFDCEBC6);

  /// rgba(31,35,24,0.5) — modal barrier.
  static const Color scrim = Color(0x801F2318);

  /// rgba(255,255,255,0.94) — floating buttons over photos.
  static const Color glass = Color(0xF0FFFFFF);

  /// rgba(255,255,255,0.97) — tab bar background.
  static const Color tabBarBg = Color(0xF7FFFFFF);
}

/// Parses `#RRGGBB` / `#AARRGGBB` strings (mock "photo" tints, API colors).
Color hexColor(String hex, {Color fallback = AppColors.sand}) {
  var value = hex.replaceFirst('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}
