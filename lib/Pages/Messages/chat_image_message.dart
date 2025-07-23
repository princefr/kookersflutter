import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';

class ChatImageMessage extends StatelessWidget {
  final String messagePicture;
  const ChatImageMessage({Key? key, required this.messagePicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (ctx) {
      if (this.messagePicture == "" ||
          this.messagePicture == null) return SizedBox();
      return InkWell(
        onTap: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => FullScreenImage(
                      url: this.messagePicture)));
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      this.messagePicture),
                  fit: BoxFit.cover,
                  alignment: Alignment.center)),
          height: 150,
        ),
      );
    });
  }
}
