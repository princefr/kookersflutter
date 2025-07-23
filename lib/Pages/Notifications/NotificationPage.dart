import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/NotificiationService.dart';
import 'package:kookers/Services/PermissionHandler.dart';
import 'package:kookers/TabHome/TabHome.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';





class NotificationPage extends StatefulWidget {
  final User user;
  NotificationPage({Key? key, required this.user}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  StreamButtonController _streamButtonController = StreamButtonController();


  final permissionhandler = PermissionHandler();

  @override
  Widget build(BuildContext context) {

    final notifService =
        Provider.of<NotificationService>(context, listen: false);


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

            Expanded(child: SizedBox()),

            StreamButton(buttonColor: Colors.black,
                            buttonText: "Activer les notifications",
                            errorText: "Une erreur s'est produite, Veuillez reesayer",
                            loadingText: "Traitement en cours",
                            successText: "Terminé",
                            controller: _streamButtonController, onClick: () async {
                              notifService.askPermission().then((settings) {
                                Get.to(TabHome(user:  this.widget.user));   
                              });
                              }
                            ),

                            SizedBox(height:10),

                            InkWell(
                              onTap: (){
                                    Get.to(TabHome(user:  this.widget.user));
                            },child: Center(
                              key:  Key("delay_accept_notification"),
                              child: Text("Plus tard", style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey),))),
                            SizedBox(height:10),
         ],),
      ),
          ),
    );
  }
}