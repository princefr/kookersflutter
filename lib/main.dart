import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Blocs/SignupBloc.dart';
import 'package:kookers/Pages/Onboarding/OnboardingPager.dart';
import 'package:kookers/Services/AnalyticsService.dart';
import 'package:kookers/Services/AuthentificationService.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/ForceUpgradeService.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Services/OrderProvider.dart';
import 'package:kookers/Services/PublicationProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:kookers/UI/ThemeController.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Locales the app supports.
///
/// French stays the default (the app shipped as French-only before
/// localisation was added). The other locales are sorted by the order
/// the user requested them: en, it, de, es, tr.
const kSupportedLocales = <Locale>[
  Locale('fr'),
  Locale('en'),
  Locale('it'),
  Locale('de'),
  Locale('es'),
  Locale('tr'),
];

void main({bool testing = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  // Hook Firebase Analytics into our typed event helpers.
  KookersAnalytics.init(FirebaseAnalytics.instance);
  // Load persisted theme preference before runApp so the first frame
  // matches what the user picked on their last session.
  await themeController.load();
  if (testing) await FirebaseAuth.instance.signOut();
  if (!testing) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  runApp(
    EasyLocalization(
      supportedLocales: kSupportedLocales,
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('fr'),
      child: const KookersApp(),
    ),
  );
}

/// Global [ThemeController] instance. Initialised in [main] before
/// [runApp]; screens read it via `ThemeController.of(context)`.
final ThemeController themeController = ThemeController();

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
        child: themeController.scope(
          child: GetMaterialApp(
            title: 'Kookers',
            theme: KookersTheme.light,
            darkTheme: KookersTheme.dark,
            themeMode: themeController.value.toMaterialThemeMode(),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              // pull_to_refresh delegate is not bundled by easy_localization,
              // so we add it alongside the standard delegates it provides.
              RefreshLocalizations.delegate,
              ...context.localizationDelegates,
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const AuthenticationWrapper(),
          ),
        ),
      ),
    );
  }
}

/// Decides which root screen to show:
///  - splash while we resolve auth
///  - onboarding when there is no signed-in user (or no DB record yet)
///  - main TabHome once the user is fully loaded
class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  /// Null = check in progress. true = app meets minimum. false = must
  /// upgrade. We check once on startup and stash the result so we
  /// don't re-fetch the config on every rebuild.
  bool? _meetsMinimum;

  @override
  void initState() {
    super.initState();
    _checkMinimumVersion();
  }

  Future<void> _checkMinimumVersion() async {
    final ok = await ForceUpgradeService.meetsMinimum();
    if (!mounted) return;
    if (!ok) {
      // Show the upgrade dialog; it's non-dismissible so the user is
      // forced to update. We don't set state — the dialog itself
      // blocks the app.
      await ForceUpgradeService.showUpgradeDialog(context);
      if (!mounted) return;
      // Re-check after they come back from the store (they may have
      // updated, in which case the app will be hot-restarted by the
      // OS anyway).
      _checkMinimumVersion();
    } else {
      setState(() => _meetsMinimum = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_meetsMinimum != true) {
      // Still checking or upgrade dialog is showing — splash is fine.
      return const SplashScreen();
    }

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
