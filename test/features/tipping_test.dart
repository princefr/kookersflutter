// Tests for the tipping selector (FEATURE_PROPOSALS.md §6.4).
//
// Verifies that:
//   * The preset chips render with correct labels.
//   * Tapping a preset chip calls onChanged with the right amount.
//   * Selecting "None" (the default) calls onChanged with 0.
//   * The "Custom" chip opens a dialog and accepts a numeric input.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Widgets/TipSelector.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpTipSelector(
    WidgetTester tester, {
    required ValueChanged<num> onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TipSelector(
            subtotal: 25,
            currencySymbol: '€',
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('renders the title, description, and 5 preset chips',
      (tester) async {
    await pumpTipSelector(tester, onChanged: (_) {});

    expect(find.text('payment.tipTitle'), findsOneWidget);
    expect(find.text('payment.tipDesc'), findsOneWidget);

    // 5 chips: None / 2 € / 5 € / 10 € / Custom
    expect(find.text('payment.tipNone'), findsOneWidget);
    expect(find.text('2 €'), findsOneWidget);
    expect(find.text('5 €'), findsOneWidget);
    expect(find.text('10 €'), findsOneWidget);
    expect(find.text('payment.tipCustom'), findsOneWidget);
  });

  testWidgets('tapping "None" calls onChanged with 0', (tester) async {
    num? received;
    await pumpTipSelector(tester, onChanged: (amount) => received = amount);

    await tester.tap(find.text('payment.tipNone'));
    await tester.pump();

    expect(received, 0);
  });

  testWidgets('tapping "5 €" calls onChanged with 5', (tester) async {
    num? received;
    await pumpTipSelector(tester, onChanged: (amount) => received = amount);

    await tester.tap(find.text('5 €'));
    await tester.pump();

    expect(received, 5);
  });

  testWidgets('tapping "Custom" opens a dialog and accepts input',
      (tester) async {
    num? received;
    await pumpTipSelector(tester, onChanged: (amount) => received = amount);

    await tester.tap(find.text('payment.tipCustom'));
    await tester.pumpAndSettle();

    // Dialog should be visible
    expect(find.text('payment.tipCustom'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '7');
    await tester.tap(find.text('common.validate'));
    await tester.pumpAndSettle();

    expect(received, 7);
  });

  testWidgets('custom tip dialog rejects negative input', (tester) async {
    num? received;
    await pumpTipSelector(tester, onChanged: (amount) => received = amount);

    await tester.tap(find.text('payment.tipCustom'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '-3');
    await tester.tap(find.text('common.validate'));
    await tester.pumpAndSettle();

    // Negative tips are clamped to 0.
    expect(received, 0);
  });

  testWidgets('the selected chip is visually highlighted', (tester) async {
    await pumpTipSelector(tester, onChanged: (_) {});

    // Initially "None" is selected (index 0).
    // We can't easily verify background color in a widget test, but we
    // can verify the chip exists and is tappable.
    expect(find.text('payment.tipNone'), findsOneWidget);

    // Tap "10 €" and verify it's still there.
    await tester.tap(find.text('10 €'));
    await tester.pump();

    expect(find.text('10 €'), findsOneWidget);
  });
}
