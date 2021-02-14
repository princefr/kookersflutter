import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:provider/provider.dart';

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

  BottomNavigationBarItem _iconWithBadge(IconData icon, String text, Stream badgeCountstream) {
        return BottomNavigationBarItem(
        icon: StreamBuilder<dynamic>(
          stream: badgeCountstream,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) return Icon(icon);
            if(snapshot.data == 0) return Icon(icon);
            if(snapshot.data == null) return Icon(icon);
            return Badge(child: Icon(icon), badgeContent: Text(snapshot.data.toString(), style: GoogleFonts.montserrat(color: Colors.white),), elevation: 0, badgeColor: Colors.red, toAnimate: false);
          }
        ),
        label: text,
      );
  }

  

  @override
  Widget build(BuildContext context) {
    final databaseService =
            Provider.of<DatabaseProviderService>(context, listen: false);
            
    return BottomNavigationBar(
            backgroundColor: Colors.white,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedItemColor: Color(0xFFF95F5F),
            unselectedItemColor: Colors.black,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            currentIndex: selectedIndex,
            onTap: onTap,
            items: [
              _icons(CupertinoIcons.house_alt, "Accueil"),
              _iconWithBadge(Icons.shopping_bag, "Achats", databaseService.buyingNotification),
              _iconWithBadge(Icons.store, "Ventes", databaseService.sellingNotificationCount),
              _iconWithBadge(CupertinoIcons.chat_bubble, "Messages",  databaseService.messageNotificationCount),
              _icons(CupertinoIcons.gear_alt, "Réglages"),
            ],
    );
  }
}