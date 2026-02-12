insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'adoption-photos',
  'adoption-photos',
  true,
  15728640,
  array[
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif'
  ]
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "adoption_photos_insert_own" on storage.objects;
drop policy if exists "adoption_photos_update_own" on storage.objects;
drop policy if exists "adoption_photos_delete_own" on storage.objects;
drop policy if exists "adoption_photos_select_public" on storage.objects;

drop policy if exists "adoption_photos_insert_authenticated" on storage.objects;
create policy "adoption_photos_insert_authenticated"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'adoption-photos'
  and auth.role() = 'authenticated'
);

drop policy if exists "adoption_photos_update_authenticated" on storage.objects;
create policy "adoption_photos_update_authenticated"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'adoption-photos'
  and auth.role() = 'authenticated'
)
with check (
  bucket_id = 'adoption-photos'
  and auth.role() = 'authenticated'
);

drop policy if exists "adoption_photos_delete_authenticated" on storage.objects;
create policy "adoption_photos_delete_authenticated"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'adoption-photos'
  and auth.role() = 'authenticated'
);

drop policy if exists "adoption_photos_select_all" on storage.objects;
create policy "adoption_photos_select_all"
on storage.objects
for select
to public
using (bucket_id = 'adoption-photos');
