import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kookers/Pages/BeforeSign/BeforeSignAdress.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/Widgets/WebView.dart';




class AcceptTermsPage extends StatefulWidget {
  AcceptTermsPage({Key? key = null}) : super(key: key);

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
                      text: 'terms.acceptPrefix'.tr(),
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                      color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: "  ${'signup.termsLabel'.tr()} ",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(WebViewPage(
                                                    url: "https://getkookers.com/terms",
                                                    title: 'signup.termsLabel'.tr(),
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
                      text: 'terms.learnMorePrefix'.tr() + '   ',
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                                    color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: 'terms.privacySuffix'.tr() + '            ',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(WebViewPage(
                                                    url: "https://getkookers.com/privacy",
                                                    title: 'signup.privacyLabel'.tr(),
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
                      text: 'terms.dataUsage'.tr() + '   ',
                      style: GoogleFonts.montserrat(fontSize: 18, decoration: TextDecoration.none,
                                    color: Colors.black),
                      children: [
                                  TextSpan(
                                  text: '${'terms.dpoSuffix'.tr()} prince.ondonda@getkookers.com',
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
                      buttonText: 'common.continue'.tr(),
                      errorText: 'auth.error'.tr(),
                      loadingText: 'auth.sending'.tr(),
                      successText: 'auth.smsSent'.tr(),
                      controller: _streamButtonController,
                      onClick: () async {
                        Get.to(BeforeAdress(isReturn: false,));
                })
          ],
        ))
    );
  }
}
