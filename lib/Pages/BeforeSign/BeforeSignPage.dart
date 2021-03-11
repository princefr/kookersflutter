import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/PhoneAuth/PhoneAuthPage.dart';
import 'package:kookers/Pages/Terms/AcceptTermsPage.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:get/get.dart';




class BeforeSignPage extends StatefulWidget {
  final String from;
  BeforeSignPage({Key key, @required this.from}) : super(key: key);

  @override
  _BeforeSignPageState createState() => _BeforeSignPageState();
}

class _BeforeSignPageState extends State<BeforeSignPage> {

    StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: TopBarWitRightTitle(title: "", height: 54, rightText: this.widget.from == "onboarding" ? "Ignorer" : "", onTapRight: (){
          if(this.widget.from == "onboarding"){
            Get.to(AcceptTermsPage());
          }
          
        }),
        body: SafeArea(
            child: Container(
            child: Column(
              children: [
                SizedBox(height: 40),

                Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                    children: [
                      Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 30,
                          width: 30,
                          child: SvgPicture.asset(
                                        'assets/logo/logo_white.svg',
                                        height: 30,
                                        width: 30,
                                        color: Colors.black,
                                      ),
                        ),

                        SizedBox(width: 10),
                  Text("Kookers",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w900,
                          fontSize: 30,
                          color: Colors.black))
                    ],
                  ),

                  SizedBox(height:20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height: 250,
                    padding: EdgeInsets.all(10),
                     decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover, image: AssetImage('assets/onboarding/lily-banse--YHSwy6uqvk-unsplash.jpg')),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.redAccent,
                    )),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(child: Text("Kookers connecte chefs amateur et gourmands aux alentours. Rejoignez nous!!", style: GoogleFonts.montserrat(fontSize: 20), textAlign: TextAlign.center,)),
                  ),
                    ]
                  ),
                ),

                StreamButton(
                        buttonColor: Colors.black,
                        key: Key("beforeSignButton"),
                        buttonText: "Se connecter / S'inscrire",
                        errorText: "Une erreur s'est produite, veuillez reesayer!",
                        loadingText: "Envoie en cours",
                        successText: "Sms envoyé",
                        controller: _streamButtonController,
                        onClick: () async {
                          Get.to(PhoneAuthPage());
                        })

              ]),
            ),
        ),
      ),
    );
  }
}