import 'package:flutter/material.dart';

// ignore: must_be_immutable
class StepIndicator extends StatelessWidget {
  final int stepNumbers;
  StepIndicator({Key? key, required this.stepNumbers}) : super(key: key);

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
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Builder(builder: (ctx) {
              if (this.isActive0) {
                return Container(
                    height: 4,
                    width: 70,
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)));
              } else {
                return Container(height: 4, width: 70, color: Colors.grey);
              }
            }),
            Builder(builder: (ctx) {
              if (this.isActive1) {
                return Container(
                    height: 4,
                    width: 70,
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)));
              } else {
                return Container(height: 4, width: 70, color: Colors.grey);
              }
            }),
            Builder(builder: (ctx) {
              if (this.isActive2) {
                return Container(
                    height: 4,
                    width: 70,
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)));
              } else {
                return Container(height: 4, width: 70, color: Colors.grey);
              }
            }),
            Builder(builder: (ctx) {
              if (this.isActive3) {
                return Container(
                    height: 4,
                    width: 70,
                    child: LinearProgressIndicator(
                        backgroundColor: Colors.black,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white)));
              } else {
                return Container(height: 4, width: 70, color: Colors.grey);
              }
            }),
          ])),
    );
  }
}
