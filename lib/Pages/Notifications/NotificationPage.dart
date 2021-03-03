import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';





class NotificationPage extends StatefulWidget {
  final User user;
  NotificationPage({Key key, @required this.user}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
  return Scaffold(
        body: SafeArea(
        child: Container(
        child: Column(children: [
            SizedBox(height: 40),
            Center(child: Container(child: Lottie.asset('assets/lottie/lottie_notification.json', height: 300, fit: BoxFit.fill, repeat: false))),
            SizedBox(height: 10),

            Center(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text("Nous souhaiterions pouvoir vous envoyer des notifications pour vous prévénir de ce qui se passe sur kookers.", style: GoogleFonts.montserrat()),
            )),

            Expanded(child: SizedBox(),),

            StreamButton(buttonColor: Colors.black,
                            buttonText: "Activer les notifications",
                            errorText: "Une erreur s'est produite, Veuillez reesayer",
                            loadingText: "Traitement en cours",
                            successText: "Terminé",
                            controller: _streamButtonController, onClick: () async {
                                notificationService.askPermission().then((permission) {
                                  if (permission.authorizationStatus ==
                                                AuthorizationStatus.authorized ||
                                            permission.authorizationStatus ==
                                                AuthorizationStatus.provisional) {
                                                  Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        TabHome(user:  this.widget.user,)));
                                                  
                                    }else{
                                      Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        TabHome(user: this.widget.user)));
                                    }
                                });
                              }
                            ),

                            SizedBox(height:10),
                            InkWell(onTap: (){
                                            Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                    builder: (context) =>
                                                        TabHome(user: this.widget.user,)));
                            },child: Center(child: Text("Plus tard.", style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey),))),
                            SizedBox(height:10),
         ],),
      ),
          ),
    );
  }
}