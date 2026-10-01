import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography: **Bricolage Grotesque** for titles (600–800),
/// **Figtree** for text (400–700).
abstract class AppTypography {
  /// Tests switch this off so no font is fetched over the network.
  static bool useGoogleFonts = true;

  static const String displayFamily = 'Bricolage Grotesque';
  static const String bodyFamily = 'Figtree';

  /// `font-variant-numeric: tabular-nums` (prices, quantities).
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextStyle display({
    double size = 22,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) {
    return _font(
      displayFamily,
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFeatures: fontFeatures,
      ),
    );
  }

  static TextStyle body({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    List<FontFeature>? fontFeatures,
  }) {
    return _font(
      bodyFamily,
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        decorationColor: color,
        fontFeatures: fontFeatures,
      ),
    );
  }

  /// Uppercase group label ("MON COMPTE", "AUJOURD’HUI"…).
  static TextStyle overline({Color color = AppColors.muted}) =>
      body(size: 12, weight: FontWeight.w700, color: color, letterSpacing: 0.72);

  // Common presets -----------------------------------------------------------
  static TextStyle get pageTitle =>
      display(size: 28, weight: FontWeight.w700, letterSpacing: -0.56);
  static TextStyle get headerTitle => display(size: 22, weight: FontWeight.w700);
  static TextStyle get sectionTitle =>
      display(size: 22, weight: FontWeight.w700, letterSpacing: -0.22);
  static TextStyle get label => body(size: 14, weight: FontWeight.w600);
  static TextStyle get caption => body(size: 12, color: AppColors.muted);

  static TextStyle _font(String family, TextStyle style) {
    if (!useGoogleFonts) return style.copyWith(fontFamily: family);
    try {
      return GoogleFonts.getFont(family, textStyle: style);
    } catch (_) {
      return style.copyWith(fontFamily: family);
    }
  }

  static TextTheme textTheme() {
    return TextTheme(
      displayLarge: display(size: 56, weight: FontWeight.w800, letterSpacing: -1.9),
      displayMedium: display(size: 48, weight: FontWeight.w800, letterSpacing: -1.4),
      displaySmall: display(size: 34, weight: FontWeight.w800, letterSpacing: -0.7),
      headlineLarge: display(size: 30, weight: FontWeight.w800, letterSpacing: -0.6),
      headlineMedium: display(size: 28, weight: FontWeight.w700, letterSpacing: -0.56),
      headlineSmall: display(size: 22, weight: FontWeight.w700),
      titleLarge: display(size: 20, weight: FontWeight.w700),
      titleMedium: body(size: 17, weight: FontWeight.w700),
      titleSmall: body(size: 15, weight: FontWeight.w700),
      bodyLarge: body(size: 16),
      bodyMedium: body(size: 15),
      bodySmall: body(size: 13, color: AppColors.muted),
      labelLarge: body(size: 15, weight: FontWeight.w700),
      labelMedium: body(size: 13, weight: FontWeight.w600),
      labelSmall: body(size: 11, weight: FontWeight.w700),
    );
  }
}
