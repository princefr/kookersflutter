// Tests for the SortDropdown widget + PublicationSort enum
// (FEATURE_PROPOSALS.md §2.5).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Widgets/SortDropdown.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  group('PublicationSort enum', () {
    test('has exactly 5 values', () {
      expect(PublicationSort.values.length, 5);
    });

    test('every value has a unique labelKey under "sort."', () {
      final keys = PublicationSort.values.map((s) => s.labelKey).toSet();
      expect(keys.length, 5);
      for (final k in keys) {
        expect(k.startsWith('sort.'), isTrue);
      }
    });

    test('labelKeys are well-formed (lowerCamelCase)', () {
      for (final sort in PublicationSort.values) {
        // sort.newest, sort.trending, sort.topRated, sort.priceAsc,
        // sort.priceDesc
        expect(sort.labelKey, matches(r'^sort\.[a-z]+([A-Z][a-z]+)*$'));
      }
    });
  });

  group('SortDropdown widget', () {
    Future<void> pumpDropdown(
      WidgetTester tester, {
      required PublicationSort current,
      required ValueChanged<PublicationSort> onChanged,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SortDropdown(current: current, onChanged: onChanged),
          ),
        ),
      );
    }

    testWidgets('renders the current sort label', (tester) async {
      await pumpDropdown(
        tester,
        current: PublicationSort.topRated,
        onChanged: (_) {},
      );
      expect(find.text('sort.topRated'), findsOneWidget);
    });

    testWidgets('tapping opens a popup menu with all 5 options',
        (tester) async {
      await pumpDropdown(
        tester,
        current: PublicationSort.newest,
        onChanged: (_) {},
      );

      // Tap the chip to open the popup.
      await tester.tap(find.byType(PopupMenuButton<PublicationSort>));
      await tester.pumpAndSettle();

      // All 5 labels should now be visible.
      expect(find.text('sort.newest'), findsWidgets);
      expect(find.text('sort.trending'), findsOneWidget);
      expect(find.text('sort.topRated'), findsOneWidget);
      expect(find.text('sort.priceAsc'), findsOneWidget);
      expect(find.text('sort.priceDesc'), findsOneWidget);
    });

    testWidgets('selecting an option calls onChanged', (tester) async {
      PublicationSort? selected;
      await pumpDropdown(
        tester,
        current: PublicationSort.newest,
        onChanged: (s) => selected = s,
      );

      await tester.tap(find.byType(PopupMenuButton<PublicationSort>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('sort.priceDesc').last);
      await tester.pumpAndSettle();

      expect(selected, PublicationSort.priceDesc);
    });
  });
}
