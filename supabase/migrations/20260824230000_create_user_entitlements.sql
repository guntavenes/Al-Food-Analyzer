alter table public.analysis_usage
  add column if not exists usage_kind text not null default 'free'
  check (usage_kind in ('free', 'premium'));

create table if not exists public.user_entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  free_analyses_used integer not null default 0 check (free_analyses_used between 0 and 1),
  premium_until timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.user_entitlements enable row level security;
revoke all on table public.user_entitlements from anon, authenticated;
grant select, insert, update on table public.user_entitlements to service_role;

create or replace function public.claim_analysis_entitlement(p_user_id uuid, p_request_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  entitlement public.user_entitlements%rowtype;
  existing_kind text;
begin
  select usage_kind into existing_kind from public.analysis_usage
  where request_id = p_request_id and user_id = p_user_id;
  if existing_kind is not null then return 'duplicate'; end if;

  insert into public.user_entitlements (user_id) values (p_user_id)
  on conflict (user_id) do nothing;
  select * into entitlement from public.user_entitlements
  where user_id = p_user_id for update;

  if entitlement.premium_until is not null and entitlement.premium_until > now() then
    insert into public.analysis_usage (user_id, request_id, usage_kind)
    values (p_user_id, p_request_id, 'premium');
    return 'premium';
  end if;

  if entitlement.free_analyses_used = 0 then
    update public.user_entitlements set free_analyses_used = 1, updated_at = now()
    where user_id = p_user_id;
    insert into public.analysis_usage (user_id, request_id, usage_kind)
    values (p_user_id, p_request_id, 'free');
    return 'free';
  end if;

  return 'premium_required';
end;
$$;

create or replace function public.release_analysis_entitlement(p_user_id uuid, p_request_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  released_kind text;
begin
  delete from public.analysis_usage
  where request_id = p_request_id and user_id = p_user_id
  returning usage_kind into released_kind;
  if released_kind = 'free' then
    update public.user_entitlements set free_analyses_used = 0, updated_at = now()
    where user_id = p_user_id;
  end if;
end;
$$;

revoke all on function public.claim_analysis_entitlement(uuid, uuid) from public, anon, authenticated;
revoke all on function public.release_analysis_entitlement(uuid, uuid) from public, anon, authenticated;
grant execute on function public.claim_analysis_entitlement(uuid, uuid) to service_role;
grant execute on function public.release_analysis_entitlement(uuid, uuid) to service_role;
notify pgrst, 'reload schema';
