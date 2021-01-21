import "package:flutter/material.dart";
import 'package:kookers/Widgets/PageTitle.dart';





class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Column(children: [
         PageTitle(title: "Notifications"),
       ],),
    );
  }
}