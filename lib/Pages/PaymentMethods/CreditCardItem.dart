
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';



class CardModel {
   final String id;
   final String brand;
   final int expMonth;
   final int expYear;
   final String last4;

    CardModel({this.id, this.brand, this.expMonth, this.expYear, this.last4});

    static CardModel fromJson(Map<String, dynamic> map) => CardModel(
      id: map["id"],
      brand: map["brand"],
      expMonth: map["exp_month"],
      expYear: map["exp_year"],
      last4: map["last4"]
    );

    static List<CardModel> fromJsonTolist(List<Object> map){
      List<CardModel> allsources = [];
      map.forEach((element) {
        final source = CardModel.fromJson(element);
        allsources.add(source);
      });

      return allsources;
    }
}


class CardItem extends StatelessWidget {
  final CardModel card;
  final bool isDefault;
  final Function onCheckBoxClicked;
  const CardItem({Key key, @required this.card, this.isDefault, this.onCheckBoxClicked}) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      child: ListTile(
        onTap: onCheckBoxClicked,
        leading: SvgPicture.asset(
            'assets/payments_logo/${card.brand}.svg',
            height: 30,
          ),
        title: Text("****" + " " +card.last4),
        trailing: Visibility(visible: this.isDefault, child: Icon(CupertinoIcons.checkmark_circle, color: Colors.green)),
       
      ),
    );
  }
}