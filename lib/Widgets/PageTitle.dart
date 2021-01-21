
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        ));
  }
}