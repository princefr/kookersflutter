import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] that gives every haptic in the
/// app a single, named call site. Centralising this means we can later
/// gate them behind a user setting ("Settings → Haptics") without
/// touching every screen.
///
/// Usage:
///   Haptics.light();   // like button, chip tap
///   Haptics.medium();  // add to cart, open sheet
///   Haptics.heavy();   // order confirmed, sign-out
///   Haptics.selection();  // sort dropdown, toggle change
abstract class Haptics {
  Haptics._();

  /// Default to enabled. The setting in `Settings` flips this.
  static bool enabled = true;

  static Future<void> light() async {
    if (!enabled) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (!enabled) return;
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
  }

  static Future<void> selection() async {
    if (!enabled) return;
    await HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    if (!enabled) return;
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }
}
