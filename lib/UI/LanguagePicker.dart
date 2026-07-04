import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Services/AnalyticsService.dart';
import 'package:kookers/UI/Colors.dart';
import 'package:kookers/UI/Theme.dart';

/// Available languages, ordered consistently with `kSupportedLocales` in
/// `main.dart`. The `code` matches the JSON file name and the locale
/// code; `nameKey` is the localization key under `languages.*` so the
/// language name renders in its own script regardless of the current
/// app locale.
class _LanguageDef {
  final String code;
  final String nameKey;
  const _LanguageDef(this.code, this.nameKey);
}

const List<_LanguageDef> _kLanguages = [
  _LanguageDef('fr', 'languages.fr'),
  _LanguageDef('en', 'languages.en'),
  _LanguageDef('it', 'languages.it'),
  _LanguageDef('de', 'languages.de'),
  _LanguageDef('es', 'languages.es'),
  _LanguageDef('tr', 'languages.tr'),
];

/// Modal sheet that lets the user pick the app language.
///
/// Shows the current selection with a checkmark, and immediately
/// applies the new locale via [EasyLocalization.setLocale]. The
/// selection is persisted by easy_localization across app restarts.
Future<void> showLanguagePicker(BuildContext context) async {
  final current = context.locale;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: KookersColors.surface,
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
                    'settings.language'.tr(),
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KookersColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                    icon: const Icon(CupertinoIcons.xmark,
                        color: KookersColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ..._kLanguages.map((lang) {
              final selected = current.languageCode == lang.code;
              return ListTile(
                leading: Text(
                  _flagEmoji(lang.code),
                  style: const TextStyle(fontSize: 22),
                ),
                title: Text(
                  lang.nameKey.tr(),
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: KookersColors.textPrimary,
                  ),
                ),
                trailing: selected
                    ? const Icon(CupertinoIcons.checkmark_alt_fill,
                        color: KookersColors.primary)
                    : null,
                onTap: () {
                  sheetCtx.setLocale(Locale(lang.code));
                  KookersEvents.languageChanged(locale: lang.code);
                  Navigator.of(sheetCtx).pop();
                },
              );
            }),
            const SizedBox(height: KookersSpacing.md),
          ],
        ),
      );
    },
  );
}

/// Maps a 2-letter language code to a flag emoji for the language
/// picker. Geographically approximate; flags are not political.
String _flagEmoji(String code) {
  switch (code) {
    case 'fr':
      return '🇫🇷';
    case 'en':
      return '🇬🇧';
    case 'it':
      return '🇮🇹';
    case 'de':
      return '🇩🇪';
    case 'es':
      return '🇪🇸';
    case 'tr':
      return '🇹🇷';
    default:
      return '🌍';
  }
}
