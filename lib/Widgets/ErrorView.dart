import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ErrorView extends StatelessWidget {
  const ErrorView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red,),
          SizedBox(height: 5),
          Text("Une erreur s'est produite, veuillez reessayer!")
        ]
      )
    );
  }
}