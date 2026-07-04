// Continuous localization lint test.
//
// Scans every .dart file under lib/ for `'foo.bar'.tr()` style calls
// and asserts that every key it finds actually exists in
// assets/translations/fr.json. This catches typos like
// `'setting.language'.tr()` (missing 's') at PR time instead of letting
// them ship and render as the raw key in production.
//
// The test also asserts that no .dart file contains obvious hardcoded
// French copy in user-visible widgets (Text/Title/hintText/...) so the
// i18n work doesn't regress.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libDir = Directory('lib');
  final frJson =
      jsonDecode(File('assets/translations/fr.json').readAsStringSync())
          as Map<String, dynamic>;

  /// Flatten a nested map into a set of dotted-leaf paths.
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

  final knownKeys = flattenKeys(frJson);

  /// Regex matching `'section.key'.tr()` calls.
  /// Captures the dotted key inside the quotes.
  final trCallRegex = RegExp(r"""'([a-z][a-z0-9_]*(?:\.[a-z0-9_]+)+)'\.tr\(\)""",
      caseSensitive: false);

  /// Regex matching obvious hardcoded French strings in user-visible
  /// widgets. False-positive risk is high, so we keep this strict:
  /// only matches `Text("...")` / `Text('...')` with at least 3 chars
  /// of accented or specifically French content.
  final hardcodedRegex =
      RegExp(r"""(Text|title|hintText|labelText|buttonText|errorText|"""
          r"""loadingText|successText|infoText|message|subtitle|caption|"""
          r"""label|tooltip|placeholder|header)\s*:\s*"""
          r"""["']([A-ZÀ-Ý][a-zA-ZÀ-ÿ]{2,}(\s+[a-zA-ZÀ-ÿ]+)*)["']""");

  test('every .tr() key used in lib/ exists in fr.json', () {
    final failures = <String>[];
    final checkedFiles = <String>[];

    for (final file in libDir.recursive.toList().whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      checkedFiles.add(file.path);

      final source = file.readAsStringSync();
      for (final match in trCallRegex.allMatches(source)) {
        final key = match.group(1)!;
        if (!knownKeys.contains(key)) {
          failures.add('${file.path}: unknown .tr() key "$key"');
        }
      }
    }

    expect(checkedFiles, isNotEmpty,
        reason: 'sanity check: should have scanned at least one file');
    expect(failures, isEmpty,
        reason:
            'Found .tr() calls referencing unknown keys:\n${failures.join('\n')}');
  });

  test('no obvious hardcoded French strings remain in lib/', () {
    final failures = <String>[];

    for (final file in libDir.recursive.toList().whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;

      final source = file.readAsStringSync();
      final lines = source.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().startsWith('//')) continue;
        if (line.contains('.tr(')) continue;

        for (final match in hardcodedRegex.allMatches(line)) {
          final captured = match.group(2)!;
          // Allow obvious English-only non-translatables: "Kookers"
          // brand name, "TabHome", test-only strings.
          if (captured == 'Kookers' || captured == 'TabHome') continue;
          // Allow URL fragments
          if (captured.startsWith('http')) continue;
          failures.add(
              '${file.path}:${i + 1}: hardcoded string "$captured"');
        }
      }
    }

    expect(failures, isEmpty,
        reason:
            'Found possible hardcoded user-visible strings (use .tr() instead):\n${failures.take(20).join('\n')}');
  });
}
