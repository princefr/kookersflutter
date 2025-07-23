import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/CurrencyService.dart';

class PriceDisplay extends StatelessWidget {
  final String price;
  final String currency;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;

  const PriceDisplay({
    Key? key,
    required this.price,
    required this.currency,
    this.fontSize = 20,
    this.color,
    this.fontWeight = FontWeight.normal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "$price ${CurrencyService.getCurrencySymbol(currency)}",
      style: GoogleFonts.montserrat(
        color: color ?? Colors.grey,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}