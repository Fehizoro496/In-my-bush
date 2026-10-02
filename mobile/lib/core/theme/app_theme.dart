import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.pomme500,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.pommeSelected,
      onPrimaryContainer: AppColors.pomme800,
      secondary: AppColors.orange500,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.orange100,
      onSecondaryContainer: AppColors.orange800,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.muted,
      error: AppColors.dangerFg,
      onError: Colors.white,
      outline: AppColors.lineStrong,
      outlineVariant: AppColors.line,
    );

    final textTheme = AppTypography.textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      highlightColor: const Color(0x0A1F2318),
      splashColor: const Color(0x141F2318),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1, space: 1),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.pomme700,
        selectionColor: AppColors.pomme300,
        selectionHandleColor: AppColors.pomme600,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.pomme600),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.body(size: 14, color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.all(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pomme500,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.all(AppRadius.button)),
          textStyle: AppTypography.body(size: 16, weight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pomme700,
          textStyle: AppTypography.body(size: 14, weight: FontWeight.w700),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
