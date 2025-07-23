import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class DateBelowMessage extends StatelessWidget {
  final String date;
  const DateBelowMessage({Key? key, required this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        Jiffy.parse(this.date).yMMMMd == Jiffy.parseFromDateTime(DateTime.now()).yMMMMd
            ? Jiffy.parse(this.date).format(pattern: "HH:mm")
            : Jiffy.parse(this.date).format(pattern: "do MMMM, HH:mm"),
        style: GoogleFonts.montserrat(fontSize: 11),
      ),
    );
  }
}
