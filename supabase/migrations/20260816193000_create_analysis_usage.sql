create table if not exists public.analysis_usage (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  request_id uuid not null unique,
  created_at timestamptz not null default now()
);

create index if not exists analysis_usage_user_created_at_idx
  on public.analysis_usage (user_id, created_at desc);

alter table public.analysis_usage enable row level security;

revoke all on table public.analysis_usage from anon, authenticated;
