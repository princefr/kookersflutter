import 'package:flutter/material.dart';

/// Centralised Kookers brand palette.
///
/// The codebase previously sprinkled raw hex values
/// (`Color(0xFFF95F5F)`, `Colors.black`, `Colors.grey[400]`, ...)
/// across every screen. That made it impossible to retheme the app
/// and produced inconsistent shades of grey/red from one widget to
/// the next. Everything visible should reference these tokens.
abstract class KookersColors {
  KookersColors._();

  /// Brand coral — used for primary CTAs, active tab, FAB.
  static const Color primary = Color(0xFFF95F5F);

  /// Slightly deeper coral for pressed / focused states.
  static const Color primaryDark = Color(0xFFE04C4C);

  /// Soft coral tint — used for chips, subtle highlights, onboarding dots.
  static const Color primarySoft = Color(0xFFFFE9E9);

  /// Body / heading text on light backgrounds.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary copy (captions, helper text).
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Disabled / hint text.
  static const Color textMuted = Color(0xFF9A9A9A);

  /// App background.
  static const Color background = Color(0xFFFFFFFF);

  /// Card / list-item background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Off-white used behind grouped sections.
  static const Color surfaceAlt = Color(0xFFF6F6F8);

  /// Hairline borders and dividers.
  static const Color border = Color(0xFFE6E6EA);

  /// Used for "go" / confirm actions.
  static const Color success = Color(0xFF2ECC71);

  /// Destructive actions (sign out, delete, report).
  static const Color danger = Color(0xFFE74C3C);

  /// Notification badges, hearts.
  static const Color badge = Color(0xFFFF3B30);
}
