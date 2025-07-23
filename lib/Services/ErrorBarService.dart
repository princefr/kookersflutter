
import 'package:cached_network_image/cached_network_image.dart';
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
  MessageToDisplay loadMessageTypeSeller(String type) {
    switch (type) {
      case "new_order":
          return MessageToDisplay(body: "Vous avez une nouvelle commande.", title: "Commande");
      case "order_cancelled":
          return MessageToDisplay(body: "Une commande a été annulé.", title: "Annnulation");
      case "order_done":
          return MessageToDisplay(body: "Une commande vient de se terminer.", title: "Commande Terminée");
      case "order_rated":
          return MessageToDisplay(body: "Vous avez recu une nouvelle note pour une de vos commandes.", title: "Notation");
      default: return MessageToDisplay(body: "Vous avez une nouvelle commande.", title: "Commande");
    }
  }


  



    MessageToDisplay loadMessageTypeBuyer(String type) {
      switch (type) {
        case "order_accepted":
            return MessageToDisplay(body: "Votre commande a été accepté par le chef.", title: "Acceptation commande");
        case "order_refused":
            return MessageToDisplay(body: "Le chef a malheuresement annulé votre commande.", title: "Annulation commande");
        default:
        return MessageToDisplay(body: "Votre commande a été accepté par le chef.", title: "Acceptation commande");
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
        Get.snackbar(message.title, message.body, icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ), onTap: (snack) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => VendorPageChild(vendor: order)));
          },);
  }


  void showOrderBuyer(BuildContext context, RemoteMessage event, Order order){
        MessageToDisplay message = loadMessageTypeBuyer(event.data["type"]);
                Get.snackbar(message.title, message.body, icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ), onTap: (snack) {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => OrderPageChild(order: order)));
          },);
  }


  static void showError(BuildContext ctx, String message){
    Get.snackbar("Erreur", message, colorText: Colors.white, icon: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.white,
          ),
    ), backgroundColor: Colors.red);
  }


  static void showSuccess(BuildContext ctx, String message){
    Get.snackbar("Succès de l'opération", message, colorText: Colors.white, icon: Padding(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
          Icons.check,
          size: 28.0,
          color: Colors.white,
          ),
    ), backgroundColor: Colors.green);
  }

} 