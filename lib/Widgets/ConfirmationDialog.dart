import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';




class ConfirmationDialog extends StatelessWidget {
  final String infoText;
  final Function onAcceptTap;
  const ConfirmationDialog({Key key, @required this.infoText, this.onAcceptTap}) : super(key: key);

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

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(onTap: (){Navigator.pop(context);}, child: Text("Annuler", style: GoogleFonts.openSans(fontSize: 17, decoration: TextDecoration.none, color: Colors.black),)),
                SizedBox(width: 40),
                GestureDetector(onTap: (){
                  Navigator.pop(context);
                  this.onAcceptTap();
                }, child: Text("Confirmer", style: GoogleFonts.openSans(fontSize: 17, decoration: TextDecoration.none, color: Colors.black),)),
              ],
            )
          ],
        ),
      )),
    ),
        ),
      );
  }
}