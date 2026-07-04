# Kookers Flutter

Kookers is a cross-platform mobile marketplace that connects amateur
home chefs with nearby food lovers. Buyers browse geolocated meal
listings, place orders, pay by card or IBAN, and chat with the cook in
real time. Sellers publish dishes, manage incoming orders, and cash out
to their bank account.

## Features

- **Phone authentication** via Firebase Auth (SMS verification)
- **Geolocated feed** of publications (plates & desserts) with photo,
  price, rating, distance, and food-preference chips
- **Publishing flow** for sellers: multi-photo upload, price, dietary
  tags, geohash-based discoverability
- **Orders**: buyer-side ("Achats") and seller-side ("Ventes") tabs,
  with Stripe payment + IBAN payout support
- **Real-time chat** between buyer and seller per order
- **Push notifications** for new messages, new orders, and order status
  changes (FCM)
- **Ratings & reviews** after each completed order
- **Balance / transactions** ledger with withdrawal to a saved IBAN

## Internationalisation

The app is localised in **six languages**: French (default), English,
Italian, German, Spanish, and Turkish. Translations live in
`assets/translations/<locale>.json` and are wired in via
[`easy_localization`](https://pub.dev/packages/easy_localization).

- Add or edit a string → add a key to **all six** JSON files, then call
  `'section.key'.tr()` from the widget tree.
- Switch language at runtime → Settings → Language, or
  `EasyLocalization.of(context).setLocale(Locale('de'))`.
- Add a new locale → drop a new `<code>.json` file in
  `assets/translations/`, append `Locale('<code>')` to
  `kSupportedLocales` in `lib/main.dart`, and add an entry to
  `_kLanguages` in `lib/UI/LanguagePicker.dart`.

The previously empty `assets/translations/*.json` files (en, fr, en-US,
fr-FR) have been replaced with full translations; `en-US.json` and
`fr-FR.json` were removed because easy_localization keys off the bare
language code.

## Tech stack

| Layer | Choice |
| --- | --- |
| Framework | Flutter (Dart, null-safe) |
| State | `provider` for DI + `rxdart` `BehaviorSubject` for streams |
| Navigation | `get` (`GetMaterialApp`) + `modal_bottom_sheet` |
| Backend | Firebase (Auth, Firestore, Storage, FCM, Crashlytics) |
| API | GraphQL (`graphql_flutter`) for the Kookers backend |
| Payments | Stripe (custom integration) + IBAN |
| Maps | `google_maps_flutter`, `geocoding`, `geolocator` |

## Project layout

```
lib/
├── main.dart              App entry, providers, theme, root router
├── UI/                    Brand colours, spacing tokens, ThemeData
│   ├── Colors.dart
│   └── Theme.dart
├── TabHome/               Bottom-nav shell (5 tabs)
├── Pages/                 Feature screens (Home, Orders, Vendor, ...)
├── Widgets/               Reusable UI (EmptyView, StreamButton, ...)
├── Services/              Auth, DB, Storage, Notifications, Stripe, ...
├── Blocs/                 Phone-auth / signup form blocs
├── Models/                Data models (User, Address, Payment, ...)
└── GraphQlHelpers/        GraphQL client wiring
```

## Getting started

### Prerequisites

- Flutter 3.x SDK
- Android Studio or Xcode
- A Firebase project with:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- For release builds: `android/key.properties` + `key.jks`

### Run locally

```bash
flutter pub get
flutter run
```

### Build release

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## License

Proprietary. All rights reserved by the Kookers authors.
