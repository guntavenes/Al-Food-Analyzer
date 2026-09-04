alter table public.user_entitlements
  add column if not exists premium_source text,
  add column if not exists premium_transaction_id text;

create unique index if not exists user_entitlements_premium_transaction_id_idx
  on public.user_entitlements (premium_transaction_id)
  where premium_transaction_id is not null;

revoke all on table public.user_entitlements from anon, authenticated;
grant select, insert, update on table public.user_entitlements to service_role;
