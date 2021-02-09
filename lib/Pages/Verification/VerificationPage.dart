import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Widgets/TopBar.dart';



class VerificationPage extends StatefulWidget {
  VerificationPage({Key key}) : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
            appBar: TopBarWitBackNav(
            title: "Iban",
            rightIcon: CupertinoIcons.plus,
            isRightIcon: false,
            height: 54,
            onTapRight: null),

      body: SafeArea(
        child: Container()
      ),
    );
  }
}