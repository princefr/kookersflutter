-- Kookers — initial schema migration.
--
-- Mirrors the data model exposed by the legacy GraphQL backend so the
-- Flutter app can switch transports without re-modelling its data.
--
-- Run order:
--   1. This file (0001_init.sql) — creates tables, indexes, RLS
--   2. 0002_triggers.sql — updated_at triggers + auto-room creation
--   3. 0003_edge_functions.sql — webhook + FCM bridge setup
--
-- After running, set up:
--   - Auth → Providers → Phone (enabled)
--   - Storage → buckets: 'publication_photos', 'profile_photos'
--   - Edge Functions → deploy supabase/functions/*

-- ---------------------------------------------------------------------------
-- ENUMS
-- ---------------------------------------------------------------------------
do $$ begin
  create type order_state as enum (
    'NOT_ACCEPTED',
    'ACCEPTED',
    'REFUSED',
    'CANCELLED',
    'DONE',
    'RATED'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type publication_type as enum ('Plates', 'Desserts');
exception when duplicate_object then null; end $$;

-- ---------------------------------------------------------------------------
-- PROFILES (auth.users.id FK; mirrors UserDef)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  first_name text,
  last_name text,
  phonenumber text,
  photo_url text,
  country text default 'FR',
  currency text default 'EUR',
  is_seller boolean default false,
  stripe_customer_id text,
  stripe_account_id text,
  default_source text,
  default_iban text,
  fcm_token text,
  notification_permission boolean default false,
  settings jsonb default '{
    "food_preferences": [],
    "food_price_ranges": [],
    "distance_from_seller": 45
  }'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- ADDRESSES
-- ---------------------------------------------------------------------------
create table if not exists public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  latitude double precision not null,
  longitude double precision not null,
  is_chosen boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_addresses_user on public.addresses(user_id);

-- ---------------------------------------------------------------------------
-- PUBLICATIONS (sellers' dish listings)
-- ---------------------------------------------------------------------------
create table if not exists public.publications (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  type publication_type default 'Plates',
  price_all numeric(10, 2) not null,
  currency text default 'EUR',
  photo_urls text[] default '{}'::text[],
  food_preferences text[] default '{}'::text[],
  allergens text[] default '{}'::text[],
  portions_available int,
  -- Geohash string used for the geohashWithinRange() lookup pattern.
  -- Computed by the application on insert; we store it denormalised
  -- so the query can use a simple BETWEEN clause.
  geohash text,
  address jsonb,
  rating_total numeric(3, 1) default 0,
  rating_count int default 0,
  like_count int default 0,
  is_open boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists idx_publications_seller on public.publications(seller_id);
create index if not exists idx_publications_geohash on public.publications(geohash);
create index if not exists idx_publications_created_at on public.publications(created_at desc);
create index if not exists idx_publications_likes on public.publications(like_count desc);

-- ---------------------------------------------------------------------------
-- LIKES (publication_id × user_id)
-- ---------------------------------------------------------------------------
create table if not exists public.publication_likes (
  publication_id uuid not null references public.publications(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (publication_id, user_id)
);

-- ---------------------------------------------------------------------------
-- ORDERS
-- ---------------------------------------------------------------------------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  short_id text unique,
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  seller_id uuid not null references public.profiles(id) on delete cascade,
  publication_id uuid not null references public.publications(id) on delete cascade,
  quantity int not null default 1,
  total_price numeric(10, 2) not null,
  fees numeric(10, 2) not null default 0,
  tip numeric(10, 2) not null default 0,
  total_with_fees numeric(10, 2) not null,
  currency text default 'EUR',
  order_state order_state default 'NOT_ACCEPTED',
  stripe_transaction_id text,
  delivery_day timestamptz,
  address jsonb,
  notification_buyer int default 0,
  notification_seller int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
create index if not exists idx_orders_buyer on public.orders(buyer_id);
create index if not exists idx_orders_seller on public.orders(seller_id);
create index if not exists idx_orders_publication on public.orders(publication_id);
create index if not exists idx_orders_state on public.orders(order_state);

-- ---------------------------------------------------------------------------
-- CHAT ROOMS + MESSAGES
-- ---------------------------------------------------------------------------
create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references public.profiles(id) on delete cascade,
  seller_id uuid not null references public.profiles(id) on delete cascade,
  publication_id uuid references public.publications(id) on delete set null,
  last_message text,
  last_message_at timestamptz,
  buyer_unread int default 0,
  seller_unread int default 0,
  created_at timestamptz default now()
);
create index if not exists idx_rooms_buyer on public.rooms(buyer_id);
create index if not exists idx_rooms_seller on public.rooms(seller_id);
create unique index if not exists uniq_rooms_pair_publication
  on public.rooms(buyer_id, seller_id, publication_id);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  message text,
  image_url text,
  is_read boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_messages_room on public.messages(room_id, created_at desc);

-- ---------------------------------------------------------------------------
-- RATINGS (one per order, after delivery)
-- ---------------------------------------------------------------------------
create table if not exists public.ratings (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  publication_id uuid not null references public.publications(id) on delete cascade,
  rater_id uuid not null references public.profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  photos text[] default '{}'::text[],
  created_at timestamptz default now(),
  unique (order_id)
);

-- ---------------------------------------------------------------------------
-- REPORTS
-- ---------------------------------------------------------------------------
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  publication_id uuid references public.publications(id) on delete cascade,
  seller_id uuid references public.profiles(id) on delete cascade,
  description text,
  created_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- IBANS + CARDS (Stripe-issued; we store the references only)
-- ---------------------------------------------------------------------------
create table if not exists public.ibans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  stripe_iban_id text not null,
  account_holder_name text,
  bank_name text,
  country text,
  currency text,
  last4 text,
  is_default boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_ibans_user on public.ibans(user_id);

create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  stripe_card_id text not null,
  brand text,
  country text,
  exp_month int,
  exp_year int,
  last4 text,
  fingerprint text,
  funding text,
  is_default boolean default false,
  created_at timestamptz default now()
);
create index if not exists idx_cards_user on public.cards(user_id);

-- ---------------------------------------------------------------------------
-- TRANSACTIONS + BALANCE
-- ---------------------------------------------------------------------------
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  stripe_transaction_id text,
  amount numeric(10, 2) not null,
  fee numeric(10, 2) default 0,
  net numeric(10, 2) not null,
  currency text default 'EUR',
  description text,
  type text,
  status text,
  reporting_category text,
  available_on timestamptz,
  created_at timestamptz default now()
);
create index if not exists idx_transactions_user on public.transactions(user_id, created_at desc);

create table if not exists public.balances (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  current_balance numeric(10, 2) default 0,
  pending_balance numeric(10, 2) default 0,
  currency text default 'EUR',
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------------
-- VERIFICATION DOCUMENTS (KYC)
-- ---------------------------------------------------------------------------
create table if not exists public.verification_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  document_type text not null,  -- 'passport' | 'hosting_certificate' | ...
  file_url text not null,
  status text default 'pending',  -- pending | approved | rejected
  created_at timestamptz default now()
);
create index if not exists idx_verification_user on public.verification_documents(user_id);

-- ---------------------------------------------------------------------------
-- SAVED SEARCHES (FEATURE_PROPOSALS.md §2.2)
-- ---------------------------------------------------------------------------
create table if not exists public.saved_searches (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  query text,
  allergens text[] default '{}'::text[],
  food_preferences text[] default '{}'::text[],
  max_price numeric(10, 2),
  distance_km int default 45,
  notify_on_match boolean default true,
  last_notified_at timestamptz,
  created_at timestamptz default now()
);
create index if not exists idx_saved_searches_user on public.saved_searches(user_id);

-- ---------------------------------------------------------------------------
-- APP CONFIG (force-upgrade etc.)
-- ---------------------------------------------------------------------------
create table if not exists public.app_config (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz default now()
);

insert into public.app_config (key, value) values
  ('minimum_app_version', '"1.0.0"'::jsonb),
  ('tip_presets', '[0, 2, 5, 10]'::jsonb),
  ('platform_fee_percent', '15'::jsonb)
on conflict (key) do nothing;
