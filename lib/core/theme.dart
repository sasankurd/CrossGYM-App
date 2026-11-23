import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Space Grotesk for headings, Inter for body, JetBrains Mono for numbers.
ThemeData buildTheme(AnimeTheme t) {
  final scheme = ColorScheme.dark(
    primary: t.primary,
    onPrimary: AppColors.canvas,
    secondary: t.secondary,
    onSecondary: AppColors.canvas,
    surface: AppColors.card,
    onSurface: AppColors.text,
    surfaceContainerHighest: AppColors.inputRaised,
    error: AppColors.rose,
    outline: AppColors.gray400,
    outlineVariant: AppColors.hairline,
  );

  final inter = GoogleFonts.interTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  ).apply(bodyColor: AppColors.text, displayColor: AppColors.text);

  TextStyle? grotesk(TextStyle? s, FontWeight w) => s == null
      ? null
      : GoogleFonts.spaceGrotesk(
          textStyle: s,
          fontWeight: w,
          letterSpacing: (s.fontSize ?? 14) * -0.02,
        );

  final text = inter.copyWith(
    displayLarge: grotesk(inter.displayLarge, FontWeight.w800),
    displayMedium: grotesk(inter.displayMedium, FontWeight.w800),
    displaySmall: grotesk(inter.displaySmall, FontWeight.w800),
    headlineLarge: grotesk(inter.headlineLarge, FontWeight.w800),
    headlineMedium: grotesk(inter.headlineMedium, FontWeight.w800),
    headlineSmall: grotesk(inter.headlineSmall, FontWeight.w800),
    titleLarge: grotesk(inter.titleLarge, FontWeight.w700),
    titleMedium: grotesk(inter.titleMedium, FontWeight.w700),
  );

  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: AppColors.container,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.hairline),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.input,
      border: border(AppColors.hairline),
      enabledBorder: border(AppColors.hairline),
      focusedBorder: border(t.primary),
      labelStyle: const TextStyle(color: AppColors.gray400),
      hintStyle: const TextStyle(color: AppColors.gray400),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.primary,
        foregroundColor: AppColors.canvas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        minimumSize: const Size(0, 44),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.hairlineStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        minimumSize: const Size(0, 44),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: t.primary,
      foregroundColor: AppColors.canvas,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.primary,
      linearTrackColor: AppColors.hairline,
      linearMinHeight: 6,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.hairline, space: 1),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.hairlineStrong),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.hairline),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.inputRaised,
      contentTextStyle: const TextStyle(color: AppColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
