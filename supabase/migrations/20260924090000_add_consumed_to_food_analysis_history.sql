alter table public.food_analysis_history
  add column if not exists is_consumed boolean not null default false;

create index if not exists food_analysis_history_user_consumed_created_idx
  on public.food_analysis_history (user_id, is_consumed, created_at desc);
