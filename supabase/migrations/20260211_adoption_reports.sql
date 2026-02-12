create table if not exists public.adoption_reports (
  id uuid primary key default gen_random_uuid(),
  adoption_id uuid not null references public.adoptions (id) on delete cascade,
  reporter_user_id uuid not null references auth.users (id) on delete cascade,
  reason text not null,
  details text not null default '',
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint adoption_reports_reason_non_empty check (char_length(trim(reason)) > 0),
  constraint adoption_reports_status_check check (
    status in ('open', 'reviewed', 'dismissed', 'resolved')
  )
);

create index if not exists adoption_reports_adoption_id_idx
  on public.adoption_reports (adoption_id, created_at desc);

create index if not exists adoption_reports_reporter_user_id_idx
  on public.adoption_reports (reporter_user_id, created_at desc);

alter table public.adoption_reports enable row level security;

drop trigger if exists adoption_reports_set_updated_at on public.adoption_reports;
create trigger adoption_reports_set_updated_at
before update on public.adoption_reports
for each row
execute function public.set_updated_at();

drop policy if exists "adoption_reports_insert_own" on public.adoption_reports;
create policy "adoption_reports_insert_own"
on public.adoption_reports
for insert
to authenticated
with check (auth.uid() = reporter_user_id);

drop policy if exists "adoption_reports_select_own_or_admin" on public.adoption_reports;
create policy "adoption_reports_select_own_or_admin"
on public.adoption_reports
for select
to authenticated
using (
  auth.uid() = reporter_user_id
  or (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
);

drop policy if exists "adoption_reports_update_admin_only" on public.adoption_reports;
create policy "adoption_reports_update_admin_only"
on public.adoption_reports
for update
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');
