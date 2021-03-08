import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class MessageDateDivider extends StatelessWidget {
  final String datetime;
  final bool uppercase;
  const MessageDateDivider(
      {Key key, @required this.datetime, @required this.uppercase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = Jiffy(this.datetime);
    final now = DateTime.now();

    String dayInfo;

    if (Jiffy(createdAt).isSame(now, Units.DAY)) {
      dayInfo = "Aujourd'hui";
    } else if (Jiffy(createdAt)
        .isSame(now.subtract(Duration(days: 1)), Units.DAY)) {
      dayInfo = 'Hier';
    } else if (Jiffy(createdAt).isAfter(
      now.subtract(Duration(days: 7)),
      Units.DAY,
    )) {
      dayInfo = createdAt.format('EEEE');
    } else if (Jiffy(createdAt).isAfter(
      Jiffy(now).subtract(years: 1),
      Units.DAY,
    )) {
      dayInfo = createdAt.format('MMMM d');
    }else{
      dayInfo = createdAt.format('MMMM d');
    }

    if (uppercase) dayInfo = dayInfo.toUpperCase();
    return Column(
      children: [
        Center(child: Text(dayInfo, style: GoogleFonts.montserrat(),)),
        Divider()
      ],
    );
  }
}
