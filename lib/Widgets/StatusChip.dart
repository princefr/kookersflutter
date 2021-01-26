import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';


class StatusChip extends StatelessWidget {
  final OrderState state;
  const StatusChip({Key key, @required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Builder(builder: (BuildContext ctx){
          switch (this.state) {
            case OrderState.ACCEPTED:
                return Chip(label: Text("Accepté", style: GoogleFonts.montserrat()));
              break;
            case OrderState.CANCELLED:
                return Chip(label: Text("Annulé", style: GoogleFonts.montserrat(color: Colors.white)), backgroundColor: Colors.red,);
              break;

            case OrderState.NOT_ACCEPTED:
                return Chip(label: Text("En attente", style: GoogleFonts.montserrat(),), backgroundColor: Colors.yellow,);
              break;

            case OrderState.DONE:
                return Chip(label: Text("Fini", style: GoogleFonts.montserrat()));
              break;
            case OrderState.RATED:
                return Chip(label: Text("Noté", style: GoogleFonts.montserrat()));
              break;
            case OrderState.REFUSED:
                return Chip(label: Text("Refusé", style: GoogleFonts.montserrat(color: Colors.white)), backgroundColor: Colors.red,);
              break;
            default:
              return Chip(label: Text("Accepté", style: GoogleFonts.montserrat()));
          }
      })
    );
  }
}