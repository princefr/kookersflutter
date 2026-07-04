// Tests for the Haptics utility (FEATURE_PROPOSALS.md §8.1).
//
// Verifies that the enabled flag gates calls correctly. We can't
// actually verify the native haptic fires in a unit test, but we can
// verify that calls don't throw and that disabling haptics short-
// circuits the Future.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/UI/Haptics.dart';

void main() {
  setUp(() {
    // Haptics.enabled is a global; reset between tests.
    Haptics.enabled = true;
    // Initialize the binding so HapticFeedback doesn't blow up.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  test('light / medium / heavy / selection / success do not throw',
      () async {
    await Haptics.light();
    await Haptics.medium();
    await Haptics.heavy();
    await Haptics.selection();
    await Haptics.success();
  });

  test('all methods are no-ops when Haptics.enabled == false', () async {
    Haptics.enabled = false;

    // We can't observe the underlying HapticFeedback call, but we can
    // verify the methods return immediately without throwing.
    expect(Haptics.light(), completes);
    expect(Haptics.medium(), completes);
    expect(Haptics.heavy(), completes);
    expect(Haptics.selection(), completes);
    expect(Haptics.success(), completes);
  });

  test('success() fires two impacts (heavy + light) sequentially',
      () async {
    // Time the call — success should take at least 80ms (the delay
    // between the heavy and light impacts).
    final stopwatch = Stopwatch()..start();
    await Haptics.success();
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(80));
  });

  test('disabled success() returns immediately', () async {
    Haptics.enabled = false;
    final stopwatch = Stopwatch()..start();
    await Haptics.success();
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(50));
  });
}
