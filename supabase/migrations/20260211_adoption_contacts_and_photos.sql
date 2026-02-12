alter table public.adoptions
  add column if not exists contact_name text not null default '',
  add column if not exists contact_phone text not null default '',
  add column if not exists contact_email text not null default '';

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'adoption-photos',
  'adoption-photos',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "adoption_photos_insert_own" on storage.objects;
create policy "adoption_photos_insert_own"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'adoption-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "adoption_photos_update_own" on storage.objects;
create policy "adoption_photos_update_own"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'adoption-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'adoption-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "adoption_photos_delete_own" on storage.objects;
create policy "adoption_photos_delete_own"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'adoption-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "adoption_photos_select_public" on storage.objects;
create policy "adoption_photos_select_public"
on storage.objects
for select
to public
using (bucket_id = 'adoption-photos');
