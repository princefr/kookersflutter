import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Colors.dart';

/// Single source of truth for the Kookers visual language.
///
/// Before this file, every screen rebuilt the same `GoogleFonts.montserrat`
/// styles, hand-rolled `Color(0xFFF95F5F)` buttons, and styled its own
/// `BottomNavigationBar`. That produced visible drift between screens
/// (different greys, different font weights, different corner radii).
///
/// Usage:
///   GetMaterialApp(
///     theme: KookersTheme.light,
///     ...
///   )
///
/// Then read `Theme.of(context)` in widgets — no more hard-coded hex.
class KookersTheme {
  KookersTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).copyWith(
      headlineMedium: GoogleFonts.montserrat(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: KookersColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: KookersColors.textPrimary,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: KookersColors.textPrimary,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: KookersColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: KookersColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: KookersColors.textPrimary,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: KookersColors.textSecondary,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: KookersColors.textPrimary,
      ),
    );

    return base.copyWith(
      useMaterial3: true,
      primaryColor: KookersColors.primary,
      scaffoldBackgroundColor: KookersColors.background,
      canvasColor: KookersColors.background,
      dividerColor: KookersColors.border,
      textTheme: textTheme,
      colorScheme: base.colorScheme.copyWith(
        primary: KookersColors.primary,
        secondary: KookersColors.primary,
        error: KookersColors.danger,
        surface: KookersColors.surface,
        background: KookersColors.background,
        onPrimary: Colors.white,
        onSurface: KookersColors.textPrimary,
        onBackground: KookersColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KookersColors.background,
        foregroundColor: KookersColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: KookersColors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KookersColors.surface,
        selectedItemColor: KookersColors.primary,
        unselectedItemColor: KookersColors.textMuted,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KookersColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: KookersColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KookersColors.primarySoft,
        labelStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: KookersColors.primaryDark,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KookersColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KookersColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KookersColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KookersColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KookersColors.primary,
          textStyle: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Layout constants used across screens to keep spacing consistent.
abstract class KookersSpacing {
  KookersSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Screen-edge horizontal padding (matches iOS HIG ~16pt).
  static const double screenH = 16;
}
