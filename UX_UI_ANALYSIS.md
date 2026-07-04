# Kookers — UX/UI Analysis & Improvement Proposal

This document captures the analysis of the Kookers Flutter app as found
on the `main` branch (commit `8210f24`), the UX/UI issues it surfaced,
and the concrete fixes shipped in this PR.

> Analysis performed by Claude. Changes are in the `ux-ui-improvements`
> branch and described at the bottom of this document.

---

## 1. App intent

**Kookers is a hyper-local food marketplace.** It connects amateur home
chefs ("sellers") with hungry neighbours ("buyers") so that buyers can
discover, order, and get home-cooked meals delivered.

The core jobs-to-be-done are:

1. **Browse** geolocated meal listings near me, filtered by food
   preferences and price range.
2. **Order** a meal: pick a quantity, pay by card or IBAN, see
   confirmation.
3. **Chat** with the cook to clarify allergens, delivery time, etc.
4. **Sell** — publish a dish (photos, price, dietary tags), receive
   orders, fulfil them, get paid into a wallet, withdraw to an IBAN.
5. **Manage account** — payment methods, bank accounts, KYC
   verification, ratings given / received.

The tech stack (Firebase phone-auth + GraphQL backend + Stripe + Google
Maps + FCM push) confirms this is a **production P2P marketplace**, not
a demo. The UX therefore has to clear a high bar: trust signals
(ratings, verified identity), clear money flows (wallet → IBAN), and
reliable real-time messaging.

---

## 2. What's broken (critical UX bugs)

These are not subjective taste calls — they are defects that prevent
core flows from working at all.

### 2.1 The home feed was missing its body

`lib/Pages/Home/homePage.dart` declared a `Scaffold` with an `appBar`
and a `floatingActionButton` but **no `body`**. The result: when a
signed-in user landed on the home tab they saw an empty white screen
with a top bar and a `+` button. The publications stream
(`databaseService.publications$`) was loaded but never rendered.

### 2.2 Bottom-nav navigation was disabled for 4 of 5 tabs

`lib/TabHome/TabHome.dart` `_onItemTapped` was:

```dart
void _onItemTapped(int index) {
  if (index != 0) {
    showCupertinoModalBottomSheet(
        expand: false,
        context: context,
        builder: (context) => BeforeSignPage(from: "tabhome"));
  } else {
    _selectedIndex.add(index);
    _controller.jumpToPage(_selectedIndex.value);
  }
}
```

So tapping "Achats", "Ventes", "Messages", or "Réglages" **always
opened the sign-up sheet**, even for fully-logged-in users. The only
way to actually reach those screens was via a push notification.

### 2.3 Inverted auth gate on the publish FAB

The same `homePage.dart` had:

```dart
onPressed: () async {
  if (databaseService.user.value.id != null) {     // ← INVERTED
    showCupertinoModalBottomSheet(... BeforeSignPage(from: "home"));
  } else {
    // publish flow
  }
}
```

`user.value.id != null` means **the user is logged in**. So a logged-in
seller pressing the `+` button was bounced to the sign-up sheet, and
the publish flow was only reachable when *not* logged in. The check
should be `id == null`.

### 2.4 Inverted auth gate on the like button

`lib/Pages/Home/FoodItem.dart` had the same inverted pattern on both
the "unlike" and "like" branches:

```dart
if (databaseService.user.value.id != null) {      // ← INVERTED
  showCupertinoModalBottomSheet(... BeforeSignPage(from: "food_item"));
} else {
  databaseService.updateLikeInPublication(...);
}
```

So only logged-out users could (theoretically) like a post — which
would then fail at the network call because there was no auth token.

### 2.5 `if (true)` dead code in the publish flow

```dart
if (true) {
  publication.uploadToServer(...).then(...).catchError(...);
}
```

The `if (true)` wrapper does nothing useful; it just adds a level of
indentation that hid the actual retry logic. Worse, the `catchError`
recurses with a 10-second retry but **keeps the `if (true)` wrapper**
in the retry path, so the second failure path was unreachable from the
UI's perspective.

### 2.6 3-second artificial splash delay

`lib/main.dart` wrapped the auth-state lookup in
`Future.delayed(Duration(seconds: 3), ...)`. Every cold launch — even
on a fast connection with a cached session — sat on the splash screen
for three full seconds before anything happened. The splash itself
also used a hard black `LinearProgressIndicator` background that
clashed with the rest of the app.

### 2.7 Bottom-nav labels were hard-coded French

`lib/TabHome/BottomBar.dart` hard-coded "Accueil / Achats / Ventes /
Messages / Réglages", even though `main.dart` declared supported
locales as `en` + `zh` (Chinese is in fact configured nowhere in the
app). The translation JSON files in `assets/translations/` are all
empty (`{}`). The app therefore presents an inconsistent language
story: French UI text, English locale resolution, no actual i18n.

### 2.8 Repo hygiene

The root directory contained:

- `.flutter-plugins 2`, `.flutter-plugins 3`, ..., `.flutter-plugins 9`
- `.flutter-plugins-dependencies 2` ... `9`
- `.packages 2` ... `.packages 10`
- `pubspec_backup.yaml`, `pubspec_minimal.yaml`
- `pe-results.md` (empty)

These are duplicate / leftover files from a previous "modernize"
commit. They confuse IDEs and contribute nothing.

---

## 3. UX/UI design issues (subjective but worth fixing)

### 3.1 No theme — every screen re-implements the visual language

The brand coral `#F95F5F` appeared in **8+ files** as a literal
`Color(0xFFF95F5F)`. Greys wandered between `Colors.grey[200]`,
`Colors.grey[300]`, `Colors.grey[400]`, and `Colors.black` for icons.
The app had no `ThemeData`, so changing the brand colour required a
repo-wide find-and-replace. Typography had the same problem:
`GoogleFonts.montserrat(...)` was called inline dozens of times with
inconsistent weights and sizes.

### 3.2 The home top bar was visually noisy

The top bar contained three rows of mixed-purpose widgets (progress
bar, logo, settings icon, address picker with chevron, divider) all
shoved into a 121-pt-tall container. The settings button used a grey
circle background that didn't read as tappable; the address text was
inside a `ListTile` so its hit area was unpredictable.

### 3.3 Onboarding had no Skip button

The 4-screen onboarding carousel only offered a circular `→` button.
Users who already understood the concept (or who re-installed the app)
had to swipe through 4 screens. The pagination dots were flat circles
that didn't visually communicate the active page beyond a fill toggle.

### 3.4 Empty states were generic and unhelpful

`EmptyView` showed a Lottie animation and the literal text *"Vous n'avez
aucun achat"* — which is wrong on the home tab (which lists
**publications**, not purchases) and unhelpful everywhere else because
it didn't suggest a next action.

### 3.5 The food card had weak information hierarchy

`FoodItem` stacked the photo, distance chip, like button, title, rating,
price, and preference chips into a 260-pt-tall column with no card
background or border. The like button was a 35-pt icon with no
background — invisible against light food photos.

### 3.6 Tab swiping was disabled

Both `TabHome` and `VendorPage` set `physics: NeverScrollableScrollPhysics()`
on their `PageView`. This is defensible for the main tab shell (you
don't want users to accidentally swipe from Messages to Settings), but
the `BottomBar` then must be the only way to switch tabs — and per §2.2
it wasn't.

### 3.7 Hard-coded `print()` statements in production code

`DatabaseProvider.loadUserData` had `print("this is my uid")` and
`print(uid)` — debug noise that ships to the user's console in
release builds.

---

## 4. Proposed direction (and what this PR ships)

The single biggest leverage point was **fixing the bugs**: an app where
the home feed is blank and 4 of 5 tabs do nothing has no UX to
critique. Beyond that, the proposal is:

### 4.1 Introduce a real theme system

New files `lib/UI/Colors.dart` and `lib/UI/Theme.dart` define:

- A `KookersColors` token set (primary, primaryDark, primarySoft,
  textPrimary, textSecondary, textMuted, background, surface,
  surfaceAlt, border, success, danger, badge).
- A `KookersTheme.light` `ThemeData` wiring those tokens into
  `colorScheme`, `appBarTheme`, `bottomNavigationBarTheme`,
  `floatingActionButtonTheme`, `chipTheme`, `inputDecorationTheme`,
  and `elevatedButtonTheme` — plus a `montserratTextTheme` for
  consistent typography.
- A `KookersSpacing` constant set so padding stops being a per-screen
  guess.

`main.dart` now wires this theme into `GetMaterialApp(theme:
KookersTheme.light)`.

### 4.2 Make the bottom nav actually navigate

`TabHome._onItemTapped` is now a one-liner that switches the
`PageView` page to whatever index was tapped. The sign-up sheet is no
longer shown to logged-in users when they try to read their messages.

### 4.3 Implement the home feed

`HomePage` now has a real `body`: a `SmartRefresher` wrapping a
`ListView.separated` of `FoodItem`s, with a shimmer placeholder while
the stream is loading and a configurable empty state. Tapping a card
pushes the existing `FoodItemChild` detail page.

### 4.4 Fix the inverted auth checks

The publish FAB and the like button both now use the correct
`if (user.value.id == null) { showSignup() } else { doAction() }`
ordering. The `if (true)` wrapper is gone; the retry path is a
separate `_tryUpload(publication, isRetry: true)` call.

### 4.5 Tighter home top bar

`HomeTopBar` is now a `StatelessWidget` that:
- uses the brand coral for the logo tint (instead of black),
- has a clear circular settings button on a soft-grey background,
- has a tappable address row with location pin + chevron,
- shows the upload progress bar only when percentage > 0 (instead of
  flickering on every rebuild).

### 4.6 Better onboarding

`OnBoardingPager` now:
- Has a top-right **Passer** (Skip) button visible on every page.
- Uses an animated pill-style page indicator that grows the active dot.
- Replaces the bare `→` arrow with a labelled CTA ("Suivant" then
  "Commencer") plus the arrow.
- Drops the heavy `BoxShadow` that was on the original button.

### 4.7 Actionable empty states

`EmptyView` now takes `title`, `subtitle`, optional `ctaLabel` and
`onCtaTap`. The default copy matches the home feed ("Aucun plat à
proximité …") instead of misusing the purchases empty state on every
screen.

### 4.8 Cleaner food card

`FoodItem` is now a proper rounded card with a 0.5-pt border. The
like button sits in a translucent dark circle so it's visible against
any food photo. The preference chips use the theme's `ChipTheme`
(soft coral background) instead of `Colors.green[100]`.

### 4.9 Splash delay cut from 3s to 600ms

`AuthenticationWrapper` now waits 600ms (enough for one frame) instead
of 3s. The splash bar uses theme colours.

### 4.10 Repo cleanup

- Removed 25 duplicate `.flutter-plugins*`, `.packages*`, and
  `.flutter-plugins-dependencies*` files.
- Removed `pubspec_backup.yaml`, `pubspec_minimal.yaml`, `pe-results.md`.
- Updated `.gitignore` so `.gradle/` and the duplicate suffix patterns
  stay out of version control.
- Replaced the broken `test/widget_test.dart` (which referenced a
  non-existent `MyApp` and a "counter" that doesn't exist) with
  smoke tests for the new theme tokens.

### 4.11 README rewritten

The README now describes what the app actually does, the tech stack,
the project layout, and how to run / build it. Previously it was the
default Flutter boilerplate ("A new Flutter project.").

---

## 5. What this PR deliberately does NOT do

To keep the PR reviewable, the following are intentionally out of
scope and would be good follow-ups:

1. ~~**Internationalisation.** French strings are still hard-coded
   everywhere. The empty `assets/translations/*.json` files should be
   filled in and the localization delegate should actually load them.
   Once that's done, the bottom-nav labels and onboarding copy should
   move behind `AppLocalizations.of(context).t(...)`.~~
   **Done** — see §7 below.
2. **State management refactor.** The mix of `provider` +
   `BehaviorSubject` + `get` works but is hard to test. A migration to
   `riverpod` or a stricter BLoC pattern would help — but that's a
   rewrite, not a UX fix.
3. **Settings page redesign.** `Settings.dart` is a 475-line wall of
   `ListTile`s with no sectioning. It should be split into grouped
   sections (Account / Payments / Legal / About) with a
   `ListView.custom` + sliver headers.
4. **Accessibility audit.** No `Semantics` labels on icon buttons, no
   `MediaQuery.textScaleFactor` testing, contrast on `textMuted` over
   `surfaceAlt` is borderline. A proper a11y pass is warranted.
5. **Onboarding illustrations** are still stock Pana illustrations.
   The brand could commission custom art for a more distinctive feel.
6. **Dark mode.** `KookersTheme.light` is the only theme; a
   `KookersTheme.dark` counterpart is straightforward to add now that
   the tokens are centralised.
7. **Splash screen** still uses `assets/logo/logo_flutter.png` which is
   the Flutter logo, not the Kookers logo. Branding should be updated.

## 7. Localization (follow-up landed)

The first version of this PR listed i18n as out-of-scope; it has since
been added in the same branch. Summary of the i18n work:

- **6 locales**: `fr` (default), `en`, `it`, `de`, `es`, `tr`.
- All visible UI strings in the main flows (nav, onboarding, home,
  orders, vendor, messages, settings, empty states, permission
  dialogs, publish form labels) now go through `'section.key'.tr()`.
- Translations live in `assets/translations/<locale>.json` — 81 keys
  per locale, validated to have identical structure across all six
  files.
- New `lib/UI/LanguagePicker.dart` ships a modal bottom sheet with
  flag emojis + checkmark; the user's choice is persisted across
  restarts by `easy_localization`.
- Empty `en-US.json` and `fr-FR.json` files removed (easy_localization
  keys off the bare language code).
- `pubspec.yaml` gains `easy_localization: ^3.0.7`.
- Settings screen has a new "Language" entry between "Identity
  verification" and "Terms of service".

Files that still contain hard-coded French copy (chat message bubbles,
balance/IBAN/payment-method sub-screens, food detail bottom sheet) are
left as-is in this PR — they can be migrated incrementally without
breaking the existing keys.

---

## 6. Files touched

| File | Change |
| --- | --- |
| `lib/UI/Colors.dart` | NEW — brand colour tokens |
| `lib/UI/Theme.dart` | NEW — ThemeData + spacing tokens |
| `lib/UI/LanguagePicker.dart` | NEW — modal sheet for switching the app locale |
| `lib/main.dart` | Apply theme, cut splash delay, rename to `KookersApp`, fix `AuthenticationWrapper`, wire `EasyLocalization` |
| `lib/TabHome/TabHome.dart` | Fix `_onItemTapped` to actually switch tabs |
| `lib/TabHome/BottomBar.dart` | Theme tokens, top border, consistent label sizing, `.tr()` labels |
| `lib/Pages/Home/homePage.dart` | Implement missing feed body, fix inverted FAB auth check, remove `if (true)`, extract `_HomeFeedShimmer`, `.tr()` strings |
| `lib/Pages/Home/FoodItem.dart` | Fix inverted like auth check, redesign card with border + themed chips + visible like button, `.tr()` |
| `lib/Pages/Home/FoodIemChild.dart` | `.tr()` on order / report / login-to-* strings |
| `lib/Pages/Home/HomePublish.dart` | `.tr()` on form labels and photo-permission dialog |
| `lib/Pages/Onboarding/OnboardingPager.dart` | Add Skip button, animated dot indicator, labelled CTA, drive text via translation keys |
| `lib/Pages/Onboarding/OnboardingPage.dart` | Resolve title / description via `.tr()` |
| `lib/Pages/BeforeSign/BeforeSignPage.dart` | `.tr()` on tagline + StreamButton labels |
| `lib/Pages/Orders/OrdersPage.dart` | `.tr()` page title + empty state |
| `lib/Pages/Vendor/VendorPage.dart` | `.tr()` page title, tab labels, empty states |
| `lib/Pages/Messages/RoomsPage.dart` | `.tr()` page title + empty state |
| `lib/Pages/Settings/Settings.dart` | `.tr()` every item, add Language entry + photo-permission dialog localised |
| `lib/Widgets/EmptyView.dart` | Make empty states configurable + actionable, defaults resolve via `.tr()` |
| `assets/translations/{fr,en,it,de,es,tr}.json` | 6 new full translation files (81 keys each) |
| `pubspec.yaml` | Add `easy_localization: ^3.0.7` |
| `test/widget_test.dart` | Replace broken counter test with theme smoke tests |
| `README.md` | Real project description, stack, layout, run instructions, i18n section |
| `UX_UI_ANALYSIS.md` | This document |
| `.gitignore` | Ignore `.gradle/` and duplicate config suffixes |
| repo root | Removed 25 duplicate config files + `pubspec_backup.yaml` + `pubspec_minimal.yaml` + `pe-results.md` + empty `en-US.json`/`fr-FR.json` |
