import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Home/homePage.dart';
import 'package:kookers/Pages/Messages/RoomsPage.dart';
import 'package:kookers/Pages/Orders/OrdersPage.dart';
import 'package:kookers/Pages/Settings/Settings.dart';
import 'package:kookers/Pages/Vendor/VendorPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/TabHome/BottomBar.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TabHome extends StatefulWidget  {
  UserDef user;
  TabHome({Key key, this.user}) : super(key: key);

  @override
  _TabHomeState createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome>  {



  int _selectedIndex = 0;

  Widget gePage(int index) {
    switch (index) {
      case 0:
        return HomePage();
        break;
      case 1:
        return OrdersPage();
      case 2:
        return VendorPage();
      case 3:
        return RoomsPage();
      case 4:
        return Settings();
      default:
        return HomePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void initState() {
    new Future.delayed(Duration.zero,() {
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      final firebaseUser = context.read<User>();
      Provider.of<DatabaseProviderService>(context, listen: false)
          .loadUserData(firebaseUser.uid)
          .then((value) {
          databaseService.loadPublication(); 
      });
    });

    

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
   super.initState(); 
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(child: this.gePage(_selectedIndex)),
        ),
        bottomNavigationBar:
            BottomBar(onTap: _onItemTapped, selectedIndex: _selectedIndex),
      );

  }
}
