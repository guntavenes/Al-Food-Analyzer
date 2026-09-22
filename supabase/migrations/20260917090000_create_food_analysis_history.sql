create table if not exists public.food_analysis_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_path text not null,
  analysis_data jsonb not null,
  is_favorite boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists food_analysis_history_user_created_idx
  on public.food_analysis_history (user_id, created_at desc);

alter table public.food_analysis_history enable row level security;
grant select, insert, update, delete on public.food_analysis_history to authenticated;

create policy "Users can read their history"
  on public.food_analysis_history for select to authenticated
  using (auth.uid() = user_id);
create policy "Users can insert their history"
  on public.food_analysis_history for insert to authenticated
  with check (auth.uid() = user_id);
create policy "Users can update their history"
  on public.food_analysis_history for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete their history"
  on public.food_analysis_history for delete to authenticated
  using (auth.uid() = user_id);

insert into storage.buckets (id, name, public)
values ('analysis-images', 'analysis-images', false)
on conflict (id) do nothing;

create policy "Users can read their analysis images"
  on storage.objects for select to authenticated
  using (bucket_id = 'analysis-images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Users can upload their analysis images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'analysis-images' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "Users can delete their analysis images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'analysis-images' and (storage.foldername(name))[1] = auth.uid()::text);
