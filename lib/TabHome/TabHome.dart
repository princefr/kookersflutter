import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Home/homePage.dart';
import 'package:kookers/Pages/Messages/RoomsPage.dart';
import 'package:kookers/Pages/Orders/OrdersPage.dart';
import 'package:kookers/Pages/Settings/Settings.dart';
import 'package:kookers/Pages/Vendor/VendorPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/TabHome/BottomBar.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';

// ignore: must_be_immutable
class TabHome extends StatefulWidget  {
  UserDef user;
  TabHome({Key key, this.user}) : super(key: key);

  @override
  _TabHomeState createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome>  with AutomaticKeepAliveClientMixin<TabHome>  {
  // ignore: close_sinks
  BehaviorSubject<int> _selectedIndex = BehaviorSubject<int>.seeded(0);
  PageController _controller;

  void _onItemTapped(int index) {
      this._selectedIndex.add(index);
      this._controller.jumpToPage(_selectedIndex.value);
  }


  @override
  void initState() {
    new Future.delayed(Duration.zero,() async {
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      final firebaseUser = context.read<User>();
      await Provider.of<DatabaseProviderService>(context, listen: false)
          .loadUserData(firebaseUser.uid)
          .then((value) {
          databaseService.loadPublication(); 
          databaseService.loadSellerPublications();
          databaseService.loadSellerOrders();
          databaseService.loadrooms();
          notificationService.messaging.subscribeToTopic("new_message");
          notificationService.messaging.subscribeToTopic("new_order");
          notificationService.messaging.subscribeToTopic("order_update");
          
      });
    });

    FirebaseMessaging.onMessage.listen((event) {
      final databaseService = Provider.of<DatabaseProviderService>(context, listen: false);
      // Flushbar(
      //   margin: EdgeInsets.all(8),
      //   borderRadius: 8,
      //   flushbarPosition: FlushbarPosition.TOP,
      //   message: event.notification.body,
      //   icon: Icon(
      //   Icons.info_outline,
      //   size: 28.0,
      //   color: Colors.blue[300],
      //   ),
      //   flushbarStyle: FlushbarStyle.FLOATING, duration: Duration(seconds: 3),).show(context);
      databaseService.loadrooms();
      print("get new remote message");
    });

    this._controller = PageController(initialPage: 0);
    super.initState(); 
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: PageView(
            controller: _controller,
            onPageChanged: (value){
                this._selectedIndex.add(value);
                this._controller.jumpToPage(value);

            },
            physics: NeverScrollableScrollPhysics(),
            children: [
              HomePage(),
              OrdersPage(),
              VendorPage(),
              RoomsPage(),
              Settings()
            ],
          ),
        ),
        bottomNavigationBar:
            StreamBuilder<int>(
              stream: _selectedIndex.stream,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting) return SizedBox();
                return BottomBar(onTap: _onItemTapped, selectedIndex: snapshot.data);
              }
            ),
      );

  }

  @override
  bool get wantKeepAlive => true;
}
