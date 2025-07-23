import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';

enum ButtonVerificationState {
  Verified, VerificationInProgress, Missing, Error
}



class ButtonVerification extends StatelessWidget {
  final Color color;
  final String text;
  final Icon leftIcon;
  final Function onTap;
  final ButtonVerificationState status;
  
  const ButtonVerification({Key? key, this.color, required this.text, required this.leftIcon, required this.onTap, required this.status}) : super(key: key);

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

                      Builder(builder: (ctx) {
                        switch (this.status) {
                          case ButtonVerificationState.Missing:
                              return Icon(CupertinoIcons.chevron_forward, color: Colors.black, size: 24.0);
                          case ButtonVerificationState.VerificationInProgress:
                              return Icon(CupertinoIcons.clock, color: Colors.black, size: 24.0);
                          case ButtonVerificationState.Verified: 
                                return Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green, size: 24.0);
                          case ButtonVerificationState.Error: 
                                return Icon(CupertinoIcons.exclamationmark_circle_fill, color: Colors.red, size: 24.0);
                          default:
                              return Icon(CupertinoIcons.chevron_forward, color: Colors.black, size: 24.0);
                        }
                      })
                      
                    ],),
                  ),
                  
      ),
    );
  }
}