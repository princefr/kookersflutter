// Basic smoke tests for the Kookers theme + UI tokens.
//
// (The previous test referenced a `MyApp` class and a "counter" widget
// that no longer exist, so it failed to compile. These tests do not
// require a Firebase project — they exercise pure UI code only.)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';

void main() {
  group('KookersTheme', () {
    test('light theme exposes the brand coral as primaryColor', () {
      final theme = KookersTheme.light;
      expect(theme.primaryColor, KookersColors.primary);
    });

    test('light theme uses Material 3', () {
      expect(KookersTheme.light.useMaterial3, isTrue);
    });

    test('bottom nav theme flags unselected labels as visible', () {
      final bnbt = KookersTheme.light.bottomNavigationBarTheme;
      expect(bnbt.showUnselectedLabels, isTrue);
      expect(bnbt.type, BottomNavigationBarType.fixed);
    });
  });

  group('KookersColors', () {
    test('tokens are stable (do not regress by accident)', () {
      expect(KookersColors.primary.value, 0xFFF95F5F);
      expect(KookersColors.primaryDark.value, 0xFFE04C4C);
      expect(KookersColors.textPrimary.value, 0xFF1A1A1A);
      expect(KookersColors.background.value, 0xFFFFFFFF);
    });
  });
}
