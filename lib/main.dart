import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Blocs/SignupBloc.dart';
import 'package:kookers/Pages/Onboarding/OnboardingPager.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Services/OrderProvider.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pull_to_refresh/pull_to_refresh.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(new FocusNode());
      },
          child: MultiProvider(
        providers: [
          Provider<AuthentificationService>(create: (_) => AuthentificationService(firebaseAuth: FirebaseAuth.instance)),
          StreamProvider(create: (context) => context.read<AuthentificationService>().authStateChanges),
          Provider<NotificationService>(create: (_) => NotificationService(messaging: FirebaseMessaging.instance)),
          Provider<StorageService>(create: (_) => StorageService(storage: firebase_storage.FirebaseStorage.instance)),
          Provider< DatabaseProviderService>(create: (_) =>  DatabaseProviderService()),
          Provider< PublicationProvider>(create: (_) =>  PublicationProvider()),
          Provider<OrderProvider>(create: (_) =>  OrderProvider()),
          Provider<PhoneAuthBloc>(create: (_) =>  PhoneAuthBloc()),
          Provider<SignupBloc>(create: (_) =>  SignupBloc()),
          Provider<NotificationPanelService>(create: (_) =>  NotificationPanelService()),

          
        ],
        child: MaterialApp(
          localizationsDelegates: [
              RefreshLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: [
              const Locale('en'),
              const Locale('zh'),
            ],
            localeResolutionCallback: (Locale locale, Iterable<Locale> supportedLocales) {
              return locale;
            },
        color: Colors.white,
        title: 'Kookers',
        home: AuthentificationnWrapper(),
        ),
      ),
    );
  }
}


class AuthentificationnWrapper extends StatelessWidget {
  AuthentificationnWrapper({Key key}): super(key: key);

  
  @override
  Widget build(BuildContext context) {
    final authentificationService =  Provider.of<AuthentificationService>(context, listen: true);
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);

    return StreamBuilder<User>(
      stream: authentificationService.authStateChanges,
      initialData: null,
      builder: (BuildContext ctx, AsyncSnapshot<User> snapshotc){
        if(snapshotc.connectionState == ConnectionState.waiting) return SplashScreen();
        if(snapshotc.data == null) return OnBoardingPager();
        databaseService.firebaseUser = snapshotc.data;
        return FutureBuilder<Object>(
          future: Future.delayed(Duration(seconds: 3), () => databaseService.loadUserData()),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) return SplashScreen();
            if(snapshot.data == null) return OnBoardingPager();
            return TabHome(user: snapshotc.data);
          }
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(image: AssetImage('assets/logo/logo_flutter.png'), height: 150,),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        ),
      ],
    ),));
  }
}



