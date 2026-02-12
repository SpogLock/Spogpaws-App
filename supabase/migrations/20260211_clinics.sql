create table if not exists public.clinics (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null,
  area text not null default '',
  address_line text not null,
  contact_phone text not null default '',
  emergency_phone text not null default '',
  opening_time text not null default '09:00',
  closing_time text not null default '20:00',
  services text[] not null default '{}',
  about text not null default '',
  is_24_hours boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint clinics_name_city_address_unique unique (name, city, address_line)
);

alter table public.clinics enable row level security;

drop trigger if exists clinics_set_updated_at on public.clinics;
create trigger clinics_set_updated_at
before update on public.clinics
for each row
execute function public.set_updated_at();

drop policy if exists "clinics_select_active_authenticated" on public.clinics;
create policy "clinics_select_active_authenticated"
on public.clinics
for select
to authenticated
using (is_active = true);

drop policy if exists "clinics_insert_admin_only" on public.clinics;
create policy "clinics_insert_admin_only"
on public.clinics
for insert
to authenticated
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "clinics_update_admin_only" on public.clinics;
create policy "clinics_update_admin_only"
on public.clinics
for update
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

drop policy if exists "clinics_delete_admin_only" on public.clinics;
create policy "clinics_delete_admin_only"
on public.clinics
for delete
to authenticated
using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

insert into public.clinics (
  name,
  city,
  area,
  address_line,
  contact_phone,
  emergency_phone,
  opening_time,
  closing_time,
  services,
  about,
  is_24_hours,
  is_active
)
values
  (
    'Paws and Claws Veterinary Center',
    'New York',
    'Manhattan',
    '245 Lexington Ave',
    '+1 212 555 0123',
    '+1 212 555 0199',
    '08:00',
    '22:00',
    array['General Checkup', 'Vaccination', 'Surgery', 'Dental Care'],
    'Full-service veterinary clinic with in-house diagnostics and pet wellness plans.',
    false,
    true
  ),
  (
    'CityPet Emergency Hospital',
    'Chicago',
    'Downtown',
    '118 W Jackson Blvd',
    '+1 312 555 0108',
    '+1 312 555 0109',
    '00:00',
    '23:59',
    array['Emergency Care', 'Trauma', 'ICU Monitoring'],
    '24/7 emergency hospital focused on urgent and critical pet care.',
    true,
    true
  ),
  (
    'Happy Tails Animal Clinic',
    'Houston',
    'Midtown',
    '501 Gray St',
    '+1 713 555 0167',
    '+1 713 555 0170',
    '09:00',
    '20:00',
    array['General Checkup', 'Vaccination', 'Microchipping'],
    'Neighborhood-friendly clinic for routine care and preventive treatment.',
    false,
    true
  ),
  (
    'Sunset Vet Care',
    'Los Angeles',
    'Silver Lake',
    '920 Sunset Blvd',
    '+1 323 555 0142',
    '',
    '10:00',
    '19:00',
    array['Dermatology', 'Dental Care', 'Nutrition Consult'],
    'Specialized preventive care and chronic condition management for dogs and cats.',
    false,
    true
  ),
  (
    'Bayview Pet Hospital',
    'San Diego',
    'Mission Valley',
    '777 Camino Del Rio S',
    '+1 619 555 0185',
    '+1 619 555 0188',
    '08:30',
    '21:00',
    array['Imaging', 'Surgery', 'General Checkup', 'Vaccination'],
    'Comprehensive pet hospital with modern imaging and experienced surgical staff.',
    false,
    true
  )
on conflict (name, city, address_line) do update set
  area = excluded.area,
  contact_phone = excluded.contact_phone,
  emergency_phone = excluded.emergency_phone,
  opening_time = excluded.opening_time,
  closing_time = excluded.closing_time,
  services = excluded.services,
  about = excluded.about,
  is_24_hours = excluded.is_24_hours,
  is_active = excluded.is_active,
  updated_at = now();
