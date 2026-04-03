# Kookers Flutter - Project Context

## Project Overview

**Kookers** is a cross-platform mobile application (iOS/Android) built with Flutter for a food marketplace platform. The app connects buyers with food sellers/vendors, featuring:

- **User authentication** via phone number (Firebase Auth)
- **Multi-vendor marketplace** for food products
- **Order management** system
- **Payment processing** (Stripe, IBAN/bank transfers)
- **Real-time messaging** between buyers and sellers
- **Push notifications** via Firebase Cloud Messaging
- **Location services** (Google Maps, geocoding)
- **Rating & reviews** system
- **Balance/transactions** tracking

**Version:** 1.1.3+12  
**Package ID:** `com.getkookers.android` (Android), `1529436130` (iOS App Store)

---

## Tech Stack

### Core Framework
- **Flutter** (SDK: >=3.0.0 <4.0.0)
- **Dart** (null-safe, modern patterns with `super.key`, `const` constructors)

### State Management
- **Provider** ^6.1.2 - Primary DI and state management
- **GetX (get)** ^4.6.6 - Navigation and lightweight state management
- **RxDart** ^0.28.0 - Reactive streams and BehaviorSubject

### Backend Services
- **Firebase Suite:**
  - Firebase Core ^2.32.0
  - Firebase Auth ^4.20.0 (phone authentication)
  - Firebase Firestore (database)
  - Firebase Storage ^11.7.7 (file uploads)
  - Firebase Cloud Messaging ^14.9.4 (push notifications)
  - Firebase Analytics ^10.10.7
  - Firebase Crashlytics ^3.5.7
  - Firebase Performance ^0.9.4+7

- **GraphQL** - `graphql_flutter` ^5.2.0-beta.8

### Payment
- **Stripe** - Custom integration (migrate to `flutter_stripe` ^10.0.0+1)
- **IBAN** - Bank transfer support (European payments)

### Key Dependencies
| Category | Packages |
|----------|----------|
| UI Components | `google_fonts` ^6.2.1, `lottie` ^3.3.1, `shimmer` ^3.0.0, `carousel_slider` ^5.1.2, `photo_view` ^0.15.0, `badges` ^3.1.2, `flutter_chat_bubble` ^2.0.0, `chips_choice` ^3.0.1, `flutter_rating_bar` ^4.0.1, `toggle_switch` ^2.3.0 |
| Navigation | `get` ^4.6.6, `modal_bottom_sheet` ^3.0.0, `url_launcher` ^6.3.0, `webview_flutter` ^4.13.0 |
| Media | `cached_network_image` ^3.4.0, `flutter_svg` ^2.2.0, `image_picker` ^1.1.2 |
| Maps/Location | `google_maps_flutter` ^2.14.2, `geolocator` ^10.1.1, `geocoding` ^2.2.2 |
| Utilities | `uuid` ^4.5.1, `jiffy` ^6.4.3, `package_info_plus` ^8.3.1, `permission_handler` ^11.4.0, `enum_to_string` ^2.1.0, `path_provider` ^2.1.5, `shared_preferences` ^2.2.3 |
| Forms/Validation | `keyboard_actions` ^4.2.0, `iban` ^1.0.1, `country_code_picker` ^3.3.0 |
| Ratings | `rate_my_app` ^2.2.0, `flutter_app_badger` ^1.5.0 |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase init, Provider setup
├── Blocs/                       # Business logic components
│   ├── GuidelinesBloc.dart
│   ├── IbanBloc.dart
│   ├── PhoneAuthBloc.dart      # Phone authentication logic
│   ├── PhoneCodeBloc.dart
│   └── SignupBloc.dart
├── Core/                        # Core validation logic
│   ├── BaseValidationBloc.dart
│   └── ValidationTransformers.dart
├── Env/                         # Environment configuration
│   └── Environment.dart
├── GraphQlHelpers/              # GraphQL client helpers
│   └── ClientProvider.dart
├── Keyboards/                   # Custom keyboard widgets
│   └── ChatKeyboard.dart
├── Mixins/                      # Shared mixin utilities (validations)
├── Models/                      # Data models
│   ├── User.dart               # UserDef, SellerDef, BuyerVendor, UserSettings
│   ├── Address.dart            # Address model
│   ├── Balance.dart            # Balance/transaction models
│   ├── Location.dart           # Location data
│   └── PaymentModels.dart      # CardModel, BankAccount, StripeAccount, Transaction
├── Pages/                       # Screen implementations (17 feature modules)
│   ├── Balance/
│   ├── BeforeSign/
│   ├── Home/
│   ├── Iban/
│   ├── Messages/               # Chat/messaging screens
│   ├── Notifications/
│   ├── Onboarding/
│   ├── Orders/                 # Order management
│   ├── PaymentMethods/
│   ├── PhoneAuth/
│   ├── Ratings/
│   ├── Reports/
│   ├── Settings/
│   ├── Signup/
│   ├── Terms/
│   ├── Vendor/                 # Vendor/seller pages
│   └── Verification/
├── Services/                    # Business logic services
│   ├── AuthentificationService.dart
│   ├── DatabaseProvider.dart   # Firestore operations
│   ├── StorageService.dart     # Firebase Storage
│   ├── NotificiationService.dart
│   ├── OrderProvider.dart
│   ├── PublicationProvider.dart
│   ├── StripeServices.dart     # Stripe payment handling
│   ├── UserService.dart
│   ├── AnalyticsService.dart
│   ├── CrashService.dart
│   ├── CurrencyService.dart
│   ├── ErrorBarService.dart
│   └── PermissionHandler.dart
├── TabHome/                     # Main tabbed navigation
│   ├── TabHome.dart
│   └── BottomBar.dart
└── Widgets/                     # Reusable UI components
```

**Assets:**
```
assets/
├── logo/
├── onboarding/
├── lottie/
├── payments_logo/
└── translations/
```

---

## Building and Running

### Prerequisites
- Flutter SDK 3.x
- Android Studio / Xcode
- Java 17 (for Android builds)
- Firebase project configured with:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`
- Keystore configured for release builds (`key.properties`, `key.jks`)

### Setup
```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Run in debug mode with verbose logging
flutter run --verbose

# Build release APK (Android)
flutter build apk --release

# Build iOS release
flutter build ios --release
```

### Android Configuration
- **minSdkVersion:** 23
- **targetSdkVersion:** 34
- **compileSdkVersion:** 34
- **Gradle:** 8.2
- **Kotlin:** 1.9.22
- **Java:** 17

### Environment Configuration
- Release signing: `android/key.properties` and keystore file
- Firebase configuration files must be present

### CI/CD
- **Codemagic** configured for automated builds

---

## Architecture Patterns

### State Management
- **Provider** for dependency injection and global state (Auth, Database, Notifications, Storage)
- **StreamProvider** for auth state changes
- **BehaviorSubject** (RxDart) for reactive state in widgets
- **GetX** for navigation (`GetMaterialApp`)

### Authentication Flow
```
main() → Firebase.initializeApp() → AuthentificationnWrapper
                                    ├── No user → OnBoardingPager
                                    └── User exists → DatabaseProvider.loadUserData() → TabHome
```

### Key Models
- **UserDef** - Main user model with nested settings, addresses, payment methods, balance
- **SellerDef** - Seller-specific data
- **StripeAccount** - Stripe integration data (charges/payouts enabled, requirements)
- **Balance** - User balance tracking
- **Transaction** - Payment transaction history

---

## Development Conventions

### Code Style
- **Null safety** enabled (Dart 3.x)
- **Provider pattern** for service injection
- **Stream-based** auth state management
- **FutureBuilder** for async UI updates
- Linting configured via `analysis_options.yaml`

### Modern Dart Patterns Applied
- `super.key` instead of `super(key: key)`
- `const` constructors where applicable
- `VoidCallback` instead of `Function` for callbacks
- `BehaviorSubject<T>` with proper disposal
- Null-aware operators (`?.`, `??`, `!`)
- Collection literals (`[]`, `{}`) instead of `new List/Map`

### Testing
- Basic test structure in `test/widget_test.dart`
- `flutter_test` and `integration_test` configured

### Localization
- Supported locales: English (`en`), Chinese (`zh`)
- Default locale: English
- Translation files in `assets/translations/`

### Platform Support
- **Android:** minSdk 23, targetSdk 34, multidex enabled
- **iOS:** minSdk 12.0

---

## Key Features Implementation

### Phone Authentication
- Implemented in `Blocs/PhoneAuthBloc.dart`, `Blocs/PhoneCodeBloc.dart`
- Uses Firebase Auth phone verification flow
- SMS code verification with timeout handling

### Messaging
- Real-time chat in `Pages/Messages/`
- Firebase Cloud Messaging for push notifications
- Topic subscriptions: `new_message`, `new_order`, `order_update`

### Payments
- Stripe integration via `Services/StripeServices.dart`
- IBAN/bank transfer support (European SEPA)
- Balance tracking and transaction history
- **Migration note:** Consider migrating to `flutter_stripe` package

### Vendor/Buyer Roles
- Users can be buyers, sellers, or both
- Vendor-specific pages in `Pages/Vendor/`
- Seller verification flow in `Pages/Verification/`

---

## Modernization Changes Applied

### Removed Files
- 16 duplicate `.flutter-plugins*` files
- 9 duplicate `.packages*` files
- `pubspec_backup.yaml`
- `pubspec_minimal.yaml`
- 9 duplicate iOS `Flutter*.podspec` files

### Updated Dependencies
- SDK: `>=3.0.0 <4.0.0`
- All packages updated to latest compatible versions
- Removed deprecated `package_info` (replaced with `package_info_plus`)
- Removed deprecated `stripe_payment` (custom integration prepared)
- Updated Firebase packages to latest stable versions
- Added `flutter_lints` for code quality

### Android Build Updates
- **Gradle:** 6.7 → 8.2
- **Kotlin:** 1.3.50 → 1.9.22
- **AGP:** 4.1.0 → 8.2.1
- **Java:** 1.8 → 17
- **minSdk:** 19 → 23
- **targetSdk:** 30 → 34
- **compileSdk:** 30 → 34
- Added ProGuard rules for release builds
- Updated to new Flutter Gradle Plugin system
- Added `namespace` to app build.gradle

### iOS Build Updates
- **platform:** 10.0 → 12.0
- Updated Podfile with modern configuration
- Added RunnerTests target

### Code Modernization

#### Blocs (`lib/Blocs/`)
- Updated to modern Dart patterns
- Fixed getter naming conventions (`inPhoneCode` instead of `inphoneCode`)
- Proper `const` usage

#### Core (`lib/Core/`)
- Modernized `BaseValidationBloc.dart`
- Updated `ValidationTransformers.dart` with const patterns

#### Models (`lib/Models/`)
- Added proper null safety
- Factory constructors for `fromJson`
- Collection literals
- Fixed enum constant naming

#### Services (`lib/Services/`)
- Modern async/await patterns
- Proper disposal of streams
- Removed deprecated patterns
- Renamed `PermissionHandler` to `PermissionHandlerService`

#### Widgets (`lib/Widgets/`)
- `super.key` pattern
- `const` constructors
- `PreferredSizeWidget` for TopBar classes
- Fixed `WebView` to use `WebViewWidget` controller pattern
- Updated enum usage

#### TabHome (`lib/TabHome/`)
- Modern StatefulWidget patterns
- Proper disposal of subscriptions
- `const` constructors

#### Main (`lib/main.dart`)
- `const MyApp()`
- Proper async handling
- Fixed snapshot variable naming

### New Files Added
- `analysis_options.yaml` - Linting configuration
- `android/app/proguard-rules.pro` - ProGuard rules for release

---

## Useful Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter build apk

# Run tests
flutter test

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade

# Generate localization (if using l10n)
flutter gen-l10n
```

---

## Known Issues & TODOs

1. **Stripe Integration:** Migrate from deprecated `stripe_payment` to `flutter_stripe` ^10.0.0+1
2. **Pages Refactoring:** Some Pages files need additional null-safety fixes (legacy code)
3. **Translation Files:** `assets/translations/en.json` is empty - needs population
4. **Widget Tests:** Expand test coverage beyond basic widget test
5. **OrderState Enum:** Ensure consistent naming (camelCase) across all files

---

## Migration Notes

### For Developers Continuing Work

1. **Enum Naming:** All enums now use `camelCase` (e.g., `ButtonVerificationState.verified` not `Verified`)
2. **Service Naming:** `PermissionHandler` → `PermissionHandlerService`
3. **Bloc Getters:** Standardized getter names (e.g., `inPhoneCode`, `inUserCountry`)
4. **WebView:** Now uses `WebViewWidget(controller: controller)` pattern
5. **TopBar:** Now implements `PreferredSizeWidget` instead of extending `PreferredSize`
