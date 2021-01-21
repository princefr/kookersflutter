



import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ErrorBar {



  void showError(BuildContext ctx){
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(8),
      borderRadius: 8,
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      backgroundColor: Colors.red,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        
        color: Colors.white,
        ),
      duration: Duration(seconds: 5)
    ).show(ctx);
  }


  void showSuccessError(BuildContext ctx){

  }

} 