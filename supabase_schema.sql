create extension if not exists "uuid-ossp";

create table if not exists public.errors (
 id uuid primary key default uuid_generate_v4(),
 user_id uuid not null references auth.users(id) on delete cascade,
 discipline text not null, subject text not null, subtopic text, source text, question_number text,
 date date default current_date, difficulty text, statement text not null, user_answer text,
 correct_answer text, explanation text, key_concept text, error_reason text[] default '{}',
 content_gap text, status text default 'not_reviewed', priority text default 'medium',
 created_at timestamptz default now(), updated_at timestamptz default now(),
 reviewed_at timestamptz, review_count integer default 0
);

create table if not exists public.reviews (
 id uuid primary key default uuid_generate_v4(),
 error_id uuid not null references public.errors(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 review_date timestamptz default now(), result text, notes text
);

create table if not exists public.content_gaps (
 id uuid primary key default uuid_generate_v4(),
 user_id uuid not null references auth.users(id) on delete cascade,
 title text not null, description text, discipline text,
 status text default 'open', priority text default 'medium',
 created_at timestamptz default now(), updated_at timestamptz default now()
);

alter table public.errors enable row level security;
alter table public.reviews enable row level security;
alter table public.content_gaps enable row level security;

drop policy if exists errors_select on public.errors;
drop policy if exists errors_insert on public.errors;
drop policy if exists errors_update on public.errors;
drop policy if exists errors_delete on public.errors;
create policy errors_select on public.errors for select using (auth.uid()=user_id);
create policy errors_insert on public.errors for insert with check (auth.uid()=user_id);
create policy errors_update on public.errors for update using (auth.uid()=user_id);
create policy errors_delete on public.errors for delete using (auth.uid()=user_id);

drop policy if exists reviews_select on public.reviews;
drop policy if exists reviews_insert on public.reviews;
create policy reviews_select on public.reviews for select using (auth.uid()=user_id);
create policy reviews_insert on public.reviews for insert with check (auth.uid()=user_id);

drop policy if exists gaps_select on public.content_gaps;
drop policy if exists gaps_insert on public.content_gaps;
drop policy if exists gaps_update on public.content_gaps;
drop policy if exists gaps_delete on public.content_gaps;
create policy gaps_select on public.content_gaps for select using (auth.uid()=user_id);
create policy gaps_insert on public.content_gaps for insert with check (auth.uid()=user_id);
create policy gaps_update on public.content_gaps for update using (auth.uid()=user_id);
create policy gaps_delete on public.content_gaps for delete using (auth.uid()=user_id);

create index if not exists errors_user_created_idx on public.errors(user_id,created_at desc);
create index if not exists errors_user_subject_idx on public.errors(user_id,subject);
create index if not exists gaps_user_idx on public.content_gaps(user_id);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at=now(); return new; end $$;

drop trigger if exists errors_updated_at on public.errors;
create trigger errors_updated_at before update on public.errors for each row execute function public.set_updated_at();
drop trigger if exists gaps_updated_at on public.content_gaps;
create trigger gaps_updated_at before update on public.content_gaps for each row execute function public.set_updated_at();
