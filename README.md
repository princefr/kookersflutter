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
