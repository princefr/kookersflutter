-- Kookers — Row-Level Security + triggers.
--
-- RLS is the single most important safety net in a Supabase app: even
-- with the anon key in the client, a user can only read or write rows
-- they own (or that are publicly readable, like publications). We
-- enable RLS on every table and add a policy per access pattern.
--
-- Naming convention:
--   "<verb>_<table>_as_<role>"
--   verb   ∈ {select, insert, update, delete}
--   role   ∈ {owner, peer, public}

-- ===========================================================================
-- RLS enable
-- ===========================================================================
alter table public.profiles                  enable row level security;
alter table public.addresses                 enable row level security;
alter table public.publications              enable row level security;
alter table public.publication_likes         enable row level security;
alter table public.orders                    enable row level security;
alter table public.rooms                     enable row level security;
alter table public.messages                  enable row level security;
alter table public.ratings                   enable row level security;
alter table public.reports                   enable row level security;
alter table public.ibans                     enable row level security;
alter table public.cards                     enable row level security;
alter table public.transactions              enable row level security;
alter table public.balances                  enable row level security;
alter table public.verification_documents    enable row level security;
alter table public.saved_searches            enable row level security;
alter table public.app_config                enable row level security;

-- ===========================================================================
-- PROFILES — each user can read all profiles (so they can see seller
-- info on a publication) but only update their own.
-- ===========================================================================
create policy "select_profiles_public" on public.profiles
  for select using (true);

create policy "insert_profile_owner" on public.profiles
  for insert with check (auth.uid() = id);

create policy "update_profile_owner" on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- ===========================================================================
-- ADDRESSES — owner-only
-- ===========================================================================
create policy "select_addresses_owner" on public.addresses
  for select using (auth.uid() = user_id);
create policy "insert_addresses_owner" on public.addresses
  for insert with check (auth.uid() = user_id);
create policy "update_addresses_owner" on public.addresses
  for update using (auth.uid() = user_id);
create policy "delete_addresses_owner" on public.addresses
  for delete using (auth.uid() = user_id);

-- ===========================================================================
-- PUBLICATIONS — publicly readable; only seller can mutate their own
-- ===========================================================================
create policy "select_publications_public" on public.publications
  for select using (is_open = true or seller_id = auth.uid());
create policy "insert_publications_seller" on public.publications
  for insert with check (auth.uid() = seller_id);
create policy "update_publications_seller" on public.publications
  for update using (auth.uid() = seller_id);
create policy "delete_publications_seller" on public.publications
  for delete using (auth.uid() = seller_id);

-- ===========================================================================
-- LIKES — anyone signed in can like; only the likers themselves can
-- unlike (delete their own row).
-- ===========================================================================
create policy "select_likes_public" on public.publication_likes
  for select using (true);
create policy "insert_likes_authenticated" on public.publication_likes
  for insert with check (auth.uid() = user_id);
create policy "delete_likes_owner" on public.publication_likes
  for delete using (auth.uid() = user_id);

-- ===========================================================================
-- ORDERS — buyer + seller of each order can read it; only buyer can
-- insert (create); either party can update state.
-- ===========================================================================
create policy "select_orders_party" on public.orders
  for select using (auth.uid() = buyer_id or auth.uid() = seller_id);
create policy "insert_orders_buyer" on public.orders
  for insert with check (auth.uid() = buyer_id);
create policy "update_orders_party" on public.orders
  for update using (auth.uid() = buyer_id or auth.uid() = seller_id)
  with check (auth.uid() = buyer_id or auth.uid() = seller_id);

-- ===========================================================================
-- ROOMS — buyer + seller of each room can read/update; either can
-- insert (start a conversation).
-- ===========================================================================
create policy "select_rooms_party" on public.rooms
  for select using (auth.uid() = buyer_id or auth.uid() = seller_id);
create policy "insert_rooms_party" on public.rooms
  for insert with check (auth.uid() = buyer_id or auth.uid() = seller_id);
create policy "update_rooms_party" on public.rooms
  for update using (auth.uid() = buyer_id or auth.uid() = seller_id);

-- ===========================================================================
-- MESSAGES — participants of the room only.
-- ===========================================================================
create policy "select_messages_participant" on public.messages
  for select using (
    exists (
      select 1 from public.rooms r
      where r.id = messages.room_id
        and (r.buyer_id = auth.uid() or r.seller_id = auth.uid())
    )
  );
create policy "insert_messages_participant" on public.messages
  for insert with check (
    exists (
      select 1 from public.rooms r
      where r.id = room_id
        and (r.buyer_id = auth.uid() or r.seller_id = auth.uid())
    )
  );

-- ===========================================================================
-- RATINGS — anyone can read ratings (they're public trust signals);
-- only the buyer of the order can create one.
-- ===========================================================================
create policy "select_ratings_public" on public.ratings
  for select using (true);
create policy "insert_ratings_buyer" on public.ratings
  for insert with check (
    exists (
      select 1 from public.orders o
      where o.id = ratings.order_id and o.buyer_id = auth.uid()
    )
  );

-- ===========================================================================
-- REPORTS — only the reporter can see their own reports; any signed-in
-- user can create one.
-- ===========================================================================
create policy "select_reports_reporter" on public.reports
  for select using (auth.uid() = reporter_id);
create policy "insert_reports_authenticated" on public.reports
  for insert with check (auth.uid() = reporter_id);

-- ===========================================================================
-- IBANS / CARDS — owner-only
-- ===========================================================================
create policy "select_ibans_owner" on public.ibans
  for select using (auth.uid() = user_id);
create policy "insert_ibans_owner" on public.ibans
  for insert with check (auth.uid() = user_id);
create policy "update_ibans_owner" on public.ibans
  for update using (auth.uid() = user_id);
create policy "delete_ibans_owner" on public.ibans
  for delete using (auth.uid() = user_id);

create policy "select_cards_owner" on public.cards
  for select using (auth.uid() = user_id);
create policy "insert_cards_owner" on public.cards
  for insert with check (auth.uid() = user_id);
create policy "update_cards_owner" on public.cards
  for update using (auth.uid() = user_id);
create policy "delete_cards_owner" on public.cards
  for delete using (auth.uid() = user_id);

-- ===========================================================================
-- TRANSACTIONS / BALANCES — owner-only
-- ===========================================================================
create policy "select_transactions_owner" on public.transactions
  for select using (auth.uid() = user_id);
create policy "select_balances_owner" on public.balances
  for select using (auth.uid() = user_id);
create policy "update_balances_owner" on public.balances
  for update using (auth.uid() = user_id);

-- ===========================================================================
-- VERIFICATION DOCUMENTS — owner-only
-- ===========================================================================
create policy "select_verification_owner" on public.verification_documents
  for select using (auth.uid() = user_id);
create policy "insert_verification_owner" on public.verification_documents
  for insert with check (auth.uid() = user_id);

-- ===========================================================================
-- SAVED SEARCHES — owner-only
-- ===========================================================================
create policy "select_saved_searches_owner" on public.saved_searches
  for select using (auth.uid() = user_id);
create policy "insert_saved_searches_owner" on public.saved_searches
  for insert with check (auth.uid() = user_id);
create policy "update_saved_searches_owner" on public.saved_searches
  for update using (auth.uid() = user_id);
create policy "delete_saved_searches_owner" on public.saved_searches
  for delete using (auth.uid() = user_id);

-- ===========================================================================
-- APP CONFIG — publicly readable (so client can fetch minimum version
-- etc.); only service_role can write (via Edge Functions).
-- ===========================================================================
create policy "select_app_config_public" on public.app_config
  for select using (true);

-- ===========================================================================
-- TRIGGERS — updated_at maintenance + auto-short-id on orders + auto
-- profile creation on auth.users insert.
-- ===========================================================================

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$ begin
  create trigger profiles_touch_updated_at
    before update on public.profiles
    for each row execute function public.touch_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger publications_touch_updated_at
    before update on public.publications
    for each row execute function public.touch_updated_at();
exception when duplicate_object then null; end $$;

do $$ begin
  create trigger orders_touch_updated_at
    before update on public.orders
    for each row execute function public.touch_updated_at();
exception when duplicate_object then null; end $$;

-- Auto-create a profile row when a new auth user signs up. Mirrors
-- the Firestore `usersExist` upsert the legacy GraphQL backend did.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, first_name, last_name, phonenumber)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    new.raw_user_meta_data->>'phone'
  )
  on conflict (id) do nothing;
  insert into public.balances (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

do $$ begin
  create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();
exception when duplicate_object then null; end $$;

-- Generate a short human-readable id for orders (e.g. "K-AB12CD").
-- Used in the order detail screen's app bar.
create or replace function public.assign_order_short_id()
returns trigger language plpgsql as $$
begin
  if new.short_id is null then
    new.short_id = 'K-' || upper(substr(encode(gen_random_bytes(4), 'hex'), 1, 6));
  end if;
  return new;
end;
$$;

do $$ begin
  create trigger orders_assign_short_id
    before insert on public.orders
    for each row execute function public.assign_order_short_id();
exception when duplicate_object then null; end $$;

-- Decrement portions_available when an order is created, and bump
-- publication rating aggregates when a new rating is inserted.
create or replace function public.decrement_portions_on_order()
returns trigger language plpgsql as $$
begin
  if new.order_state = 'NOT_ACCEPTED' then
    update public.publications
      set portions_available = greatest(0, coalesce(portions_available, 0) - new.quantity)
      where id = new.publication_id;
  end if;
  return new;
end;
$$;

do $$ begin
  create trigger orders_decrement_portions
    after insert on public.orders
    for each row execute function public.decrement_portions_on_order();
exception when duplicate_object then null; end $$;

create or replace function public.bump_publication_rating()
returns trigger language plpgsql as $$
begin
  update public.publications set
    rating_total = rating_total + new.rating,
    rating_count = rating_count + 1
  where id = new.publication_id;
  return new;
end;
$$;

do $$ begin
  create trigger ratings_bump_publication
    after insert on public.ratings
    for each row execute function public.bump_publication_rating();
exception when duplicate_object then null; end $$;

-- Realtime: publish changes on the tables the client subscribes to.
-- (Supabase v2 requires explicit publication membership.)
do $$ begin
  alter publication supabase_realtime add table public.publications;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.orders;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.rooms;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null; end $$;
