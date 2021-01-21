import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';



class KookersButton extends StatelessWidget {
  final Color color;
  final String text;
  final Icon lefticon;
  final Color textcolor;

  KookersButton ({this.color, this.text, this.lefticon, this.textcolor});

  @override
  Widget build(BuildContext context) {
    return  Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                  color: color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[

                      Expanded(
                          child: SizedBox(),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left:15),
                        child: Text(text, style: GoogleFonts.montserrat(color: textcolor, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),

                      Expanded(
                          child: SizedBox(),
                      ),

                      
                    ]
                  ),
                ),
            );
  }


  


}