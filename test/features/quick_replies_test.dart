// Tests for the QuickReplies widget (FEATURE_PROPOSALS.md §5.1).

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kookers/Pages/Messages/QuickReplies.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  });

  group('QuickReplies widget', () {
    Future<void> pump(
      WidgetTester tester, {
      required ValueChanged<String> onPick,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: QuickReplies(onPick: onPick)),
        ),
      );
    }

    testWidgets('renders 4 quick-reply chips', (tester) async {
      await pump(tester, onPick: (_) {});

      expect(find.text('chat.quick.hello'), findsOneWidget);
      expect(find.text('chat.quick.askTime'), findsOneWidget);
      expect(find.text('chat.quick.askAvailability'), findsOneWidget);
      expect(find.text('chat.quick.thanks'), findsOneWidget);
    });

    testWidgets('tapping a chip calls onPick with the resolved text',
        (tester) async {
      String? picked;
      await pump(tester, onPick: (text) => picked = text);

      await tester.tap(find.text('chat.quick.thanks'));
      await tester.pump();

      // Without an active locale, .tr() returns the key itself.
      expect(picked, 'chat.quick.thanks');
    });

    testWidgets('all 4 chips are tappable ActionChips', (tester) async {
      await pump(tester, onPick: (_) {});
      expect(find.byType(ActionChip), findsNWidgets(4));
    });
  });
}
