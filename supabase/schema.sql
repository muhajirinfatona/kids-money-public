create table if not exists public.children (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80), age_group text not null default '5-7', avatar text not null default '🙂', created_at timestamptz not null default now()
);
create table if not exists public.wallets (
  id uuid primary key default gen_random_uuid(), child_id uuid not null references public.children(id) on delete cascade,
  wallet_type text not null check (wallet_type in ('spend','save','share')), balance bigint not null default 0 check (balance >= 0), unique(child_id, wallet_type)
);
create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(), child_id uuid not null references public.children(id) on delete cascade,
  description text not null, amount bigint not null check (amount > 0), wallet text not null check (wallet in ('spend','save','share')),
  type text not null check (type in ('income','expense')), created_at timestamptz not null default now()
);
create table if not exists public.savings_goals (
  id uuid primary key default gen_random_uuid(), child_id uuid not null references public.children(id) on delete cascade,
  title text not null, current_amount bigint not null default 0 check (current_amount >= 0), target_amount bigint not null check (target_amount > 0), created_at timestamptz not null default now()
);
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(), child_id uuid not null references public.children(id) on delete cascade,
  title text not null, reward bigint not null check (reward > 0), status text not null default 'active' check (status in ('active','waitingApproval','completed')), created_at timestamptz not null default now()
);

alter table public.children enable row level security;
alter table public.wallets enable row level security;
alter table public.transactions enable row level security;
alter table public.savings_goals enable row level security;
alter table public.tasks enable row level security;

create policy "parents manage own children" on public.children for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "parents manage child wallets" on public.wallets for all using (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid())) with check (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid()));
create policy "parents manage child transactions" on public.transactions for all using (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid())) with check (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid()));
create policy "parents manage child goals" on public.savings_goals for all using (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid())) with check (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid()));
create policy "parents manage child tasks" on public.tasks for all using (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid())) with check (exists (select 1 from public.children c where c.id = child_id and c.user_id = auth.uid()));

create or replace function public.seed_child_wallets() returns trigger language plpgsql security definer set search_path = public as $$
begin insert into public.wallets(child_id, wallet_type) values (new.id,'spend'),(new.id,'save'),(new.id,'share'); return new; end; $$;
drop trigger if exists on_child_created on public.children;
create trigger on_child_created after insert on public.children for each row execute function public.seed_child_wallets();
