import 'package:flutter/material.dart';



class UnreadCountIndicator extends StatelessWidget {
  final int? count;
  const UnreadCountIndicator({Key? key, this.count}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if((this.count ?? 0) > 0)return Container(margin: const EdgeInsets.only(top: 5.0),height: 25,width: 25,decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.all(Radius.circular(25.0))),child: Center(child: Text((this.count ?? 0) > 99 ? "99+": (this.count ?? 0).toString(),style: TextStyle(fontSize: 11, color: Colors.white),)),);
      return SizedBox();
      
    });
  }
}