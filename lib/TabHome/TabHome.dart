import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignPage.dart';
import 'package:kookers/Pages/Home/homePage.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Messages/RoomsPage.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Orders/OrderPageChild.dart';
import 'package:kookers/Pages/Orders/OrdersPage.dart';
import 'package:kookers/Pages/Settings/Settings.dart';
import 'package:kookers/Pages/Vendor/VendorPage.dart';
import 'package:kookers/Pages/Vendor/VendorPageChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/ErrorBarService.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/TabHome/BottomBar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
    with AutomaticKeepAliveClientMixin<TabHome>, WidgetsBindingObserver {
  BehaviorSubject<int> _selectedIndex = BehaviorSubject<int>.seeded(0);
  PageController _controller;

  void _onItemTapped(int index) {
    if (this.widget.user == null && index != 0) {
      showCupertinoModalBottomSheet(
          expand: false,
          context: context,
          builder: (context) => BeforeSignPage(from: "tabhome"));
    } else {
      this._selectedIndex.add(index);
      this._controller.jumpToPage(_selectedIndex.value);
    }
  }

  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateKookers_',
    minDays: 0, // Show rate popup on first day of install.
    minLaunches:
        5, // Show rate popup after 5 launches of app after minDays is passed.
    remindDays: 2,
    remindLaunches: 2,
    googlePlayIdentifier: "com.getkookers.android",
    appStoreIdentifier: "1529436130",
  );

  StreamSubscription<RemoteMessage> get onMessage => FirebaseMessaging.onMessage.listen((event) => event);

  @override
  void dispose() {
    this._selectedIndex.close();
    super.dispose();
  }

  @override
  void initState() {
    new Future.delayed(Duration.zero, () async {
      await Jiffy.locale("fr");
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      final notificationService =
          Provider.of<NotificationService>(context, listen: false);
      notificationService.messaging.subscribeToTopic("new_message");
      notificationService.messaging.subscribeToTopic("new_order");
      notificationService.messaging.subscribeToTopic("order_update");
      if (this.widget.user != null) {
        final token = await notificationService.messaging.getToken();
        databaseService.user.value.fcmToken = token;
        databaseService.updateFirebasetoken(token);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context);
      }
    });


    Future.delayed(Duration.zero, () async {
      final notifService = Provider.of<NotificationService>(context, listen: false);
      final permission = await notifService.checkPermissions();
      if(permission.authorizationStatus == AuthorizationStatus.authorized){
      if (await FlutterAppBadger.isAppBadgeSupported()) FlutterAppBadger.removeBadge();
            this.onMessage.onData((event) async {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      if (event.data["type"] == "new_message") {
        await databaseService.loadrooms();
        Room room = databaseService.rooms.value
            .firstWhere((element) => element.id == event.data["roomId"]);
        NotificationPanelService().showNewMessagePanel(context, event, room);
      } else if (event.data["side"] == "order_seller") {
        if (event.data["type"] == "order_done") databaseService.loadUserData(this.widget.user.uid);
        await databaseService.loadSellerOrders();
        OrderVendor order = databaseService.sellerOrders.value
            .firstWhere((element) => element.id == event.data["orderId"]);
        NotificationPanelService().showOrderSeller(context, event, order);
      } else if (event.data["side"] == "order_buyer") {
        await databaseService.loadbuyerOrders();
        final Order order = databaseService.buyerOrders.value
            .firstWhere((element) => element.id == event.data["orderId"]);
        NotificationPanelService().showOrderBuyer(context, event, order);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Future.delayed(Duration(microseconds: 200), () async {
        final databaseService =
            Provider.of<DatabaseProviderService>(context, listen: false);
        if (event.data["type"] == "new_message") {
          await databaseService.loadrooms();
          Room room = databaseService.rooms.value
              .firstWhere((element) => element.id == event.data["roomId"]);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatPage(room: room)));
        } else if (event.data["side"] == "order_seller") {
          await databaseService.loadSellerOrders();
          OrderVendor order = databaseService.sellerOrders.value
              .firstWhere((element) => element.id == event.data["orderId"]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VendorPageChild(vendor: order)));
        } else if (event.data["side"] == "order_buyer") {
          await databaseService.loadbuyerOrders();
          final Order order = databaseService.buyerOrders.value
              .firstWhere((element) => element.id == event.data["orderId"]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderPageChild(order: order)));
        }
      });
    });
      }
    });



    this._controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
              HomePage(user: this.widget.user),
              OrdersPage(),
              VendorPage(),
              RoomsPage(),
              Settings(user: this.widget.user)
            ],
          ),
        ),
        bottomNavigationBar: new Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
