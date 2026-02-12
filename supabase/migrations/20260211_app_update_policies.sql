create table if not exists public.app_update_policies (
  platform text primary key,
  min_required_version text not null,
  force_update_url text not null,
  is_enabled boolean not null default false,
  updated_at timestamptz not null default now(),
  constraint app_update_policies_platform_check check (
    platform in ('android', 'ios', 'web')
  )
);

alter table public.app_update_policies enable row level security;

drop policy if exists "app_update_policies_select_all" on public.app_update_policies;
create policy "app_update_policies_select_all"
on public.app_update_policies
for select
to anon, authenticated
using (true);

insert into public.app_update_policies (
  platform,
  min_required_version,
  force_update_url,
  is_enabled
)
values
  ('android', '0.0.0', '', false),
  ('ios', '0.0.0', '', false),
  ('web', '0.0.0', '', false)
on conflict (platform) do nothing;
