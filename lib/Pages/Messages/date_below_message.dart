import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class DateBelowMessage extends StatelessWidget {
  final String date;
  const DateBelowMessage({Key key, @required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        Jiffy(this.date).yMMMMd == Jiffy(DateTime.now()).yMMMMd
            ? Jiffy(this.date).format("HH:mm")
            : Jiffy(this.date).format("do MMMM, HH:mm"),
        style: GoogleFonts.montserrat(fontSize: 11),
      ),
    );
  }
}
