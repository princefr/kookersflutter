// Tests for the empty-state CTAs (FEATURE_PROPOSALS.md §8.4).
//
// Verifies that EmptyView and EmptyViewElse:
//   * Render the title and subtitle.
//   * Render the CTA button only when both ctaLabel and onCtaTap are
//     provided.
//   * Call onCtaTap when the button is pressed.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Widgets/EmptyView.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  group('EmptyView', () {
    testWidgets('renders default title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyView())),
      );

      expect(find.text('empty.homeTitle'), findsOneWidget);
      expect(find.text('empty.homeSubtitle'), findsOneWidget);
    });

    testWidgets('renders custom title and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 'custom.title',
              subtitle: 'custom.subtitle',
            ),
          ),
        ),
      );

      expect(find.text('custom.title'), findsOneWidget);
      expect(find.text('custom.subtitle'), findsOneWidget);
    });

    testWidgets('does NOT render a CTA when ctaLabel is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 't',
              subtitle: 's',
              onCtaTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('does NOT render a CTA when onCtaTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 't',
              subtitle: 's',
              ctaLabel: 'Browse',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('renders CTA button when both ctaLabel and onCtaTap are set',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 't',
              subtitle: 's',
              ctaLabel: 'Browse',
              onCtaTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Browse'), findsOneWidget);
    });

    testWidgets('tapping the CTA calls onCtaTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              title: 't',
              subtitle: 's',
              ctaLabel: 'Browse',
              onCtaTap: () => tapped++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, 1);
    });
  });

  group('EmptyViewElse', () {
    testWidgets('renders the text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyViewElse(text: 'No items')),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('renders CTA when both ctaLabel and onCtaTap are set',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyViewElse(
              text: 'No items',
              ctaLabel: 'Browse',
              onCtaTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('tapping the CTA calls onCtaTap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyViewElse(
              text: 'No items',
              ctaLabel: 'Browse',
              onCtaTap: () => tapped++,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(tapped, 1);
    });
  });
}
