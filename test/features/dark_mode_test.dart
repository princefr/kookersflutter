// Tests for the dark-mode theme system.
//
// Verifies that KookersTheme.dark exists, exposes the expected tokens,
// and that ThemeController parses / persists / resolves the user's
// preference correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:kookers/UI/ThemeController.dart';

void main() {
  group('KookersTheme.dark', () {
    test('exposes Material 3 dark scheme', () {
      final theme = KookersTheme.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    test('scaffoldBackgroundColor is the dark background token', () {
      expect(KookersTheme.dark.scaffoldBackgroundColor,
          KookersColorsDark.background);
    });

    test('primary stays coral — brand must be consistent across modes', () {
      expect(KookersTheme.dark.primaryColor, KookersColors.primary);
    });

    test('bottom nav theme uses dark surface and brand-coral selection', () {
      final bnbt = KookersTheme.dark.bottomNavigationBarTheme;
      expect(bnbt.backgroundColor, KookersColorsDark.surface);
      expect(bnbt.selectedItemColor, KookersColors.primary);
    });
  });

  group('KookersThemeMode', () {
    test('parses valid mode names', () {
      expect(
          KookersThemeMode.values
              .where((m) => m.name == 'system')
              .first,
          KookersThemeMode.system);
      expect(
          KookersThemeMode.values.where((m) => m.name == 'dark').first,
          KookersThemeMode.dark);
      expect(
          KookersThemeMode.values.where((m) => m.name == 'light').first,
          KookersThemeMode.light);
    });

    test('toMaterialThemeMode maps correctly', () {
      expect(KookersThemeMode.system.toMaterialThemeMode(), ThemeMode.system);
      expect(KookersThemeMode.light.toMaterialThemeMode(), ThemeMode.light);
      expect(KookersThemeMode.dark.toMaterialThemeMode(), ThemeMode.dark);
    });

    test('every mode has a translation key', () {
      for (final mode in KookersThemeMode.values) {
        expect(mode.label, isNotEmpty);
        expect(mode.label.startsWith('themeMode.'), isTrue);
      }
    });
  });

  group('ThemeController', () {
    test('default value is system', () {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      expect(controller.value, KookersThemeMode.system);
    });

    test('set() updates the value', () async {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      // We skip load() so no SharedPreferences access happens.
      await controller.set(KookersThemeMode.dark);
      expect(controller.value, KookersThemeMode.dark);
    });

    test('resolve() picks dark theme when mode is dark', () {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      controller.value = KookersThemeMode.dark;
      final theme = controller.resolve(Brightness.light);
      expect(theme.brightness, Brightness.dark);
    });

    test('resolve() picks light theme when mode is light', () {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      controller.value = KookersThemeMode.light;
      final theme = controller.resolve(Brightness.dark);
      expect(theme.brightness, Brightness.light);
    });

    test('resolve() follows platform brightness when mode is system', () {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      expect(controller.value, KookersThemeMode.system);

      final darkTheme = controller.resolve(Brightness.dark);
      expect(darkTheme.brightness, Brightness.dark);

      final lightTheme = controller.resolve(Brightness.light);
      expect(lightTheme.brightness, Brightness.light);
    });

    testWidgets('notifies listeners on change', (tester) async {
      final controller = ThemeController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      await controller.set(KookersThemeMode.dark);
      await tester.pump();
      expect(notifications, greaterThan(0));
    });
  });
}
