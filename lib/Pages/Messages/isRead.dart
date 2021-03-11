import 'package:flutter/material.dart';





class IsReadWidget extends StatelessWidget {
  const IsReadWidget({Key key, @required this.isRead, @required this.isSent}) : super(key: key);
  final bool  isRead;
  final bool isSent;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext cxt){
      if(this.isSent == true && this.isRead == false){
        return Icon(Icons.check, size: 17);
      }else if(this.isSent == true && this.isRead == true) {
        return Icon(Icons.done_all, size: 17);
      }else{
        return Icon(Icons.timelapse_rounded, size: 17);
      }
    });
  }
}