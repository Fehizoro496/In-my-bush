import 'package:flutter/material.dart';

/// `space` tokens (px).
abstract class AppSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double s20 = 80;

  /// Horizontal page gutter used by every mobile screen.
  static const double gutter = 16;
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: gutter);
}

/// `radius` tokens (px) + the extra radii used by the mockups.
abstract class AppRadius {
  static const double sm = 9;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;

  static const double input = 10;
  static const double button = 14;
  static const double card = 18;
  static const double sheet = 24;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
}

/// `size` tokens.
abstract class AppSizes {
  static const double touchTarget = 44;
  static const double buttonHeight = 52;
  static const double inputHeight = 48;
  static const double mobileTabBar = 84;
}

abstract class AppShadows {
  /// 0 1px 2px rgba(31,35,24,0.04)
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A1F2318), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// 0 2px 8px rgba(31,35,24,0.12)
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F1F2318), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// 0 1px 3px rgba(31,35,24,0.1) — selected segment.
  static const List<BoxShadow> segment = [
    BoxShadow(color: Color(0x1A1F2318), blurRadius: 3, offset: Offset(0, 1)),
  ];

  /// 0 -6px 20px rgba(31,35,24,0.06) — sticky bottom bars.
  static const List<BoxShadow> bottomBar = [
    BoxShadow(color: Color(0x0F1F2318), blurRadius: 20, offset: Offset(0, -6)),
  ];

  /// 0 6px 16px rgba(92,145,32,0.35) — raised "Vendre" button.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(color: Color(0x595C9120), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// 0 10px 28px rgba(31,35,24,0.2) — toasts.
  static const List<BoxShadow> toast = [
    BoxShadow(color: Color(0x331F2318), blurRadius: 28, offset: Offset(0, 10)),
  ];

  /// 0 0 0 4px rgba(140,198,63,0.25) — focus ring.
  static const List<BoxShadow> focusRing = [
    BoxShadow(color: Color(0x408CC63F), spreadRadius: 4),
  ];
}
