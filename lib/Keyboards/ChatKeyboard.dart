import "package:flutter/material.dart";

enum ButtonType {
  GIPHY, Camera, Position
  
}



class ChatKeyboard extends StatelessWidget implements PreferredSizeWidget {
  static const double height = 200;
  final ValueNotifier<ButtonType> notifier;
  const ChatKeyboard({Key? key, required this.notifier}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: SizedBox(),
    );
  }
}