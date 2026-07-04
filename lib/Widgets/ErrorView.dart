import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ErrorView extends StatelessWidget {
  const ErrorView({Key? key = null}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red,),
          SizedBox(height: 5),
          Text('errorView.generic'.tr())
        ]
      )
    );
  }
}
