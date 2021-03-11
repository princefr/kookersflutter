

import 'dart:io';
import 'dart:typed_data';
import 'package:kookers/Pages/Home/HomePublish.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kookers/Pages/Home/FoodIemChild.dart';
import 'package:kookers/Pages/Home/Guidelines.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Pages/Home/homePage.dart';
import 'package:kookers/Pages/Notifications/NotificationPage.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthCodePage.dart';
import 'package:kookers/Pages/Signup/SignupPage.dart';
import 'package:kookers/Services/PermissionHandler.dart';
import 'package:kookers/main.dart' as app;
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';


// flutter drive  --driver=test_driver/app.dart --target=test_driver/app_test.dart

Future<void> delay([int milliseconds = 250]) async {
  return Future<void>.delayed(Duration(milliseconds: milliseconds));
}


class MockPermissionHandler extends Mock implements PermissionHandler {}

void main(List<String> args) {
  
    group("Kookers App", () {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      final permissionHandler = MockPermissionHandler();

      
      // testWidgets("Signin Test", (tester) async {

      //   when(permissionHandler.requestNotificationPermission())
      //           .thenAnswer((_) => Future.value(PermissionStatus.granted));
        
      //   app.main(testing: true);
      //   await tester.pumpAndSettle();

      //   await delay(750);

      //   final onBoardingSkipButton = find.byKey(Key("OnBording_pass"));
      //   await tester.tap(onBoardingSkipButton);
      //   await tester.pumpAndSettle();

      //   await delay(750);
      
      //   final beforeSignButton = find.byKey(Key("beforeSignButton"));
      //   await tester.tap(beforeSignButton);
      //   await tester.pumpAndSettle();

      //   await delay(750);

      //   final phoneTextField = find.byKey(Key("phone_number"));
      //   final phoneValidationButton = find.byKey(Key("phoneValidationButton"));
      //   await tester.enterText(phoneTextField, "782798614");

      //   await tester.pumpAndSettle(Duration(seconds: 3));
      //   await tester.tap(phoneValidationButton);
      //   await tester.pumpAndSettle(Duration(seconds: 5));

      //   expect(find.byWidgetPredicate((widget) => widget is PhoneAuthCodePage), findsOneWidget);

      //   final phoneCodeTestField = find.byKey(Key("PhoneCodeTestField"));
      //   final phoneCodeButton = find.byKey(Key("phoneCodeButton"));
      //   await tester.enterText(phoneCodeTestField, "123456");
      //   await tester.pumpAndSettle(Duration(seconds: 3));
      //   await tester.tap(phoneCodeButton);
      //   await tester.pumpAndSettle(Duration(seconds: 5));

      //   expect(find.byWidgetPredicate((widget) => widget is NotificationPage), findsOneWidget);


      // });


      // testWidgets("Signup Test", (tester) async {
        
      //   when(permissionHandler.requestNotificationPermission())
      //           .thenAnswer((_) => Future.value(PermissionStatus.granted));

      //    app.main(testing: true);
      //    await tester.pumpAndSettle();

      //   await delay(750);

      //   final onBoardingSkipButton = find.byKey(Key("OnBording_pass"));
      //   await tester.tap(onBoardingSkipButton);
      //   await tester.pumpAndSettle();

      //   await delay(750);
      
      //   final beforeSignButton = find.byKey(Key("beforeSignButton"));
      //   await tester.tap(beforeSignButton);
      //   await tester.pumpAndSettle();

      //   await delay(750);

      //   final phoneTextField = find.byKey(Key("phone_number"));
      //   final phoneValidationButton = find.byKey(Key("phoneValidationButton"));
      //   await tester.enterText(phoneTextField, "782798618");

      //   await tester.pumpAndSettle(Duration(seconds: 3));
      //   await tester.tap(phoneValidationButton);
      //   await tester.pumpAndSettle(Duration(seconds: 5));

      //   expect(find.byWidgetPredicate((widget) => widget is PhoneAuthCodePage), findsOneWidget);

      //   final phoneCodeTestField = find.byKey(Key("PhoneCodeTestField"));
      //   final phoneCodeButton = find.byKey(Key("phoneCodeButton"));
      //   await tester.enterText(phoneCodeTestField, "123456");
      //   await tester.pumpAndSettle(Duration(seconds: 3));
      //   await tester.tap(phoneCodeButton);
      //   await tester.pumpAndSettle(Duration(seconds: 3));

      //   expect(find.byWidgetPredicate((widget) => widget is SignupPage), findsOneWidget);

      //   final lastNameTextfield = find.byKey(Key("last_name_textfield"));
      //   await tester.enterText(lastNameTextfield, "test");

      //   await delay(750);

      //   final firstNameTextfield = find.byKey(Key("first_name_textfield"));
      //   await tester.enterText(firstNameTextfield, "test");


      //   await delay(750);

      //   final emailTextfield = find.byKey(Key("email_textfield"));
      //   await tester.enterText(emailTextfield, "test@getkookers.com");
      //   await tester.pumpAndSettle();
      //   await delay(750);
        

      //   final chooseDate = find.byKey(Key("choose_date_button"));
      //   await tester.tap(chooseDate);

      //   await tester.pumpAndSettle();
      //   expect(find.byWidgetPredicate((widget) => widget is ChooseDatePage), findsOneWidget);

        

      //   final dateValidationButton = find.byKey(Key("date_validation"));
      //   await tester.drag(find.text("2021"), Offset(0.0, 670.0));
      

      //   await tester.pumpAndSettle(Duration(seconds: 4));
      //   await tester.tap(dateValidationButton);
      //   await tester.pumpAndSettle();


      //   final searchAdress = find.byKey(Key("search_adress_button"));
      //   await tester.tap(searchAdress);
      //   await tester.pumpAndSettle();
      //   expect(find.byWidgetPredicate((widget) => widget is HomeSearchPage), findsOneWidget);
      //   final searchTextField = find.byKey(Key("search_text"));
      //   await tester.enterText(searchTextField, "303 quai aux fleurs");
      //   await tester.pumpAndSettle(Duration(seconds: 3));

      //   final adressitem = find.byKey(Key("adress0"));
      //   await tester.tap(adressitem);
      //   await tester.pumpAndSettle(Duration(seconds: 3));
      //   expect(find.byWidgetPredicate((widget) => widget is SignupPage), findsOneWidget);


      //   final checkboxTerms = find.byKey(Key("checkboxTerms"));
      //   await tester.tap(checkboxTerms);
      //   await tester.pumpAndSettle(Duration(seconds: 3));

        

      //   await delay(750);


      //   final signupButton = find.byKey(Key("signup_button"));
      //   await tester.ensureVisible(signupButton);
      //   await tester.pumpAndSettle(Duration(seconds: 5));
      //   await tester.tap(signupButton);  
      //   await tester.pumpAndSettle(Duration(seconds: 10));

      //   await delay(750);

      //   expect(find.byWidgetPredicate((widget) => widget is NotificationPage), findsOneWidget);

      //   final delayAcceptNotification =  find.byKey(Key("delay_accept_notification"));
      //   await tester.tap(delayAcceptNotification);
      //   await tester.pumpAndSettle();
      // });

      // testWidgets("Test becoming seller", (tester) async {
      //   app.main(testing: false);
      //   await tester.pumpAndSettle(Duration(seconds: 5));
      //   final publishButton =  find.byKey(Key("publish_button"));

      //   await tester.tap(publishButton);
      //   await delay(750);


      //   expect(find.byWidgetPredicate((widget) => widget is GuidelinesToSell), findsOneWidget);



      //   final firstTermCheckbox =  find.byKey(Key("firstTerm"));
      //   final secondTermCheckbox =  find.byKey(Key("secondTerm"));
      //   final thirdTermCheckbox =  find.byKey(Key("thirdTerm"));

      //   print("found this buttons");

      //   await tester.tap(firstTermCheckbox);
      //   await delay(750);

        

      //   await tester.tap(secondTermCheckbox);
      //   await delay(750);
      //   await tester.tap(thirdTermCheckbox);
      //   await delay(750);

        

      //   final sellingAcceptButton =  find.byKey(Key("SellingAcceptButton"));
      //   await tester.tap(sellingAcceptButton);
      //   await tester.pumpAndSettle(Duration(seconds: 5));

      //   expect(find.byWidgetPredicate((widget) => widget is HomePage), findsOneWidget); 
      // });

      testWidgets("Test publication", (tester) async {
        const MethodChannel channel = MethodChannel('plugins.flutter.io/image_picker');
        channel.setMockMethodCallHandler((MethodCall methodCall) async {
        ByteData data = await rootBundle.load('assets/logo/logo_flutter_white.jpg');
        Uint8List bytes = data.buffer.asUint8List();
        Directory tempDir = await getTemporaryDirectory();
        File file = await File('${tempDir.path}/tmp.tmp', ).writeAsBytes(bytes);
          print(file.path);
          return file.path;
        });
        app.main(testing: false);

        await tester.pumpAndSettle(Duration(seconds: 5));
        final publishButton =  find.byKey(Key("publish_button"));

        await tester.tap(publishButton);
        await delay(750);

        expect(find.byWidgetPredicate((widget) => widget is HomePublish), findsOneWidget);

        final pictureImage =  find.byKey(Key("photo0"));
        final pictureImage1 =  find.byKey(Key("photo1"));
        final pictureImage2 =  find.byKey(Key("photo2"));

        await tester.tap(pictureImage);
        await delay(750);
        await tester.tap(pictureImage1);
        await delay(750);
        await tester.tap(pictureImage2);
        await tester.pumpAndSettle(Duration(seconds: 5));

        await tester.tap(pictureImage2);

        final chipsChoice =  find.byKey(Key("chips_choice"));
        await tester.tap(chipsChoice);
        await delay(750);

        final plateName =  find.byKey(Key("plate_name"));
        final plateDescription =  find.byKey(Key("plate_description"));
        final platPrice =  find.byKey(Key("plate_price"));

        await tester.enterText(plateName, "test test");
        await tester.enterText(plateDescription, "text");
        await tester.enterText(platPrice, "15");

        await tester.pumpAndSettle(Duration(seconds: 5));

        


      });

      testWidgets("Paiement food Test", (tester) async {
        app.main(testing: false);
      });

      testWidgets("Add card Test", (tester) async {
        app.main(testing: false);
      });

      testWidgets("Add banking account Test", (tester) async {
        app.main(testing: false);
      });

      testWidgets("Add adress Test", (tester) async {
        app.main(testing: false);
      });

    });
}