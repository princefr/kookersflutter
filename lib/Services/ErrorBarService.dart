
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Orders/OrderPageChild.dart';
import 'package:kookers/Pages/Vendor/VendorPageChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';




class MessageToDisplay{
  String title;
  String body;
  MessageToDisplay({required this.title, required this.body});
}


class NotificationPanelService {
  /// Returns the **translation keys** (not the localised copy) for the
  /// title + body of a seller-facing push notification. Callers must
  /// resolve them via `.tr()` at display time so the notification is
  /// rendered in the user's current locale.
  MessageToDisplay loadMessageTypeSeller(String type) {
    switch (type) {
      case "new_order":
          return MessageToDisplay(body: 'push.newOrder.body', title: 'push.newOrder.title');
      case "order_cancelled":
          return MessageToDisplay(body: 'push.cancelled.body', title: 'push.cancelled.title');
      case "order_done":
          return MessageToDisplay(body: 'push.completed.body', title: 'push.completed.title');
      case "order_rated":
          return MessageToDisplay(body: 'push.newRating.body', title: 'push.newRating.title');
      default: return MessageToDisplay(body: 'push.newOrder.body', title: 'push.newOrder.title');
    }
  }


  



    /// Returns the **translation keys** (not the localised copy) for the
    /// title + body of a buyer-facing push notification.
    MessageToDisplay loadMessageTypeBuyer(String type) {
      switch (type) {
        case "order_accepted":
            return MessageToDisplay(body: 'push.accepted.body', title: 'push.accepted.title');
        case "order_refused":
            return MessageToDisplay(body: 'push.chefCancelled.body', title: 'push.chefCancelled.title');
        default:
        return MessageToDisplay(body: 'push.accepted.body', title: 'push.accepted.title');
      }
  }


  void showNewMessagePanel(BuildContext context, RemoteMessage event, Room room){
      Get.snackbar(event.data["senderName"], event.notification?.body ?? "", icon: Padding(
        padding: const EdgeInsets.all(6.0),
        child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    CachedNetworkImageProvider(event.data["senderImgUrl"]),
              ),
      ), onTap: (snack) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) =>ChatPage(room: room)));
      },);

  }


  void showOrderSeller(BuildContext context, RemoteMessage event, OrderVendor order){
        MessageToDisplay message =  loadMessageTypeSeller(event.data["type"]);
        Get.snackbar(message.title.tr(), message.body.tr(), icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ), onTap: (snack) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => VendorPageChild(vendor: order)));
          },);
  }


  void showOrderBuyer(BuildContext context, RemoteMessage event, Order order){
        MessageToDisplay message = loadMessageTypeBuyer(event.data["type"]);
        Get.snackbar(message.title.tr(), message.body.tr(), icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ), onTap: (snack) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => OrderPageChild(order: order)));
          },);
  }


  static void showError(BuildContext ctx, String message){
    Get.snackbar('common.errorTitle'.tr(), message, colorText: Colors.white, icon: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.white,
          ),
    ), backgroundColor: Colors.red);
  }


  static void showSuccess(BuildContext ctx, String message){
    Get.snackbar('common.successTitle'.tr(), message, colorText: Colors.white, icon: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
          Icons.check,
          size: 28.0,
          color: Colors.white,
          ),
    ), backgroundColor: Colors.green);
  }

} 