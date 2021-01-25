import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Blocs/PhoneAuthBloc.dart';
import 'package:kookers/Blocs/SignupBloc.dart';
import 'package:kookers/GraphQlHelpers/ClientProvider.dart';
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


final host = '921f6bd6742b.ngrok.io/graphql';
final graphqlEndpoint = 'https://$host';
final subscriptionEndpoint = 'wss://$host';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
  // This widget is the root of your application.

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
          Provider<ErrorBar>(create: (_) =>  ErrorBar()),

          
        ],
        child: ClientProvider(
          uri: graphqlEndpoint,
          subscriptionUri: subscriptionEndpoint,
          child: MaterialApp(
          
          color: Colors.white,
          title: 'Kookers',
          home: AuthentificationnWrapper(),
          ),
        ),
      ),
    );
  }
}


class AuthentificationnWrapper extends StatefulWidget {
  AuthentificationnWrapper({Key key}): super(key: key);



  @override
  _AuthentificationnWrapperState createState() => _AuthentificationnWrapperState();
}

class _AuthentificationnWrapperState extends State<AuthentificationnWrapper> {

  
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if(firebaseUser != null) {
      return Provider<User>.value(value: firebaseUser, child: TabHome());
    }
    
    return GestureDetector(onTap: (){FocusScope.of(context).requestFocus(new FocusNode());}, child: OnBoardingPager());
    
  }
}



abstract class RouteAwareState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)); //Subscribe it here
    super.didChangeDependencies();
  }


  

  @override
  void didPush() {
    print('didPush $widget');
  }

  @override
  void didPopNext() {
    print("did pop from $widget");
    //print('didPopNext $widget');
  }

  @override
  void didPop() {
    print('didPop $widget');
  }

  @override
  void didPushNext() {
    print('didPushNext $widget');
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}