create table if not exists public.tips_of_the_day (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  category text not null default 'care',
  cta_text text not null default '',
  cta_url text not null default '',
  published_on date not null default current_date,
  is_active boolean not null default true,
  created_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint tips_of_the_day_title_non_empty check (char_length(trim(title)) > 0),
  constraint tips_of_the_day_content_non_empty check (char_length(trim(content)) > 0),
  constraint tips_of_the_day_category_non_empty check (char_length(trim(category)) > 0)
);

create index if not exists tips_of_the_day_active_published_idx
  on public.tips_of_the_day (is_active, published_on desc, created_at desc);

alter table public.tips_of_the_day enable row level security;

drop trigger if exists tips_of_the_day_set_updated_at on public.tips_of_the_day;  
create trigger tips_of_the_day_set_updated_at
before update on public.tips_of_the_day
for each row
execute function public.set_updated_at();

drop policy if exists "tips_of_the_day_select_active_authenticated" on public.tips_of_the_day;
create policy "tips_of_the_day_select_active_authenticated"
on public.tips_of_the_day
for select
to authenticated
using (is_active = true and published_on <= current_date);

drop policy if exists "tips_of_the_day_insert_admin_only" on public.tips_of_the_day;
create policy "tips_of_the_day_insert_admin_only"
on public.tips_of_the_day
for insert
to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "tips_of_the_day_update_admin_only" on public.tips_of_the_day;
create policy "tips_of_the_day_update_admin_only"
on public.tips_of_the_day
for update
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "tips_of_the_day_delete_admin_only" on public.tips_of_the_day;
create policy "tips_of_the_day_delete_admin_only"
on public.tips_of_the_day
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

insert into public.tips_of_the_day (
  title,
  content,
  category,
  cta_text,
  cta_url,
  published_on,
  is_active
)
values
  (
    'Hydration matters',
    'Keep fresh water available all day. Pets are more likely to drink when bowls are cleaned daily.',
    'wellness',
    'View nearby clinics',
    '/clinics',
    current_date - 2,
    true
  ),
  (
    'Short daily enrichment',
    'Use 10 minutes of guided play to reduce anxiety and improve sleep quality in dogs and cats.',
    'behavior',
    'See adoption pets',
    '/adoption',
    current_date - 1,
    true
  ),
  (
    'Monthly flea check',
    'A quick skin and coat inspection can detect flea activity early before irritation becomes severe.',
    'care',
    'Learn prevention basics',
    '',
    current_date,
    true
  );
