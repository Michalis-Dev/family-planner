-- Family Planner: Run in a NEW Supabase project, SQL Editor
-- Private data is protected by PostgreSQL Row Level Security.
create extension if not exists pgcrypto;

create table if not exists public.families (
 id uuid primary key default gen_random_uuid(),
 name text not null check (length(trim(name)) between 1 and 80),
 invite_code text not null unique default replace(gen_random_uuid()::text, '-', ''),
 created_by uuid not null references auth.users(id),
 created_at timestamptz not null default now()
);
create table if not exists public.family_members (
 family_id uuid not null references public.families(id) on delete cascade,
 user_id uuid not null unique references auth.users(id) on delete cascade,
 display_name text not null default 'Μέλος',
 primary key(family_id,user_id)
);
create table if not exists public.children (
 id uuid primary key default gen_random_uuid(),
 family_id uuid not null references public.families(id) on delete cascade,
 name text not null check (length(trim(name)) between 1 and 80),
 color text not null default '#38a2a0'
);
create table if not exists public.activities (
 id uuid primary key default gen_random_uuid(),
 family_id uuid not null references public.families(id) on delete cascade,
 child_id uuid references public.children(id) on delete set null,
 title text not null check (length(trim(title)) between 1 and 160),
 activity_date date not null,
 start_time time,
 category text not null default 'other',
 location text not null default '',
 notes text not null default '',
 is_done boolean not null default false,
 created_by uuid not null default auth.uid() references auth.users(id),
 created_at timestamptz not null default now(),
 constraint valid_category check (category in ('school','sports','lesson','health','other'))
);
create index if not exists ix_activities_date on public.activities(family_id, activity_date);
create index if not exists ix_members_family on public.family_members(family_id);

create or replace function public.is_family_member(fid uuid)
returns boolean language sql stable security definer set search_path = ''
as $$ select auth.uid() is not null and exists (
 select 1 from public.family_members m where m.family_id=fid and m.user_id=auth.uid()
) $$;

create or replace function public.create_family(p_name text, p_display_name text default 'Μέλος')
returns uuid language plpgsql security definer set search_path = ''
as $$
declare fid uuid;
begin
 if auth.uid() is null then raise exception 'Login required'; end if;
 if exists(select 1 from public.family_members where user_id=auth.uid()) then raise exception 'Already in a family'; end if;
 if length(trim(coalesce(p_name,''))) not between 1 and 80 then raise exception 'Invalid family name'; end if;
 insert into public.families(name,created_by) values(trim(p_name),auth.uid()) returning id into fid;
 insert into public.family_members(family_id,user_id,display_name)
 values(fid,auth.uid(),left(coalesce(nullif(trim(p_display_name),''),'Μέλος'),80));
 return fid;
end $$;

create or replace function public.join_family(p_invite_code text, p_display_name text default 'Μέλος')
returns uuid language plpgsql security definer set search_path = ''
as $$
declare fid uuid;
begin
 if auth.uid() is null then raise exception 'Login required'; end if;
 if exists(select 1 from public.family_members where user_id=auth.uid()) then raise exception 'Already in a family'; end if;
 select id into fid from public.families where invite_code=lower(trim(coalesce(p_invite_code,'')));
 if fid is null then raise exception 'Invalid invitation code'; end if;
 insert into public.family_members(family_id,user_id,display_name)
 values(fid,auth.uid(),left(coalesce(nullif(trim(p_display_name),''),'Μέλος'),80));
 return fid;
end $$;

alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.children enable row level security;
alter table public.activities enable row level security;

create policy "family read for members" on public.families for select to authenticated
 using (public.is_family_member(id));
create policy "member self read" on public.family_members for select to authenticated
 using (user_id = (select auth.uid()));
create policy "children read" on public.children for select to authenticated
 using (public.is_family_member(family_id));
create policy "children create" on public.children for insert to authenticated
 with check (public.is_family_member(family_id));
create policy "children edit" on public.children for update to authenticated
 using (public.is_family_member(family_id)) with check (public.is_family_member(family_id));
create policy "children delete" on public.children for delete to authenticated
 using (public.is_family_member(family_id));
create policy "activities read" on public.activities for select to authenticated
 using (public.is_family_member(family_id));
create policy "activities create" on public.activities for insert to authenticated
 with check (public.is_family_member(family_id)
 and created_by=(select auth.uid())
 and (child_id is null or exists(select 1 from public.children c where c.id=child_id and c.family_id=activities.family_id)));
create policy "activities edit" on public.activities for update to authenticated
 using (public.is_family_member(family_id))
 with check (public.is_family_member(family_id)
 and (child_id is null or exists(select 1 from public.children c where c.id=child_id and c.family_id=activities.family_id)));
create policy "activities delete" on public.activities for delete to authenticated
 using (public.is_family_member(family_id));

revoke all on public.families, public.family_members, public.children, public.activities from anon;
revoke all on public.families, public.family_members, public.children, public.activities from authenticated;
grant select on public.families, public.family_members to authenticated;
grant select,insert,update,delete on public.children, public.activities to authenticated;
revoke all on function public.is_family_member(uuid) from public,anon;
revoke all on function public.create_family(text,text) from public,anon;
revoke all on function public.join_family(text,text) from public,anon;
grant execute on function public.is_family_member(uuid) to authenticated;
grant execute on function public.create_family(text,text) to authenticated;
grant execute on function public.join_family(text,text) to authenticated;
