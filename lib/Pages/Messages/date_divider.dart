import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';

class MessageDateDivider extends StatelessWidget {
  final String datetime;
  final bool uppercase;
  const MessageDateDivider(
      {Key? key, required this.datetime, required this.uppercase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createdAt = Jiffy.parse(this.datetime);
    final now = DateTime.now();

    String dayInfo;

    if (createdAt.isSame(Jiffy.parseFromDateTime(now), unit: Unit.day)) {
      dayInfo = "Aujourd'hui";
    } else if (createdAt
        .isSame(Jiffy.parseFromDateTime(now.subtract(Duration(days: 1))), unit: Unit.day)) {
      dayInfo = 'Hier';
    } else if (createdAt.isAfter(
      Jiffy.parseFromDateTime(now.subtract(Duration(days: 7))),
      unit: Unit.day,
    )) {
      dayInfo = createdAt.format(pattern: 'EEEE');
    } else if (createdAt.isAfter(
      Jiffy.parseFromDateTime(now).subtract(years: 1),
      unit: Unit.day,
    )) {
      dayInfo = createdAt.format(pattern: 'MMMM d');
    }else{
      dayInfo = createdAt.format(pattern: 'MMMM d');
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
