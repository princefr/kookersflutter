import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// https://flutter.github.io/cupertino_icons/ cupertino icons



class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)  onTap;

  const BottomBar({Key key, this.onTap, this.selectedIndex}):super(key: key);

  BottomNavigationBarItem _icons(IconData icon, String text) {
        return BottomNavigationBarItem(
        icon: Icon(icon),
        label: text,
      );
  }


 


  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
            backgroundColor: Colors.white,
            showUnselectedLabels: false,
            showSelectedLabels: true,
            selectedItemColor: Color(0xFFF95F5F),
            unselectedItemColor: Colors.black,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: onTap,
            items: [
              _icons(CupertinoIcons.house_alt, "Accueuil"),
              _icons(CupertinoIcons.cart, "Achats"),
              _icons(CupertinoIcons.arrow_down_circle_fill, "Ventes"),
              _icons(CupertinoIcons.chat_bubble, "Messages"),
              _icons(CupertinoIcons.gear_alt, "Réglages"),
            ],
    );
  }
}