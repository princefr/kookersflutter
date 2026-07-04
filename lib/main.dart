import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
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
import 'package:kookers/UI/Theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main({bool testing = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (testing) await FirebaseAuth.instance.signOut();
  if (!testing) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  runApp(const KookersApp());
}

class KookersApp extends StatelessWidget {
  const KookersApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dismiss the keyboard when the user taps outside any text field.
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: MultiProvider(
        providers: [
          Provider<AuthentificationService>(
            create: (_) =>
                AuthentificationService(firebaseAuth: FirebaseAuth.instance),
          ),
          StreamProvider<User?>(
            create: (context) =>
                context.read<AuthentificationService>().authStateChanges,
            initialData: null,
          ),
          Provider<NotificationService>(
            create: (_) =>
                NotificationService(messaging: FirebaseMessaging.instance),
          ),
          Provider<StorageService>(
            create: (_) => StorageService(
                storage: firebase_storage.FirebaseStorage.instance),
          ),
          Provider<DatabaseProviderService>(
              create: (_) => DatabaseProviderService()),
          Provider<PublicationProvider>(
              create: (_) => PublicationProvider()),
          Provider<OrderProvider>(create: (_) => OrderProvider()),
          Provider<PhoneAuthBloc>(create: (_) => PhoneAuthBloc()),
          Provider<SignupBloc>(create: (_) => SignupBloc()),
          Provider<NotificationPanelService>(
              create: (_) => NotificationPanelService()),
        ],
        child: GetMaterialApp(
          title: 'Kookers',
          theme: KookersTheme.light,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            RefreshLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
            Locale('fr'),
          ],
          localeResolutionCallback: (Locale? locale, Iterable<Locale> supported) {
            return locale ?? const Locale('en');
          },
          home: const AuthenticationWrapper(),
        ),
      ),
    );
  }
}

/// Decides which root screen to show:
///  - splash while we resolve auth
///  - onboarding when there is no signed-in user (or no DB record yet)
///  - main TabHome once the user is fully loaded
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService =
        Provider.of<AuthentificationService>(context, listen: false);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);

    // Short delay so the splash screen has a chance to render before the
    // first frame — previously this was 3 seconds, which made every cold
    // launch feel sluggish. 600ms is enough for the logo to land.
    return FutureBuilder<User?>(
      future: Future.delayed(const Duration(milliseconds: 600),
          () => authService.userConnected()),
      initialData: null,
      builder: (BuildContext ctx, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        final user = snapshot.data;
        if (user == null) return const OnBoardingPager();

        return FutureBuilder<UserDef?>(
          future: databaseService.loadUserData(user.uid),
          builder: (context, dbSnapshot) {
            if (dbSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (dbSnapshot.data == null) return const OnBoardingPager();
            return TabHome(user: user);
          },
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo_flutter.png',
              height: 150,
            ),
            const SizedBox(height: KookersSpacing.xl),
            SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    KookersColors.primary),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
