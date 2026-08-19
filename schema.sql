-- ============================================================
-- DISPATCH — Supabase schema
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard -> SQL Editor -> New query -> paste all -> Run)
-- ============================================================

-- ---------- Tables ----------

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  name text not null,
  role text not null default 'user' check (role in ('admin','user')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  last_login timestamptz
);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  email text,
  address text,
  notes text,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customers(id) on delete cascade,
  title text not null,
  notes text,
  status text not null default 'new' check (status in ('new','progress','ready','delivered')),
  price numeric(10,2),
  due_date date,
  delivered_at date,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

-- ---------- Auto-create a profile whenever someone signs up ----------
-- The very first person to sign up becomes admin automatically.
-- Everyone after that becomes a regular "user" (an admin can promote them later).

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username, name, role, active)
  values (
    new.id,
    lower(coalesce(new.raw_user_meta_data->>'username', split_part(new.email,'@',1))),
    coalesce(new.raw_user_meta_data->>'name', new.email),
    case when (select count(*) from public.profiles) = 0 then 'admin' else 'user' end,
    true
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------- Username -> email lookup (needed so people can log in with a
-- username instead of an email; runs before the person is authenticated) ----------

create or replace function public.get_email_for_username(uname text)
returns text
language sql
security definer
set search_path = public
as $$
  select u.email::text
  from auth.users u
  join public.profiles p on p.id = u.id
  where lower(p.username) = lower(uname)
  limit 1;
$$;

grant execute on function public.get_email_for_username(text) to anon, authenticated;

-- ---------- Row Level Security ----------

alter table public.profiles enable row level security;
alter table public.customers enable row level security;
alter table public.jobs enable row level security;

-- Any signed-in person can see every profile (needed for "logged by" / team report)
drop policy if exists "profiles readable by authenticated" on public.profiles;
create policy "profiles readable by authenticated" on public.profiles
  for select using (auth.role() = 'authenticated');

-- Anyone can update their own row (e.g. changing their display name)
drop policy if exists "self update own profile" on public.profiles;
create policy "self update own profile" on public.profiles
  for update using (auth.uid() = id);

-- Admins can update anyone's role / active status / name / username
drop policy if exists "admin update any profile" on public.profiles;
create policy "admin update any profile" on public.profiles
  for update using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin' and p.active)
  );

-- Any active signed-in person can read/write customers & jobs
drop policy if exists "active users read customers" on public.customers;
create policy "active users read customers" on public.customers
  for select using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  );
drop policy if exists "active users write customers" on public.customers;
create policy "active users write customers" on public.customers
  for all using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  ) with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  );

drop policy if exists "active users read jobs" on public.jobs;
create policy "active users read jobs" on public.jobs
  for select using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  );
drop policy if exists "active users write jobs" on public.jobs;
create policy "active users write jobs" on public.jobs
  for all using (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  ) with check (
    exists (select 1 from public.profiles p where p.id = auth.uid() and p.active)
  );

-- ---------- Realtime ----------
-- Lets every signed-in device get instant updates when any other device
-- adds/edits/deletes a customer or job.
alter publication supabase_realtime add table public.customers;
alter publication supabase_realtime add table public.jobs;
alter publication supabase_realtime add table public.profiles;
