import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';



class EmptyViewElse extends StatelessWidget {
  final String text;
  const EmptyViewElse({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(this.text, style: GoogleFonts.montserrat(fontSize: 16))
        ]
      )
    );
  }
}


class EmptyView extends StatelessWidget {
  
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Container(child: Lottie.asset('assets/lottie/lf30_editor_dg6paekd.json', height: 150, fit: BoxFit.fill, repeat: true)),
          ),

          Text("Vous n'avez aucun achat", style: GoogleFonts.montserrat(fontSize: 17))
        ]
      )
    );
  }
}