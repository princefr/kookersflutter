import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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


final host = 'kookers-app.herokuapp.com/graphql';
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
          Provider<NotificationPanelService>(create: (_) =>  NotificationPanelService()),

          
        ],
        child: MaterialApp(
        color: Colors.white,
        title: 'Kookers',
        home: AuthentificationnWrapper(),
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
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
    
    if(firebaseUser != null) {
      return FutureBuilder<UserDef>(
        future: Future.delayed(Duration(seconds: 3), () => databaseService.loadUserData(firebaseUser.uid)),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) return Scaffold(backgroundColor: Colors.white, body: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(image: AssetImage('assets/logo/logo_flutter.png'), height: 150,),
              SizedBox(height: 20),
              //CupertinoActivityIndicator()
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
              ),
            ],
          ),));
          if(snapshot.data == null) return OnBoardingPager();
          return Provider<User>.value(value: firebaseUser, child: TabHome(user: firebaseUser,));
        }
      );
    }

    

   return OnBoardingPager(); 

    
    
    
    
  }
}



