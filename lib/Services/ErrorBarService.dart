import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';
import 'package:kookers/Pages/Orders/OrderPageChild.dart';
import 'package:kookers/Pages/Vendor/VendorPageChild.dart';
import 'package:kookers/Services/DatabaseProvider.dart';




class MessageToDisplay{
  String title;
  String body;
  MessageToDisplay({this.title, this.body});
}


class NotificationPanelService {
  MessageToDisplay loadMessageTypeSeller(String type) {
    switch (type) {
      case "new_order":
          return MessageToDisplay(body: "Commande", title: "Vous avez une nouvelle commande.");
      break;
      case "order_cancelled":
          return MessageToDisplay(body: "Annnulation", title: "Une commande a été annulé.");
        break;
      case "order_done":
          return MessageToDisplay(body: "Commande finie", title: "Une commande vient de se terminer.");
        break;
      case "order_rated":
          return MessageToDisplay(body: "Notation", title: "Vous avez recu une nouvelle note pour une de vos commandes.");
        break;
      default: return MessageToDisplay(body: "Commande", title: "Vous avez une nouvelle commande.");
    }
  }


  



    MessageToDisplay loadMessageTypeBuyer(String type) {
      switch (type) {
        case "order_accepted":
            return MessageToDisplay(body: "Acceptation commande", title: "Votre commande a été accepté par le chef");
        break;
        case "order_refused":
            return MessageToDisplay(body: "Annulation commande", title: "Le chef a malheuresement annulé votre commande");
          break;
        default:
        return MessageToDisplay(body: "Acceptation commande", title: "Votre commande a été accepté par le chef");
      }
  }


  void showNewMessagePanel(BuildContext context, RemoteMessage event, Room room){
         Flushbar(
          onTap: (flushbar) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ChatPage(room: room)));
          },
          margin: EdgeInsets.all(8),
          borderRadius: 10,
          backgroundColor: Colors.white,
          flushbarPosition: FlushbarPosition.TOP,
          titleText: Text(event.data["senderName"], style: GoogleFonts.montserrat(),),
          messageText: Text(event.notification.body, style: GoogleFonts.montserrat(),),
          icon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(event.data["senderImgUrl"]),
            ),
          ),
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: Duration(seconds: 3),
          boxShadows: [BoxShadow(color: Colors.grey, offset: Offset(1.0, 2.0), blurRadius: 1.0,)]
        ).show(context);
  }


  void showOrderSeller(BuildContext context, RemoteMessage event, OrderVendor order){
        MessageToDisplay message =  loadMessageTypeSeller(event.data["type"]);
        Flushbar(
          onTap: (flushbar) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => VendorPageChild(vendor: order)));
          },
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
          title: message.title,
          message: message.body,
          icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ),
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: Duration(seconds: 3),
        ).show(context);
  }


  void showOrderBuyer(BuildContext context, RemoteMessage event, Order order){
        MessageToDisplay message = loadMessageTypeBuyer(event.data["type"]);
        Flushbar(
          onTap: (flushbar) {
            Navigator.push(context,
                  MaterialPageRoute(builder: (context) => OrderPageChild(order: order)));
          },
          margin: EdgeInsets.all(8),
          borderRadius: 8,
          flushbarPosition: FlushbarPosition.TOP,
          title: message.title,
          message: message.body,
          icon: Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.black,
          ),
          flushbarStyle: FlushbarStyle.FLOATING,
          duration: Duration(seconds: 3),
        ).show(context);
  }


  void showError(BuildContext ctx){
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      backgroundColor: Colors.red,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        
        color: Colors.white,
        ),
      duration: Duration(seconds: 5)
    ).show(ctx);
  }


  void showSuccessError(BuildContext ctx){

  }

} 