import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double iconSize;
  final Color? backgroundColor;
  final EdgeInsets padding;

  const RatingWidget({
    Key? key,
    required this.rating,
    required this.ratingCount,
    this.iconSize = 13,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(4.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.star_fill,
              size: iconSize,
              color: Colors.yellow[900],
            ),
            SizedBox(width: 5),
            Text(
              "${rating.toStringAsFixed(2)} ($ratingCount)",
              style: TextStyle(fontSize: iconSize * 0.9),
            ),
          ],
        ),
      ),
    );
  }
}