import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Orders/OrderItem.dart';


class StatusChip extends StatelessWidget {
  final OrderState state;
  const StatusChip({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Builder(builder: (BuildContext ctx){
          switch (this.state) {
            case OrderState.ACCEPTED:
                return Chip(label: Text('status.accepted'.tr(), style: GoogleFonts.montserrat()));
            case OrderState.CANCELLED:
                return Chip(label: Text('status.cancelled'.tr(), style: GoogleFonts.montserrat(color: Colors.white)), backgroundColor: Colors.red,);

            case OrderState.NOT_ACCEPTED:
                return Chip(label: Text('status.pending'.tr(), style: GoogleFonts.montserrat(),), backgroundColor: Colors.yellow,);

            case OrderState.DONE:
                return Chip(label: Text('status.done'.tr(), style: GoogleFonts.montserrat()));
            case OrderState.RATED:
                return Chip(label: Text('status.rated'.tr(), style: GoogleFonts.montserrat()));
            case OrderState.REFUSED:
                return Chip(label: Text('status.refused'.tr(), style: GoogleFonts.montserrat(color: Colors.white)), backgroundColor: Colors.red,);
            default:
              return Chip(label: Text('status.accepted'.tr(), style: GoogleFonts.montserrat()));
          }
      })
    );
  }
}
