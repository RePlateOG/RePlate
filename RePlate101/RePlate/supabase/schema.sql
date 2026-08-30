-- ============================================================
-- RePlate — Supabase schema
-- Run this in the Supabase Dashboard → SQL Editor → New query → Run.
-- Safe to re-run (uses IF NOT EXISTS / CREATE OR REPLACE where possible).
-- ============================================================

-- ---------- Extensions ----------
create extension if not exists "pgcrypto";   -- gen_random_uuid()

-- ---------- Enums ----------
do $$ begin
  create type account_type     as enum ('customer', 'restaurant');
exception when duplicate_object then null; end $$;

do $$ begin
  create type listing_category as enum ('Meals','Bakery','Produce','Beverages','Desserts','Snacks','Other');
exception when duplicate_object then null; end $$;

do $$ begin
  create type listing_status   as enum ('active','sold_out','expired','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type order_status     as enum ('pending','confirmed','ready','completed','cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type message_type     as enum ('text','image','system');
exception when duplicate_object then null; end $$;

-- ---------- updated_at helper ----------
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- ============================================================
-- profiles  (one row per auth user)
-- ============================================================
create table if not exists public.profiles (
  id                 uuid primary key references auth.users(id) on delete cascade,
  email              text,
  name               text,
  phone_number       text,
  profile_image_url  text,
  account_type       account_type not null default 'customer',
  verified_restaurant boolean not null default false,
  meals_saved        integer not null default 0,
  co2_reduced        numeric  not null default 0,
  food_rescued       numeric  not null default 0,
  accepted_terms_at  timestamptz,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
drop trigger if exists trg_profiles_updated on public.profiles;
create trigger trg_profiles_updated before update on public.profiles
  for each row execute function set_updated_at();

-- Auto-create a profile row when a user signs up.
-- Reads name / account_type from the sign-up metadata (options.data in the app).
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, name, account_type)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce((new.raw_user_meta_data->>'account_type')::account_type, 'customer')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================
-- restaurants
-- ============================================================
create table if not exists public.restaurants (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references public.profiles(id) on delete cascade,
  name            text not null,
  description     text,
  address         text,
  latitude        double precision,
  longitude       double precision,
  phone_number    text,
  email           text,
  image_url       text,
  cover_image_url text,
  cuisine         text[] not null default '{}',
  rating          numeric not null default 0,
  total_reviews   integer not null default 0,
  verified        boolean not null default false,
  is_premium      boolean not null default false,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);
create index if not exists idx_restaurants_owner on public.restaurants(owner_id);
drop trigger if exists trg_restaurants_updated on public.restaurants;
create trigger trg_restaurants_updated before update on public.restaurants
  for each row execute function set_updated_at();

-- ============================================================
-- listings
-- ============================================================
create table if not exists public.listings (
  id                 uuid primary key default gen_random_uuid(),
  restaurant_id      uuid not null references public.restaurants(id) on delete cascade,
  title              text not null,
  description        text,
  category           listing_category not null default 'Meals',
  image_urls         text[] not null default '{}',
  original_price     numeric not null default 0,
  discounted_price   numeric not null default 0,
  is_free            boolean not null default false,
  quantity           integer not null default 1 check (quantity >= 0),
  available_quantity integer not null default 1 check (available_quantity >= 0),
  pickup_start_time  timestamptz,
  pickup_end_time    timestamptz,
  status             listing_status not null default 'active',
  tags               text[] not null default '{}',
  dietary_info       text[] not null default '{}',
  created_at         timestamptz not null default now(),
  expires_at         timestamptz,
  updated_at         timestamptz not null default now(),
  -- SECURITY: prices must be non-negative; discounted cannot exceed original.
  constraint price_sane check (discounted_price >= 0 and original_price >= 0 and discounted_price <= original_price)
);
create index if not exists idx_listings_restaurant on public.listings(restaurant_id);
create index if not exists idx_listings_status on public.listings(status);
drop trigger if exists trg_listings_updated on public.listings;
create trigger trg_listings_updated before update on public.listings
  for each row execute function set_updated_at();

-- ============================================================
-- orders
-- ============================================================
create table if not exists public.orders (
  id                  uuid primary key default gen_random_uuid(),
  listing_id          uuid references public.listings(id) on delete set null,
  customer_id         uuid not null references public.profiles(id) on delete cascade,
  restaurant_id       uuid not null references public.restaurants(id) on delete cascade,
  quantity            integer not null default 1 check (quantity > 0),
  total_amount        numeric not null default 0 check (total_amount >= 0),
  status              order_status not null default 'pending',
  -- Single-use pickup code, verified in person by the restaurant.
  pickup_code         text not null default upper(substr(replace(gen_random_uuid()::text,'-',''),1,6)),
  pickup_code_used    boolean not null default false,
  pickup_window_start timestamptz,
  pickup_window_end   timestamptz,
  notes               text,
  payment_id          text,        -- reference only; never store raw card data
  created_at          timestamptz not null default now(),
  completed_at        timestamptz,
  updated_at          timestamptz not null default now()
);
create index if not exists idx_orders_customer   on public.orders(customer_id);
create index if not exists idx_orders_restaurant on public.orders(restaurant_id);
create index if not exists idx_orders_status     on public.orders(status);
drop trigger if exists trg_orders_updated on public.orders;
create trigger trg_orders_updated before update on public.orders
  for each row execute function set_updated_at();

-- ============================================================
-- conversations + messages
-- ============================================================
create table if not exists public.conversations (
  id            uuid primary key default gen_random_uuid(),
  order_id      uuid references public.orders(id) on delete cascade,
  customer_id   uuid not null references public.profiles(id) on delete cascade,
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
create index if not exists idx_conversations_customer on public.conversations(customer_id);

create table if not exists public.messages (
  id              uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id       uuid not null references public.profiles(id) on delete cascade,
  content         text not null,
  message_type    message_type not null default 'text',
  read            boolean not null default false,
  created_at      timestamptz not null default now()
);
create index if not exists idx_messages_conversation on public.messages(conversation_id);

-- bump conversation.updated_at when a new message arrives
create or replace function public.touch_conversation()
returns trigger language plpgsql as $$
begin
  update public.conversations set updated_at = now() where id = new.conversation_id;
  return new;
end $$;
drop trigger if exists trg_touch_conversation on public.messages;
create trigger trg_touch_conversation after insert on public.messages
  for each row execute function public.touch_conversation();

-- ============================================================
-- notifications
-- ============================================================
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles(id) on delete cascade,
  title      text not null,
  body       text,
  type       text,
  related_id text,
  read       boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notifications_user on public.notifications(user_id);

-- ============================================================
-- payment_methods  (display metadata only — NO raw card numbers)
-- ============================================================
create table if not exists public.payment_methods (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  type        text not null,             -- 'card' | 'applePay' | ...
  last4       text,
  brand       text,
  exp_month   integer,
  exp_year    integer,
  is_default  boolean not null default false,
  created_at  timestamptz not null default now()
);
create index if not exists idx_payment_methods_user on public.payment_methods(user_id);

-- ============================================================
-- reports  (anti-fraud / abuse reporting)
-- ============================================================
create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type text not null,             -- 'listing' | 'restaurant' | 'order' | 'user'
  target_id   text not null,
  reason      text,
  created_at  timestamptz not null default now()
);

-- ============================================================
-- Row Level Security
-- ============================================================
alter table public.profiles        enable row level security;
alter table public.restaurants     enable row level security;
alter table public.listings        enable row level security;
alter table public.orders          enable row level security;
alter table public.conversations   enable row level security;
alter table public.messages        enable row level security;
alter table public.notifications   enable row level security;
alter table public.payment_methods enable row level security;
alter table public.reports         enable row level security;

-- profiles: anyone authenticated can read basic profiles; you can only edit your own
drop policy if exists profiles_read on public.profiles;
create policy profiles_read on public.profiles
  for select to authenticated using (true);
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (id = auth.uid());

-- restaurants: public read; only the owner can write
drop policy if exists restaurants_read on public.restaurants;
create policy restaurants_read on public.restaurants
  for select to authenticated using (true);
drop policy if exists restaurants_write_owner on public.restaurants;
create policy restaurants_write_owner on public.restaurants
  for all to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());

-- listings: public read; only the owning restaurant can write
drop policy if exists listings_read on public.listings;
create policy listings_read on public.listings
  for select to authenticated using (true);
drop policy if exists listings_write_owner on public.listings;
create policy listings_write_owner on public.listings
  for all to authenticated
  using (exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid()))
  with check (exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid()));

-- orders: customer sees own; restaurant owner sees their restaurant's orders
drop policy if exists orders_read on public.orders;
create policy orders_read on public.orders
  for select to authenticated using (
    customer_id = auth.uid()
    or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  );
drop policy if exists orders_insert_customer on public.orders;
create policy orders_insert_customer on public.orders
  for insert to authenticated with check (customer_id = auth.uid());
drop policy if exists orders_update_party on public.orders;
create policy orders_update_party on public.orders
  for update to authenticated using (
    customer_id = auth.uid()
    or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  );

-- conversations: only the two parties
drop policy if exists conversations_party on public.conversations;
create policy conversations_party on public.conversations
  for all to authenticated using (
    customer_id = auth.uid()
    or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  ) with check (
    customer_id = auth.uid()
    or exists (select 1 from public.restaurants r where r.id = restaurant_id and r.owner_id = auth.uid())
  );

-- messages: only participants of the parent conversation
drop policy if exists messages_party on public.messages;
create policy messages_party on public.messages
  for all to authenticated using (
    exists (
      select 1 from public.conversations c
      where c.id = conversation_id
        and (c.customer_id = auth.uid()
             or exists (select 1 from public.restaurants r where r.id = c.restaurant_id and r.owner_id = auth.uid()))
    )
  ) with check (sender_id = auth.uid());

-- notifications / payment_methods: owner only
drop policy if exists notifications_own on public.notifications;
create policy notifications_own on public.notifications
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists payment_methods_own on public.payment_methods;
create policy payment_methods_own on public.payment_methods
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- reports: anyone authenticated can file; you can read your own
drop policy if exists reports_insert on public.reports;
create policy reports_insert on public.reports
  for insert to authenticated with check (reporter_id = auth.uid());
drop policy if exists reports_read_own on public.reports;
create policy reports_read_own on public.reports
  for select to authenticated using (reporter_id = auth.uid());

-- ============================================================
-- Storage buckets (public read, authenticated upload to own folder)
-- ============================================================
insert into storage.buckets (id, name, public) values ('avatars','avatars',true)            on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('restaurant-images','restaurant-images',true) on conflict (id) do nothing;
insert into storage.buckets (id, name, public) values ('listing-images','listing-images',true) on conflict (id) do nothing;

-- Allow public read of these buckets
drop policy if exists storage_public_read on storage.objects;
create policy storage_public_read on storage.objects
  for select to public
  using (bucket_id in ('avatars','restaurant-images','listing-images'));

-- Allow authenticated users to upload/update/delete within a folder named after their uid
-- e.g. path "avatars/<uid>/photo.jpg"
drop policy if exists storage_write_own on storage.objects;
create policy storage_write_own on storage.objects
  for all to authenticated
  using (
    bucket_id in ('avatars','restaurant-images','listing-images')
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id in ('avatars','restaurant-images','listing-images')
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ============================================================
-- Realtime (so Messages / Orders update live)
-- ============================================================
do $$ begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.orders;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.conversations;
exception when duplicate_object then null; end $$;

-- Done. Next: see SUPABASE_SETUP.md for the iOS app wiring.
