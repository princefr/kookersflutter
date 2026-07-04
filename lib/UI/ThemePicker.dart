import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/AnalyticsService.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';
import 'package:kookers/UI/ThemeController.dart';

/// Modal sheet that lets the user pick the app theme mode.
///
/// Mirrors the UX of [showLanguagePicker]: list of options with the
/// current one marked by a coral checkmark. Selection is persisted to
/// [SharedPreferences] via [ThemeController.set].
Future<void> showThemePicker(BuildContext context) async {
  final controller = ThemeController.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(KookersSpacing.lg),
              child: Row(
                children: [
                  Text(
                    'settings.theme'.tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(sheetCtx).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    icon: Icon(CupertinoIcons.xmark,
                        color: Theme.of(sheetCtx).hintColor),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final mode in KookersThemeMode.values)
              ValueListenableBuilder<KookersThemeMode>(
                valueListenable: controller,
                builder: (_, current, __) {
                  final selected = current == mode;
                  return ListTile(
                    leading: Icon(_iconFor(mode),
                        color: selected
                            ? KookersColors.primary
                            : Theme.of(sheetCtx).hintColor),
                    title: Text(
                      mode.label.tr(),
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: Theme.of(sheetCtx).textTheme.bodyLarge?.color,
                      ),
                    ),
                    trailing: selected
                        ? const Icon(CupertinoIcons.checkmark_alt_fill,
                            color: KookersColors.primary)
                        : null,
                    onTap: () {
                      controller.set(mode);
                      KookersEvents.themeChanged(mode: mode.name);
                      Navigator.of(sheetCtx).pop();
                    },
                  );
                },
              ),
            const SizedBox(height: KookersSpacing.md),
          ],
        ),
      );
    },
  );
}

IconData _iconFor(KookersThemeMode mode) => switch (mode) {
      KookersThemeMode.system => CupertinoIcons.circle_lefthalf_fill,
      KookersThemeMode.light => CupertinoIcons.sun_max_fill,
      KookersThemeMode.dark => CupertinoIcons.moon_fill,
    };
