-- Kookers — RPC helpers used by SupabaseDatabaseProvider.
--
-- These functions are called from the Flutter client via
-- `SupabaseService.rpc(...)`. Each one wraps an operation that would
-- otherwise require multiple round-trips or that needs to run with
-- elevated privileges (SECURITY DEFINER).

-- ---------------------------------------------------------------------------
-- bump_like_count(p_publication_id uuid, p_delta int)
--
-- Atomically updates a publication's like_count. Used by
-- SupabaseDatabaseProvider.setLikePost / setDislikePost.
-- ---------------------------------------------------------------------------
create or replace function public.bump_like_count(
  p_publication_id uuid,
  p_delta int
) returns void language plpgsql security definer set search_path = public as $$
begin
  update public.publications
    set like_count = greatest(0, coalesce(like_count, 0) + p_delta)
    where id = p_publication_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- get_publications_near(p_lat float, p_lng float, p_radius_km int, p_limit int)
--
-- Returns publications within a roughly square bounding box of side
-- 2*radius_km centred on (p_lat, p_lng). A proper PostGIS geography
-- index would let us do an exact circle; this is the simple stand-in
-- that works without enabling the PostGIS extension.
-- ---------------------------------------------------------------------------
create or replace function public.get_publications_near(
  p_lat float,
  p_lng float,
  p_radius_km int default 45,
  p_limit int default 100
) returns setof public.publications language sql stable as $$
  select *
  from public.publications
  where is_open = true
    and abs((address->'location'->>'latitude')::float - p_lat) < (p_radius_km / 111.0)
    and abs((address->'location'->>'longitude')::Float - p_lng) < (p_radius_km / (111.0 * cos(p_lat * pi() / 180)))
  order by created_at desc
  limit p_limit;
$$;

-- ---------------------------------------------------------------------------
-- create_room(p_buyer_id uuid, p_seller_id uuid, p_publication_id uuid)
--
-- Idempotently creates (or returns the existing) chat room for a
-- (buyer, seller, publication) triple. Used by the buyer when they
-- tap "Message seller" from a food card.
-- ---------------------------------------------------------------------------
create or replace function public.create_room(
  p_buyer_id uuid,
  p_seller_id uuid,
  p_publication_id uuid
) returns uuid language plpgsql security definer set search_path = public as $$
declare
  v_room_id uuid;
begin
  select id into v_room_id
    from public.rooms
    where buyer_id = p_buyer_id
      and seller_id = p_seller_id
      and publication_id = p_publication_id
    limit 1;
  if v_room_id is null then
    insert into public.rooms (buyer_id, seller_id, publication_id)
      values (p_buyer_id, p_seller_id, p_publication_id)
      returning id into v_room_id;
  end if;
  return v_room_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- get_minimum_app_version()
--
-- Reads the minimum_app_version row from app_config. Used by
-- ForceUpgradeService.
-- ---------------------------------------------------------------------------
create or replace function public.get_minimum_app_version()
returns text language sql stable as $$
  select value::text from public.app_config where key = 'minimum_app_version';
$$;

-- Grant execute to anon + authenticated.
grant execute on function public.bump_like_count(uuid, int) to anon, authenticated;
grant execute on function public.get_publications_near(float, float, int, int) to anon, authenticated;
grant execute on function public.create_room(uuid, uuid, uuid) to authenticated;
grant execute on function public.get_minimum_app_version() to anon, authenticated;
