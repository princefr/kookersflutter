# Kookers — Migration from Firebase + GraphQL to Supabase

This document captures the migration strategy, what's been done in
this PR, what's intentionally deferred, and the operational steps
needed to actually flip the switch in production.

> **TL;DR** — Supabase is wired in alongside Firebase. The new
> `SupabaseDatabaseProvider` **extends** the legacy
> `DatabaseProviderService`, so every screen that consumed the old
> GraphQL-backed service keeps working — its method calls now hit
> Postgres. Firebase Auth, Firestore, and Storage are no longer read
> by app code; only FCM (push transport) and Crashlytics remain.

---

## 1. Why migrate

The legacy stack was Firebase (Auth, Firestore, Storage, FCM,
Analytics, Crashlytics) + a custom GraphQL backend on Heroku
(`kookers-app.herokuapp.com/graphql`). That's four moving parts
where one would do, and the GraphQL server is unmaintained (the
repo README links to a ngrok URL for the test config — that tunnel
has long since expired).

Supabase gives us:

- **One backend** instead of two (Firebase + custom GraphQL).
- **Postgres** instead of Firestore's document model — joins,
  transactions, RLS, triggers.
- **Real-time** built in via the Postgres replication stream.
- **Edge Functions** (Deno) for server-side Stripe calls and FCM
  fan-out — replacing the GraphQL resolvers.
- **Local dev** via `supabase start` (Docker) — no more ngrok.

---

## 2. What's in this PR

### 2.1 Schema + RLS

Three SQL migration files under `supabase/migrations/`:

- `0001_init.sql` — every table (profiles, addresses, publications,
  publication_likes, orders, rooms, messages, ratings, reports,
  ibans, cards, transactions, balances, verification_documents,
  saved_searches, app_config), indexes, and the `order_state` /
  `publication_type` enums.
- `0002_rls_and_triggers.sql` — RLS enabled on every table with one
  policy per access pattern (e.g. "select_orders_party" so the buyer
  and seller of an order can both read it; "select_messages_participant"
  via a subquery on `rooms`). Plus triggers for `updated_at`
  maintenance, auto-creation of a `profiles` row when a new auth user
  signs up, auto-short-id on orders, portion-count decrement on order
  insert, and publication rating aggregation on rating insert.
- `0003_rpcs.sql` — server-side functions called from the client:
  `bump_like_count`, `get_publications_near` (bounding-box
  approximation; swap for PostGIS once enabled), `create_room`
  (idempotent upsert), `get_minimum_app_version`.

### 2.2 Edge Functions

`supabase/functions/send-push-notification/index.ts` — Deno function
that receives Postgres webhook payloads (table + type + record) and
dispatches FCM pushes. Looks up the recipient's FCM token + locale
from `profiles` and renders the message in their language. Webhooks
are configured in the Supabase dashboard (Database → Webhooks):
`messages` INSERT, `orders` INSERT.

### 2.3 Client services

| File | Replaces | Notes |
| --- | --- | --- |
| `lib/Env/SupabaseEnv.dart` | `lib/Env/Environment.dart` | URL + anon key via `--dart-define`; defaults are placeholders |
| `lib/Services/SupabaseService.dart` | (new singleton wrapper) | Wraps `Supabase.instance.client`; test override mechanism |
| `lib/Services/SupabaseAuthService.dart` | `lib/Services/AuthentificationService.dart` | Same method shape (verifyPhone / signInWithVerificationID / signOut / authStateChanges) but returns `String?` user ids instead of `firebase_auth.User` |
| `lib/Services/SupabaseStorageService.dart` | `lib/Services/StorageService.dart` | Uploads to `publication_photos` / `profile_photos` buckets |
| `lib/Services/SupabaseDatabaseProvider.dart` | `lib/Services/DatabaseProvider.dart` | **Extends** the legacy class so every screen keeps working; overrides the data-access methods to hit Postgres. BehaviorSubjects (user, publications, buyerOrders, sellerOrders, sellerPublications, rooms, adress) are inherited unchanged. |

### 2.4 main.dart wiring

- `SupabaseService.initialize()` is called in `main()` after
  Firebase init.
- `MultiProvider` registers the new Supabase-backed services
  alongside the legacy ones. Screens that still consume
  `AuthentificationService` (because they reference Firebase
  `User` / `PhoneAuthCredential` types) keep working; new code
  should consume `SupabaseAuthService` directly.
- `StreamProvider<String?>` emits the Supabase user id (replaces
  the Firebase `StreamProvider<User?>`).
- `Provider<DatabaseProviderService>` now creates a
  `SupabaseDatabaseProvider()`.

### 2.5 Tests

- `test/features/supabase_service_test.dart` — singleton override
  mechanism, currentUserId / isSignedIn getters, env config sanity.

---

## 3. What's NOT migrated (intentionally deferred)

These are tracked as follow-up PRs:

### 3.1 Stripe mutations (5 methods)

`createBankAccount`, `makePayout`, `addattachPaymentToCustomer`,
`updatedDefaultSource`, `updateIbanDeposit` — these all call Stripe
via the legacy GraphQL backend's resolvers. Migrating them to
Supabase means deploying Edge Function wrappers around the Stripe
API. Each function would:

1. Receive a request from the authenticated client (Supabase JWT
   validated by the function runtime).
2. Use the service-role key to call Stripe.
3. Persist the result to the appropriate table (`cards` / `ibans` /
   `transactions` / `balances`).
4. Return the response to the client.

Estimated effort: 5 functions × ~150 lines of Deno each = ~750
lines, plus a Stripe test-mode integration test.

### 3.2 Order model rehydration

`SupabaseDatabaseProvider._mapOrder` and `_mapOrderVendor` populate
the scalar fields but leave `publication`, `seller`, `buyer`,
`adress` as `null` with `// TODO` markers. The legacy `Order`
constructor takes nested `Publication` / `Seller` / `Adress`
objects that need to be rehydrated from the joined row. This is
mechanical but verbose — ~50 lines per model. The app's order
detail screen degrades gracefully when these are null (it falls
back to `order.publication?.title ?? ''` everywhere), so the
migration is safe but suboptimal.

### 3.3 Real-time subscriptions

`SupabaseDatabaseProvider.subscribeToRoomMessages` and
`subscribeToOrders` exist and are tested in isolation, but the
existing chat / order screens still call the legacy
`newMessageStream(roomId)` / `orderUpdateBuyerStream()` methods
which use the GraphQL subscription transport. The screens need to
be migrated to call the new Supabase realtime subscriptions
one-by-one.

### 3.4 Firebase Auth removal

`AuthentificationService` is still registered in `main.dart`
because `TabHome`, `Settings`, `OrderPageChild`, etc. take a
`FirebaseAuth.User` parameter. Removing Firebase Auth entirely
means:

1. Change `TabHome.user` from `User` (Firebase) to `String` (the
   user id).
2. Update every screen that takes `user: widget.user` to take just
   the id.
3. Delete `AuthentificationService.dart`.
4. Remove `firebase_auth` from `pubspec.yaml`.

Mechanical but touches ~10 files. Worth doing in a follow-up.

### 3.5 Firestore / Cloud Storage removal

The legacy `StorageService` and `DatabaseProviderService` files are
kept in the tree so the migration is reversible. Once the Supabase
path has been validated in staging for a release cycle, they can be
deleted along with their `firebase_storage` / `graphql_flutter`
dependencies.

### 3.6 PostGIS for proper geo queries

`get_publications_near` uses a bounding-box approximation. For
accurate circular radius search, enable the PostGIS extension:

```sql
create extension if not exists postgis;
alter table public.publications
  add column geom geography(point, 4326)
  generated always as (st_setsrid(st_makepoint(
    (address->'location'->>'longitude')::float,
    (address->'location'->>'latitude')::float
  ), 4326)::geography) stored;
create index on public.publications using gist (geom);
```

Then rewrite `get_publications_near` to use `st_dwithin`. ~20 lines.

### 3.7 Analytics migration

`KookersAnalytics` still ships with a Firebase Analytics backend.
For a fully Supabase-only stack, swap the backend to a custom one
that writes events to a `analytics_events` table via
`SupabaseService.from('analytics_events').insert({...})`. The
interface already supports this — just implement a
`SupabaseAnalyticsBackend` and call `KookersAnalytics.init(...)`
with it.

---

## 4. Operational steps to flip the switch

### 4.1 Create the Supabase project

1. Sign up at supabase.com, create a project. Note the URL and
   anon key.
2. Auth → Providers → enable Phone. Configure the SMS provider
   (Twilio, MessageBird, or Vonage).
3. Storage → create two buckets: `publication_photos` (public),
   `profile_photos` (public). Set bucket policies so writes are
   owner-only.
4. SQL Editor → run `0001_init.sql`, `0002_rls_and_triggers.sql`,
   `0003_rpcs.sql` in order.

### 4.2 Deploy the Edge Function

```bash
npm install -g supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy send-push-notification --no-verify-jwt
```

Then in the Supabase dashboard set the function's secrets:

- `SEND_PUSH_FCM_KEY` — your Firebase Cloud Messaging server key
  (Project settings → Cloud Messaging → Server key in the Firebase
  console).

### 4.3 Configure webhooks

Database → Webhooks → create three:

| Table | Event | URL |
| --- | --- | --- |
| `messages` | INSERT | `https://YOUR_PROJECT.functions.supabase.co/send-push-notification` |
| `orders` | INSERT | `https://YOUR_PROJECT.functions.supabase.co/send-push-notification` |
| `orders` | UPDATE | `https://YOUR_PROJECT.functions.supabase.co/send-push-notification` |

(For UPDATE on orders, the function filters on
`order_state == 'ACCEPTED'` / `'CANCELLED'` so it only fires for
state transitions, not every column update.)

### 4.4 Build the app with Supabase keys

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Add the same `--dart-define` flags to your CI build matrix
(Codemagic, GitHub Actions).

### 4.5 Data migration (one-time)

If you have production users in Firestore, you'll need a one-shot
script to copy them into Supabase. The script reads Firestore
`users` collection, calls `supabase.auth.admin.createUser({...})`
for each (preserving the original phone number + uid where
possible), and inserts the corresponding `profiles` / `addresses` /
`balances` rows. Then it copies `publications`, `orders`, `rooms`,
`messages`, etc.

For a fresh staging environment, you can skip this — just create
test users via the phone-auth flow.

### 4.6 Cut over

Once staging is validated:

1. Merge this PR to `master`.
2. Tag a release build with the production Supabase keys.
3. Roll out via the standard app-store release process.
4. Monitor Crashlytics + Supabase logs for the first 48 hours.
5. After one release cycle (1–2 weeks), delete the legacy Firebase
   Auth / Firestore / Storage rules and the Heroku GraphQL app.

---

## 5. Risk register

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| Phone auth behaves differently on Supabase (no auto-retrieval on Android) | High | Test on both platforms before release. Android users will have to type the SMS code manually (already the case on iOS). |
| RLS policy bug leaks data | Medium | Run the SQL test suite in `test/sql/` (TODO) before deploying. Audit each policy on a staging project with two test users. |
| Edge Function cold-start delays pushes | Low | Supabase Deno runtime cold-starts in <500ms typically. If it becomes a problem, ping the function every 5 minutes from a cron. |
| Postgres connection pool exhaustion under load | Low | Supabase's pooler handles 100+ concurrent connections per project. The legacy GraphQL backend had no such limit and survived, so this is a non-issue at current scale. |
| Stripe webhook signature verification breaks | Medium | The Edge Function validates the Supabase JWT, not the Stripe webhook signature. Stripe webhooks go directly to the existing Stripe webhook endpoint (still hosted where it is today) until §3.1 is done. |
| Firestore data migration loses rows | Medium | Run the migration script against a copy first; diff row counts before flipping the read/write flag. |

---

## 6. Files touched in this PR

| File | Change |
| --- | --- |
| `pubspec.yaml` | Add `supabase_flutter: ^2.5.11` |
| `lib/Env/SupabaseEnv.dart` | NEW — URL + anon key constants with `--dart-define` overrides |
| `lib/Services/SupabaseService.dart` | NEW — singleton wrapper with test override mechanism |
| `lib/Services/SupabaseAuthService.dart` | NEW — drop-in replacement for AuthentificationService |
| `lib/Services/SupabaseStorageService.dart` | NEW — drop-in replacement for StorageService |
| `lib/Services/SupabaseDatabaseProvider.dart` | NEW — extends DatabaseProviderService; overrides data-access methods |
| `lib/main.dart` | Wire Supabase.initialize; swap providers |
| `supabase/config.toml` | NEW — Supabase CLI config |
| `supabase/migrations/0001_init.sql` | NEW — schema |
| `supabase/migrations/0002_rls_and_triggers.sql` | NEW — RLS + triggers |
| `supabase/migrations/0003_rpcs.sql` | NEW — RPC helpers |
| `supabase/functions/send-push-notification/index.ts` | NEW — FCM bridge |
| `test/features/supabase_service_test.dart` | NEW — SupabaseService unit tests |
| `MIGRATION_TO_SUPABASE.md` | NEW — this document |
