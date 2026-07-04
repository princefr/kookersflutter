# Kookers — Feature & Quality Roadmap

This document is a forward-looking audit of the Kookers codebase and
product. It assumes the UX/UI fixes and i18n work from PR #12 have
landed. The goal is to identify what would take the app from "works"
to "top-notch" — both in terms of features that meaningfully improve
the user experience and engineering investments that reduce future
defects.

Each item is sized **S / M / L / XL** and tagged by category. The
order is roughly the order I'd ship them in.

---

## 1. Trust & safety — the single biggest gap

Kookers sells **food prepared by strangers in their own kitchens**.
That is a non-trivial trust ask. Today the app has phone auth + a
guidelines checklist + a 3-document KYC page, but nothing that
actively surfaces trust signals to the buyer at decision time.

### 1.1 Seller profile page with verification badges — **M**
Currently you cannot tap a seller's avatar from a food card to see
their profile. Add a `SellerProfilePage` that shows: photo, name,
member since, **verification status** (KYC verified ✓), **average
rating + count**, **response time**, **total orders fulfilled**, and
their **last 5 public reviews**. The food card should link to it.

### 1.2 Hygiene / allergy certification upload — **M**
The guidelines page asks the seller to *agree* to wear gloves, masks,
charlottes. That's a checkbox. Let sellers upload a photo of their
kitchen + a valid hygiene certificate (in France, « formation
hygiène alimentaire HACCP » is mandatory for food businesses). Show
a "Hygiene certified" badge on their profile once verified.

### 1.3 Allergen tagging on every publication — **M**
The current model has `preferences` (vegetarian, vegan, …) but no
**allergens** field. Food marketplaces are legally required in the EU
to declare the 14 mandatory allergens. Add `allergens: List<String>`
to `PublicationHome`, surface them as red chips on the food card, and
let buyers filter by "I am allergic to X" in HomeSettings — listings
containing X are then hidden.

### 1.4 Order insurance / refund guarantee — **L**
Partner with a food-delivery insurance provider (or self-insure up to
a small cap). Show a "Order protected by Kookers Guarantee" badge on
the checkout screen. If the order is cancelled by the seller or
doesn't arrive, the buyer gets an automatic refund — no support
ticket needed. This is the single biggest lever for converting
first-time buyers.

### 1.5 Report & block flow — **S**
The report flow exists (`ReportPage`) but there's no way for a buyer
to **block** a seller, and no way for a seller to **block** a buyer.
Add a "Block this user" action in the chat header; blocked users
can't message each other or see each other's listings.

---

## 2. Discovery & search

### 2.1 Search by dish name + ingredient — **M**
Today the home feed is filtered only by location + distance + food
preference chips. Add a real search bar at the top of the home feed
that does fuzzy matching on `title`, `description`, and
`preferences`. Backend-wise, this is a `searchPublications(query,
location, distance)` GraphQL query — straightforward to add.

### 2.2 Saved searches + price alerts — **M**
"Notify me when a vegetarian lasagna appears within 5km for under
15€". Stored as a `SavedSearch` document per user; a nightly Cloud
Function scans new publications and sends an FCM push when one
matches. Classic marketplace feature that drives DAU.

### 2.3 Collections / featured lists — **S**
A "Editor's picks" carousel at the top of the home feed curated by
the Kookers team. Cheap to build (one Firestore collection of
`featured_publication_ids`), high perceived polish.

### 2.4 Map view of nearby listings — **L**
A toggle on the home feed that swaps the list for a `google_maps`
view with pins for every publication. Tap a pin → bottom sheet with
the food card. Especially valuable for the "I'm hungry *now*, show
me what's around me" use case.

### 2.5 Trending / "hot this week" sort — **S**
Add a sort dropdown to the home feed: New / Trending (most ordered
this week) / Top rated / Price ↑ / Price ↓. Backend just needs an
`orderBy` parameter on the existing query.

---

## 3. Buyer experience

### 3.1 One-tap reorder from order history — **S**
On the order detail screen, add a "Commander à nouveau" button that
jumps straight to checkout with the same dish, quantity, delivery
address, and payment method. Classic food-app feature.

### 3.2 Scheduled orders — **L**
Today orders are "buy now". Add a delivery-date picker (already half
implemented in `FoodIemChild.dart` — see the `ChooseDatePage` class)
but wire it through the order model so the seller sees the requested
date in the order notification. This unlocks the "catering" use case
(office lunches, birthday cakes) which has much higher AOV than
on-demand meals.

### 3.3 Group orders / splitting the bill — **XL**
A buyer creates an order, invites friends via a shareable link, each
friend adds items and pays their share. The order only goes through
to the seller once everyone has paid. Big lift, big differentiator.

### 3.4 Live order tracking — **L**
Once a seller accepts an order, the buyer should see a status bar
(Preparing → Out for delivery → Delivered) with optional real-time
location if the seller is delivering themselves. This requires a
Firestore `order_status` field that's updated by both parties and a
streaming subscription in the buyer's order detail page.

### 3.5 Photo upload on rating — **S**
The rating flow (`RatePlate`) only collects stars + text. Let buyers
attach up to 3 photos of the dish they received. This massively
improves the social proof of the next buyer's decision.

---

## 4. Seller experience

### 4.1 Seller dashboard with revenue chart — **M**
A new tab inside `VendorPage` showing: revenue this week / this
month / all-time, orders count, average rating, top dishes. Use
`fl_chart` for the revenue sparkline. Sellers check this daily —
right now they have to mentally sum the transactions list.

### 4.2 Inventory / portion count — **S**
Each publication should have `portionsAvailable: int` that
decrements as orders come in and shows "3 portions left" on the card.
Today the seller has to manually close the sale via
`VendorPubChild`. Auto-close when portions hit 0.

### 4.3 Pre-order scheduling for sellers — **M**
Mirror to 3.2: the seller should be able to mark "available
delivery slots" on a publication (e.g. "Tue 18-20h, Wed 12-14h").
Buyers pick a slot at checkout.

### 4.4 Promote / boost a listing — **M**
Paid feature: a seller pays 2€ to pin their listing to the top of
the home feed for 24h. This is the classic monetization lever for
marketplaces — and the seller side already has Stripe wired up.

### 4.5 Multi-photo on publications — **S**
`HomePublish` lets the seller upload multiple photos today, but only
the first is shown on the card. Make the card cycle through them
with a `carousel_slider` (the dependency is already in pubspec).

---

## 5. Messaging

### 5.1 Quick replies — **S**
In `MessageInput`, add a row of tappable quick-reply chips above the
keyboard: "Bonjour 👋", "À quelle heure livrez-vous ?", "Merci !".
Removes friction for the most common messages.

### 5.2 Pre-order chat templates — **S**
When a buyer taps "Message seller" from a food card, pre-populate the
input with "Bonjour, est-ce que ce plat est disponible pour
[Demain 19h] ?" — they edit and send. Saves typing.

### 5.3 Image messages — **M**
`chat_image_message.dart` exists but the upload flow isn't wired to
`image_picker` from the chat input. Hook it up.

### 5.4 Read receipts UI — **S**
`isRead.dart` exists but isn't visible in the chat list. Show a
small "✓✓" indicator on the last outgoing message in `RoomItem`.

### 5.5 In-app calling — **L**
Some buyers prefer to call the chef. Add a "Call" button in the chat
header that opens a masked-number call (Twilio Voice SDK). Cheaper
than it sounds, big trust boost.

---

## 6. Payments & monetization

### 6.1 Apple Pay / Google Pay — **M**
Stripe supports both via `flutter_stripe`. The current `StripeServices`
is a custom integration — migrate to `flutter_stripe: ^10.0.0+1`
(which the QWEN.md file already flags as a TODO) and add the native
Pay sheets. Cuts checkout time from ~30s to ~3s.

### 6.2 Multi-currency — **M**
The user model has a `currency` field but it's hard-coded to EUR
throughout the UI. Wire it through `CurrencyService` (which exists
but is barely used) and let the user pick their currency in
Settings. Show prices in their chosen currency with FX conversion
on the fly.

### 6.3 Seller payouts to bank account (instant) — **L**
The wallet exists; withdrawals to IBAN exist. But the UX is two
separate screens (`BalancePage` + `IbanPage`) with no clear
"withdraw" CTA. Merge them into a single flow: tap "Withdraw" →
pick amount → pick IBAN → confirm → success. Add Stripe Instant
Payouts support (where available) for a 1% fee.

### 6.4 Tipping — **S**
At checkout, add an optional "Add a tip for the chef" stepper
(0€ / 2€ / 5€ / custom). 100% goes to the seller. Buyers love it,
sellers love it, platform takes no cut.

### 6.5 Subscription for power sellers — **L**
A 9.99€/month "Kookers Pro" subscription that waives the 15% platform
fee (or reduces it to 8%) for sellers who do >20 orders/month. Pure
margin shift; Stripe Billing handles the recurring charge.

---

## 7. Onboarding & growth

### 7.1 Referral program — **M**
"Invite a friend, you both get 5€ off your next order". Tracked via
a referral code in the user's Settings screen, redeemed at checkout.
Drives word-of-mouth, which is the cheapest acquisition channel for
local marketplaces.

### 7.2 Personalized onboarding — **M**
After sign-up, ask 3 questions: sweet or savory? vegetarian? max
budget per meal? Use the answers to seed `UserSettings.foodPreference`
and `foodPriceRange` so the first home feed they see isn't empty
or off-target.

### 7.3 Push notification segmentation — **M**
Today every user gets the same FCM topics (`new_message`,
`new_order`, `order_update`). Add per-locale topics so push
notifications are sent in the user's language, and per-city topics
so you can send "New chefs in Paris this week" without spamming
Lyon users.

### 7.4 Re-engagement pushes — **S**
"We miss you! Here are 3 new dishes near you." Sent after 7 / 14 /
30 days of inactivity. Backend is a Cloud Function that scans
`lastSeenAt` and queues an FCM.

### 7.5 App store screenshots in 6 languages — **S**
The screenshots in `flutter_01.png` etc. are French-only. Generate
6 sets per locale, one per onboarding step. This is a marketing
asset but it directly affects conversion in non-FR App Store
listings.

---

## 8. UX polish

### 8.1 Haptic feedback on key actions — **S**
Wrap `HapticFeedback.lightImpact()` around: like button tap, add-to-
cart, order confirmed, message sent. Cheap, feels premium.

### 8.2 Skeleton screens everywhere (not spinners) — **M**
`ShimmerCard.dart` exists but only the home feed uses it. Apply the
same shimmer pattern to Orders / Vendor / Messages / Settings —
anywhere there's a `ConnectionState.waiting` branch that currently
shows a `CircularProgressIndicator`.

### 8.3 Pull-to-refresh on every list — **S**
Most list pages have it via `SmartRefresher`, but Settings /
Verification / Balance don't. Add it consistently.

### 8.4 Empty states with CTAs — **S**
`EmptyView` already supports `ctaLabel` + `onCtaTap` (added in PR
#12) but no screen actually uses them. Wire each empty state to a
sensible action: empty orders → "Browse dishes" CTA that switches to
the Home tab; empty messages → "Order a dish to start chatting" CTA;
empty vendor listings → "Publish your first dish" CTA.

### 8.5 Dark mode — **M**
The theme system is centralized (PR #12), so adding
`KookersTheme.dark` is mostly picking token values. Follow the
Material 3 dark scheme baseline. Wire a "Dark mode" / "System" /
"Light" toggle in Settings.

### 8.6 Animated cart count badge — **S**
The bottom nav "Achats" tab badge currently shows order count, not
cart count. Add a separate cart concept (order in progress, not yet
paid) with its own badge animation when items are added.

### 8.7 On-demand permission requests — **S**
Don't ask for camera / photos / location permissions upfront. Ask
the first time the user tries to do the action that needs them, with
a one-screen "Why we need this" explainer. Higher grant rate.

### 8.8 Dynamic Type / accessibility — **M**
Test every screen at `MediaQuery.textScaleFactor` 1.5 and 2.0.
Today several screens overflow (the home top bar, the food card
preferences row). Add `Semantics(label: ...)` to every IconButton.

---

## 9. Operations & quality

### 9.1 Force-upgrade flow — **S**
Add a `minimum_app_version` field to a Firestore `config` document.
On app start, compare `package_info_plus` version against it; if
below, show a non-dismissible dialog with an "Update" button that
opens the App Store / Play Store. Prevents support tickets from
users on incompatible versions.

### 9.2 Feature flags — **M**
Add a `feature_flags` collection in Firestore (`scheduled_orders:
bool`, `apple_pay: bool`, …) consumed via a `FeatureFlags` provider.
Lets you ship features dark to production and toggle them per-user /
per-locale / per-cohort without redeploying.

### 9.3 Crash-free rate target — **M**
Crashlytics is wired up but there's no SLA. Set a 99.5% crash-free
target, triage the top 5 crashes weekly. The codebase has several
`firstWhere` calls that will throw `StateError` on empty lists
(e.g. `TabHome._onMessage.onData` line 109) — guard them.

### 9.4 Integration tests — **L**
The `test_driver/` folder is entirely commented out. Pick the 5
most critical flows (signup → first order → rate; publish → first
order received → accept → deliver → payout; chat; address change;
sign-out) and write integration tests with `integration_test`.
Run them on Codemagic CI on every PR.

### 9.5 Analytics events — **S**
Firebase Analytics is in the deps but I don't see any `logEvent`
calls. Instrument the funnel: `view_home` → `view_dish` →
`start_checkout` → `complete_order`. Without these numbers you
can't know which of the features above actually moves the needle.

### 9.6 A/B testing infrastructure — **L**
Either use Firebase Remote Config + A/B testing natively, or wire
up GrowthBook / PostHog. The first experiment worth running: does
showing the seller's photo on the food card (vs. just the dish
photo) increase CTR?

---

## 10. Technical debt

These don't ship features but they make everything above faster to
build.

### 10.1 Migrate state management to Riverpod — **XL**
The current mix of `provider` + `BehaviorSubject` + `get` works but
has zero compile-time safety. `riverpod` (with `riverpod_generator`)
gives you typed providers, async-aware widgets, and built-in test
overrides. The migration can be done screen-by-screen.

### 10.2 Replace `graphql_flutter` with `ferry` — **L**
`graphql_flutter` is in maintenance mode. `ferry` gives you typed
queries / mutations generated from your schema, cached fragments,
and `OptimisticResponse` support — critical for snappy like / cart
interactions.

### 10.3 Replace `get` with `go_router` — **M**
`Get.to(...)` works but `get` is a god-package that's also doing
state management, DI, and i18n. `go_router` is the Flutter team's
recommended declarative router — supports deep links (so a push
notification can open a specific order detail page), web URLs, and
nested navigation. Migrate gradually: `Get.to(X)` →
`context.push('/x')`.

### 10.4 Split `DatabaseProvider.dart` — **M**
At 1,669 lines, `DatabaseProvider.dart` is the largest file in the
codebase. It contains the GraphQL client, every model class
(`UserDef`, `Adress`, `Order`, `Publication`, …), and every query
and mutation. Split into `models/` (one file per class) and
`services/` (one file per domain: `OrderService`, `UserService`,
`PublicationService`, `MessageService`, …).

### 10.5 Move models to `freezed` + `json_serializable` — **M**
The hand-rolled `fromJson` / `toJson` on every model is ~600 lines
of boilerplate and a frequent source of bugs. `freezed` generates
immutable copies, equality, `toString`, JSON serialization, and
sealed unions for `OrderState`-style enums.

### 10.6 Continuous localization check — **S**
The test added in PR #12 verifies key parity across locales. Add a
second test that scans every `.dart` file for `'foo.bar'.tr()`
calls and asserts each key actually exists in `fr.json`. Catches
typos at PR time.

### 10.7 Code formatting with `dart format` — **S**
Several files (notably `FoodIemChild.dart`, `HomePublish.dart`)
have wildly inconsistent indentation. Run `dart format -l 100` on
the whole `lib/` and add it as a CI step. One-time diff,永久 benefit.

### 10.8 Dead code removal — **S**
- `lib/Pages/Orders/OrderItem.dart` lines 146/152/158 have
  `Text("this.order.publication.this")` and
  `Text("this.order.productId bitch i'm")` — obvious placeholders
  that were never replaced.
- `lib/Widgets/StateFullListView.dart`, `lib/Widgets/Toogle.dart`,
  `lib/Widgets/StepIndicator.dart` look unused — grep before
  deleting.
- The commented-out `flutter_google_places` and `google_place`
  packages in `pubspec.yaml` — pick one or remove.

---

## 11. Suggested sequencing

If I had to pick a 90-day roadmap, I'd ship in this order:

**Month 1 — Trust & polish (the foundation)**
1. Seller profile page with verification badges (1.1)
2. Allergen tagging on publications (1.3)
3. Hygiene certificate upload (1.2)
4. Empty-state CTAs (8.4)
5. Dark mode (8.5)
6. Analytics events (9.5)

**Month 2 — Discovery & buyer flow (the growth levers)**
7. Search by dish name + ingredient (2.1)
8. Trending / hot sort (2.5)
9. One-tap reorder (3.1)
10. Apple Pay / Google Pay (6.1)
11. Tipping (6.4)
12. Referral program (7.1)

**Month 3 — Seller power features (the retention loop)**
13. Seller dashboard with revenue chart (4.1)
14. Inventory / portion count (4.2)
15. Scheduled orders (3.2 + 4.3)
16. Live order tracking (3.4)
17. Force-upgrade flow (9.1)
18. Feature flags (9.2)

Everything in §10 (technical debt) should be picked off opportunistically
in parallel — none of it is on the critical path, but each item makes
the next feature cheaper to build.

---

## 12. What I deliberately did NOT propose

- **Restaurant / pro seller tier.** Kookers's positioning is amateur
  chefs. Letting restaurants in would change the unit economics and
  the brand. Stay focused.
- **Crypto / BNPL payments.** Stripe + IBAN covers the EU market
  adequately. Adding new rails is a distraction.
- **AI dish recommendations.** Trending + distance + preferences
  gets you 80% of the value for 5% of the effort. ML is a v2 feature.
- **Web app.** The Flutter web folder exists but is empty. Mobile is
  the right surface for a hyper-local food marketplace — skip web
  until you have a clear web-only use case (e.g. seller dashboard).
- **Apple Watch / Wear OS.** Not worth the engineering cost at this
  stage.
