

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthCodePage.dart';
import 'package:kookers/main.dart' as app;


// flutter drive  --driver=test_driver/app.dart --target=test_driver/app_test.dart

Future<void> delay([int milliseconds = 250]) async {
  await Future<void>.delayed(Duration(milliseconds: milliseconds));
}

void main(List<String> args) {
  
    group("Kookers App", () {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      // Process.run(executable, arguments)


      testWidgets("Signin Test", (tester) async {
        app.main();
        await tester.pumpAndSettle();

        delay(750);

        final onBoardingSkipButton = find.byKey(Key("OnBording_pass"));
        await tester.tap(onBoardingSkipButton);
        await tester.pumpAndSettle();

        delay(750);
      
        final beforeSignButton = find.byKey(Key("beforeSignButton"));
        await tester.tap(beforeSignButton);
        await tester.pumpAndSettle();


        delay(750);


        final phoneTextField = find.byKey(Key("phone_number"));
        final phoneValidationButton = find.byKey(Key("phoneValidationButton"));
        await tester.enterText(phoneTextField, "782798614");
        await tester.tap(phoneValidationButton);
        await tester.pumpAndSettle(Duration(seconds: 10));

        expect(find.byWidgetPredicate((widget) => widget is PhoneAuthCodePage), findsOneWidget);

        final phoneCodeTestField = find.byKey(Key("PhoneCodeTestField"));
        final phoneCodeButton = find.byKey(Key("phoneCodeButton"));
        await tester.enterText(phoneCodeTestField, "123456");
        await tester.tap(phoneCodeButton);
        await tester.pumpAndSettle();


      });


      testWidgets("Signup Test", (tester) async {

      });

    });
}