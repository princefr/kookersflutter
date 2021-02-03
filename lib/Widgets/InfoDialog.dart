import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class InfoDialog extends StatelessWidget {
  final String infoText;
  const InfoDialog({Key key, @required this.infoText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: AnimatedContainer(
      curve: Curves.bounceInOut,
      duration: Duration(milliseconds: 400),
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.0), color: Colors.white),
      
      height: 200,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Container(child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(this.infoText, style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              color: Colors.black54,
              decoration: TextDecoration.none
            ),),

            SizedBox(height: 40),
            Divider(),

            GestureDetector(onTap: (){Navigator.pop(context);}, child: Text("Compris", style: GoogleFonts.openSans(fontSize: 17, decoration: TextDecoration.none, color: Colors.black),))
          ],
        ),
      )),
    ),
        ),
      );
  }
}