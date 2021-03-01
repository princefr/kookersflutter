import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kookers/Pages/Home/HomeSearchPage.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/Widgets/WebView.dart';




class AcceptTermsPage extends StatefulWidget {
  AcceptTermsPage({Key key}) : super(key: key);

  @override
  _AcceptTermsPageState createState() => _AcceptTermsPageState();
}

class _AcceptTermsPageState extends State<AcceptTermsPage> {

  StreamButtonController _streamButtonController = StreamButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBarWitBackNav(title: "", height: 54, isRightIcon: false),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
                child: ListView(
                  shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      text: "En continuant, vous acceptez les",
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                      color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: "  Conditions d'utilisation ",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(WebViewPage(
                                                    url: "https://getkookers.com/terms",
                                                    title: "Conditions d'utilisation",
                                                  ));
                                    }),
                      ]
                    )),
                  ),

                  SizedBox(height: 20),

                  Center(child: Icon(CupertinoIcons.check_mark_circled_solid, size: 130, color: Colors.green,)),

                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      text: "Pour en savoir plus sur vos droits et sur l'utilisation de vos données consultez la   ",
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                                    color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: "Politique de confidentialité.            ",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(WebViewPage(
                                                    url: "https://getkookers.com/privacy",
                                                    title: "Politique de confidentialité",
                                                  ));
                                    }),
                      ]
                    )),
                  ),

                   SizedBox(height: 10),

                   Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                      text: "Kookers utilise vos données pour vous fournir ses services et les ameliorer. Vous bénéficiez d'un droit d'accès et de rectification aux informations qui vous concernent, du droit de supprimer votre compte et du droit de vous opposer à l'utilisation de vos données à des fins de protection commerciale. Vous pouvez exercer vos droits à tout moment en contactant notre   ",
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                                    color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: "Responsable de la protection des données à l'adresse : prince.ondonda@getkookers.com",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()),
                      ]
                    )),
                  ),

                  



                ],
      ),
            ),


                StreamButton(
                      buttonColor: Colors.black,
                      key: Key("phoneValidationButton"),
                      buttonText: "Continuer",
                      errorText: "Une erreur s'est produite, veuillez reesayer!",
                      loadingText: "Envoie en cours",
                      successText: "Sms envoyé",
                      controller: _streamButtonController,
                      onClick: () async {
                        Get.to(HomeSearchPage(isReturn: false, isNotAuth: true,));
                })
          ],
        ))
    );
  }
}