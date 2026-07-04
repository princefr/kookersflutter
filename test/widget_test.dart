// Basic smoke tests for the Kookers theme + UI tokens.
//
// (The previous test referenced a `MyApp` class and a "counter" widget
// that no longer exist, so it failed to compile. These tests do not
// require a Firebase project — they exercise pure UI code only.)

import 'dart:convert';
import 'dart:io';

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

  group('Translations', () {
    final locales = ['fr', 'en', 'it', 'de', 'es', 'tr'];

    /// Returns the set of "dotted paths" of every leaf in a JSON map, e.g.
    /// `{"a": {"b": 1}}` → `{"a.b"}`. Used to compare structure across
    /// locales — if one locale is missing a key the others have, the
    /// diff is obvious.
    Set<String> flattenKeys(Map<String, dynamic> map, [String prefix = '']) {
      final out = <String>{};
      map.forEach((key, value) {
        final path = prefix.isEmpty ? key : '$prefix.$key';
        if (value is Map<String, dynamic>) {
          out.addAll(flattenKeys(value, path));
        } else {
          out.add(path);
        }
      });
      return out;
    }

    test('all six locale files exist and parse as JSON', () {
      for (final loc in locales) {
        final file = File('assets/translations/$loc.json');
        expect(file.existsSync(), isTrue, reason: 'missing $loc.json');
        expect(() => jsonDecode(file.readAsStringSync()), returnsNormally,
            reason: '$loc.json is not valid JSON');
      }
    });

    test('all locales expose the same set of keys', () {
      final reference = flattenKeys(
          jsonDecode(File('assets/translations/fr.json').readAsStringSync())
              as Map<String, dynamic>);
      for (final loc in locales) {
        final keys = flattenKeys(
            jsonDecode(File('assets/translations/$loc.json').readAsStringSync())
                as Map<String, dynamic>);
        expect(keys, reference, reason: '$loc.json keys differ from fr.json');
      }
    });

    test('critical nav keys are translated in every locale', () {
      const mustHave = [
        'nav.home',
        'nav.orders',
        'nav.vendor',
        'nav.messages',
        'nav.settings',
        'onboarding.skip',
        'onboarding.start',
        'settings.signOut',
      ];
      for (final loc in locales) {
        final map = jsonDecode(
                File('assets/translations/$loc.json').readAsStringSync())
            as Map<String, dynamic>;
        for (final key in mustHave) {
          // Walk the dotted path
          dynamic node = map;
          for (final part in key.split('.')) {
            node = (node as Map<String, dynamic>)[part];
          }
          expect(node, isA<String>(),
              reason: '$loc.json missing or non-string: $key');
          expect((node as String).isNotEmpty, isTrue,
              reason: '$loc.json has empty value for: $key');
        }
      }
    });
  });
}
