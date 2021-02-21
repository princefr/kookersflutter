

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kookers/main.dart' as app;


Future<void> delay([int milliseconds = 250]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

void main(List<String> args) {
  
    group("Kookers App", () {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      // Process.run(executable, arguments)


      testWidgets("Kookers test", (tester) async {
        app.main();
        await tester.pumpAndSettle();

        delay(750);

        final onBoardingSkipButton = find.byKey(Key("OnBording_pass"));
        await tester.tap(onBoardingSkipButton);
        await tester.pumpAndSettle();

        delay(750);

        


        final phoneTextField = find.byKey(Key("phone_number"));
        final phoneValidationButton = find.byKey(Key("phoneValidationButton"));
        await tester.enterText(phoneTextField, "782798614");
        await tester.tap(phoneValidationButton);
        await tester.pumpAndSettle();

        // tester.enterText(onBoardingSkipButton, "text");



      });

    });
}