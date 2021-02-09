import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';





class ButtonVerification extends StatelessWidget {
  final Color color;
  final String text;
  final Icon leftIcon;
  final Function onTap;
  
  const ButtonVerification({Key key, this.color, @required this.text, @required this.leftIcon, @required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
          onTap: this.onTap,
          child: Container(
          height: 54,
          decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      this.leftIcon,

                      SizedBox(height: 15),

                      Padding(
                          padding: const EdgeInsets.only(left:15),
                          child: Text(text, style: GoogleFonts.montserrat()),
                      ),

                      Expanded(
                            child: SizedBox(),
                      ),
                      
                    ],),
                  ),
                  
      ),
    );
  }
}