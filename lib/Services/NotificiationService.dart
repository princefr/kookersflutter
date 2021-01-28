
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';


class NotificationService {
  FirebaseMessaging messaging;
  NotificationService({this.messaging});
  StreamSubscription<String> get tokenChanges => messaging.onTokenRefresh.listen((event) => event);

  // Any time the token refreshes, store this in the database too.
  //  FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);

  Future<NotificationSettings> askPermission() async {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings;
  }


  Future<String> notificationID() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token;
  }
}