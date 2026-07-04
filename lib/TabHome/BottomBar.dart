import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:provider/provider.dart';

/// Bottom navigation bar for the main TabHome shell.
///
/// Improvements over the previous version:
///   * Reads colours from [KookersColors] / theme instead of hard-coded hex.
///   * Adds a hairline top border so the bar reads as a separate surface
///     on white backgrounds (previously it blended into the page).
///   * Tighter label sizing + SF-style icon sizing for visual rhythm.
class BottomBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onTap;

  const BottomBar({super.key, this.onTap, this.selectedIndex = 0});

  BottomNavigationBarItem _icon(IconData icon, String text) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      label: text,
    );
  }

  BottomNavigationBarItem _iconWithBadge(
      IconData icon, String text, Stream badgeCountStream) {
    return BottomNavigationBarItem(
      icon: StreamBuilder<dynamic>(
        stream: badgeCountStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Icon(icon, size: 24);
          }
          final count = snapshot.data;
          if (count == null || count == 0) return Icon(icon, size: 24);
          return Badge(
            backgroundColor: KookersColors.badge,
            textColor: Colors.white,
            label: Text(
              count.toString(),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            child: Icon(icon, size: 24),
          );
        },
      ),
      label: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: KookersColors.surface,
        border: Border(
          top: BorderSide(color: KookersColors.border, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: KookersColors.surface,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ??
            KookersColors.primary,
        unselectedItemColor:
            theme.bottomNavigationBarTheme.unselectedItemColor ??
                KookersColors.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onTap,
        items: [
          _icon(CupertinoIcons.house_alt, 'nav.home'.tr()),
          _iconWithBadge(Icons.shopping_bag, 'nav.orders'.tr(),
              databaseService.buyingNotification),
          _iconWithBadge(Icons.store, 'nav.vendor'.tr(),
              databaseService.sellingNotificationCount),
          _iconWithBadge(CupertinoIcons.chat_bubble, 'nav.messages'.tr(),
              databaseService.messageNotificationCount),
          _icon(CupertinoIcons.gear_alt, 'nav.settings'.tr()),
        ],
      ),
    );
  }
}
