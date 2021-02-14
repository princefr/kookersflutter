import 'package:flutter/material.dart';





// ignore: must_be_immutable
class StepIndicator extends StatelessWidget {
  final int stepNumbers;
  StepIndicator({Key key, this.stepNumbers}) : super(key: key);


  bool isActive0 = false;
  bool isActive1 = true;
  bool isActive2 = false;
  bool isActive3 = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ignore: missing_return
            Builder(builder: (ctx){
              switch (this.isActive0) {
                case true:
                  return Container(height: 4, width:70, child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
                case false:
                  return Container(height: 4, width:70,  color: Colors.grey);

              }
            }),

                      // ignore: missing_return
                      Builder(builder: (ctx){
              switch (this.isActive1) {
                case true:
                  return Container(height: 4, width:70, child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
                case false:
                  return Container(height: 4, width: 70,  color: Colors.grey);

              }
            }),

                      // ignore: missing_return
                      Builder(builder: (ctx){
              switch (this.isActive2) {
                case true:
                  return Container(height: 4, width:70, child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
                case false:
                  return Container(height: 4, width: 70, color: Colors.grey);

              }
            }),

                      // ignore: missing_return
                      Builder(builder: (ctx){
              switch (this.isActive3) {
                case true:
                  return Container(height: 4, width:70, child: LinearProgressIndicator(backgroundColor: Colors.black, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
                case false:
                  return Container(height: 4, width: 70,  color: Colors.grey);

              }
            }),

        ])
      ),
    );
  }
}