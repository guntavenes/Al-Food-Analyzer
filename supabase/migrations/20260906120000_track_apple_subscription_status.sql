alter table public.user_entitlements
  add column if not exists apple_original_transaction_id text,
  add column if not exists apple_product_id text,
  add column if not exists subscription_status text not null default 'inactive'
    check (subscription_status in ('inactive', 'active', 'canceled', 'expired', 'revoked')),
  add column if not exists auto_renew_enabled boolean;

create unique index if not exists user_entitlements_apple_original_transaction_id_idx
  on public.user_entitlements (apple_original_transaction_id)
  where apple_original_transaction_id is not null;

revoke all on table public.user_entitlements from anon, authenticated;
grant select, insert, update on table public.user_entitlements to service_role;

notify pgrst, 'reload schema';
