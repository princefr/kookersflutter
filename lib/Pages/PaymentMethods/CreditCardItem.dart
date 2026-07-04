import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kookers/Models/PaymentModels.dart';

class CardItem extends StatelessWidget {
  final CardModel card;
  final bool? isDefault;
  final Function? onCheckBoxClicked;
  const CardItem(
      {Key? key, required this.card, this.isDefault, this.onCheckBoxClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      child: ListTile(
        autofocus: false,
        onTap: onCheckBoxClicked as GestureTapCallback?,
        leading: SvgPicture.asset(
          'assets/payments_logo/${card.brand}.svg',
          height: 30,
        ),
        title: Text('paymentMethods.cardMask'.tr() + " " + (card.last4 ?? '')),
        trailing: Visibility(
            visible: this.isDefault ?? false,
            child: Icon(CupertinoIcons.checkmark_circle, color: Colors.green)),
      ),
    );
  }
}
