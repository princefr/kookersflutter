import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Home/homePage.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Messages/RoomsPage.dart';
import 'package:kookers/Pages/Orders/OrdersPage.dart';
import 'package:kookers/Pages/Settings/Settings.dart';
import 'package:kookers/Pages/Vendor/VendorPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/TabHome/BottomBar.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:rxdart/subjects.dart';
import 'dart:async';

// ignore: must_be_immutable
class TabHome extends StatefulWidget {
  User user;
  TabHome({Key key, this.user}) : super(key: key);

  @override
  _TabHomeState createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome>
    with AutomaticKeepAliveClientMixin<TabHome> , WidgetsBindingObserver {
  // ignore: close_sinks
  BehaviorSubject<int> _selectedIndex = BehaviorSubject<int>.seeded(0);
  PageController _controller;

  void _onItemTapped(int index) {
    this._selectedIndex.add(index);
    this._controller.jumpToPage(_selectedIndex.value);
  }

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0, // Show rate popup on first day of install.
    minLaunches:
        1, // Show rate popup after 5 launches of app after minDays is passed.
  );

  StreamSubscription<RemoteMessage> get onMessage => FirebaseMessaging.onMessage.listen((event) => event);
  
  


  @override
  void dispose() {
    this.onMessage.cancel();
    super.dispose();
  }





  @override
  void initState() {
    new Future.delayed(Duration.zero, () async {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      await Provider.of<DatabaseProviderService>(context, listen: false)
          .loadUserData(this.widget.user.uid)
          .then((value) async {
        databaseService.loadPublication();
        databaseService.loadSellerPublications();
        databaseService.loadSellerOrders();
        databaseService.loadrooms();
        databaseService.loadSourceList();
        notificationService.messaging.subscribeToTopic("new_message");
        notificationService.messaging.subscribeToTopic("new_order");
        notificationService.messaging.subscribeToTopic("order_update");
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context);
      }
    });

    this.onMessage.onData((event) {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      if (event.data["type"] == "new_message") {
        databaseService.loadrooms();
        Flushbar(
          onTap: (flushbar) {
            Room room = databaseService.rooms.value
                .firstWhere((element) => element.id == event.data["roomId"]);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatPage(room: room)));
          },
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
          title: event.data["senderName"],
          message: event.notification.body,
          icon: CircleAvatar(
            backgroundImage:
                CachedNetworkImageProvider(event.data["senderImgUrl"]),
          ),
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: Duration(seconds: 3),
        ).show(context);
      } else if(event.data["type"] == "new_order"){
          print("new_order");
      }
    });




    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Future.delayed(Duration(microseconds: 200), () async {
        final databaseService =
            Provider.of<DatabaseProviderService>(context, listen: false);
            databaseService.loadrooms();
            if (event.data["type"] == "new_message") {
              Room room = databaseService.rooms.value
                  .firstWhere((element) => element.id == event.data["roomId"]);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatPage(room: room)));

            }
      });
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
          onPageChanged: (value) {
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
      bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.white,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light
              primaryColor: Colors.white,
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.white))),
          child: StreamBuilder<int>(
              stream: _selectedIndex.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return SizedBox();
                return BottomBar(
                    onTap: _onItemTapped, selectedIndex: snapshot.data);
              })),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
