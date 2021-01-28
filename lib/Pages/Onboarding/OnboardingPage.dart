import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Onboarding/OnboardingModel.dart';




class OnboardingPage extends StatelessWidget {
  final OnboardingModel data; // model
  const OnboardingPage({this.data}); // load page


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Container(
          color: Colors.white ,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child:Image(height: 340, width: 310, image: AssetImage(data.placeHolder))
                    ),
                  ],
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                   Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
                    child: Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 36,
                          color: Colors.black,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 24.0, right: 24.0, top: 12.0, bottom: 12.0),
                    child: Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 17,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  ],
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(),
                )


            ]
          ) ,
        )
      ),
    );

  }

}