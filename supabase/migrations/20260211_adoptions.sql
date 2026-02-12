create table if not exists public.adoptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  pet_type text not null,
  pet_name text not null,
  breed text not null,
  age text not null,
  vaccinated text not null,
  about_pet text not null,
  city text not null,
  nearby_area text not null,
  photo_urls text[] not null default '{}',
  status text not null default 'under_review',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint adoptions_status_check check (
    status in ('under_review', 'approved', 'adopted', 'closed')
  )
);

alter table public.adoptions enable row level security;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists adoptions_set_updated_at on public.adoptions;
create trigger adoptions_set_updated_at
before update on public.adoptions
for each row
execute function public.set_updated_at();

drop policy if exists "adoptions_insert_own" on public.adoptions;
create policy "adoptions_insert_own"
on public.adoptions
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "adoptions_select_own" on public.adoptions;
create policy "adoptions_select_own"
on public.adoptions
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "adoptions_update_own" on public.adoptions;
create policy "adoptions_update_own"
on public.adoptions
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

