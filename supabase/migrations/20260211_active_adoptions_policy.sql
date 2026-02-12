drop policy if exists "adoptions_select_active_approved" on public.adoptions;
create policy "adoptions_select_active_approved"
on public.adoptions
for select
to authenticated
using (status = 'approved');
