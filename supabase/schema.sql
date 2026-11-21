-- Gos Radars : schéma Supabase (signalements communautaires)
-- À coller dans Supabase > SQL Editor, puis exécuter une fois.
-- Prérequis : Authentication > Providers > Anonymous sign-ins = activé.

-- ---------- Signalements ----------
create table if not exists public.reports (
  id          uuid primary key default gen_random_uuid(),
  kind        text not null check (kind in ('radar_mobile','controle','accident','bouchon','danger')),
  lat         double precision not null check (lat between -90 and 90),
  lon         double precision not null check (lon between -180 and 180),
  user_id     uuid not null default auth.uid(),
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '45 minutes',
  confirmations int not null default 0,
  denials       int not null default 0
);

create index if not exists reports_geo_idx on public.reports (lat, lon);
create index if not exists reports_expires_idx on public.reports (expires_at);

-- ---------- Votes (« toujours là ? ») ----------
create table if not exists public.report_votes (
  report_id uuid not null references public.reports(id) on delete cascade,
  user_id   uuid not null default auth.uid(),
  still_there boolean not null,
  created_at timestamptz not null default now(),
  primary key (report_id, user_id)
);

-- ---------- Limitation anti-spam : 5 signalements maximum par 10 minutes ----------
create or replace function public.limit_reports() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if (select count(*) from public.reports
        where user_id = new.user_id and created_at > now() - interval '10 minutes') >= 5 then
    raise exception 'Trop de signalements récents, réessayez plus tard';
  end if;
  return new;
end $$;

drop trigger if exists reports_rate_limit on public.reports;
create trigger reports_rate_limit before insert on public.reports
  for each row execute function public.limit_reports();

-- ---------- Votes : mise à jour des compteurs et retrait si plusieurs « plus là » ----------
create or replace function public.apply_vote() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  c int; d int;
begin
  select count(*) filter (where still_there), count(*) filter (where not still_there)
    into c, d from public.report_votes where report_id = new.report_id;

  -- Une seule affectation d'expires_at (dans un UPDATE, les affectations ne se cumulent pas)
  update public.reports
     set confirmations = c,
         denials = d,
         expires_at = case
           -- Retiré immédiatement : au moins 3 « plus là » et plus que de « toujours là »
           when d >= 3 and d > c then least(expires_at, now())
           -- Confirmé : prolongé de 20 minutes, plafonné à 90 minutes après la création
           when new.still_there and c > d
             then greatest(expires_at, least(now() + interval '20 minutes', created_at + interval '90 minutes'))
           else expires_at
         end
   where id = new.report_id;
  return new;
end $$;

drop trigger if exists report_votes_apply on public.report_votes;
create trigger report_votes_apply after insert or update on public.report_votes
  for each row execute function public.apply_vote();

-- ---------- Sécurité : Row Level Security ----------
alter table public.reports enable row level security;
alter table public.report_votes enable row level security;

drop policy if exists "lire les signalements actifs" on public.reports;
create policy "lire les signalements actifs" on public.reports
  for select using (expires_at > now());

drop policy if exists "signaler en son nom" on public.reports;
create policy "signaler en son nom" on public.reports
  for insert with check (auth.uid() = user_id);

drop policy if exists "lire les votes" on public.report_votes;
create policy "lire les votes" on public.report_votes
  for select using (true);

drop policy if exists "voter en son nom" on public.report_votes;
create policy "voter en son nom" on public.report_votes
  for insert with check (auth.uid() = user_id);

drop policy if exists "changer son vote" on public.report_votes;
create policy "changer son vote" on public.report_votes
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------- Temps réel ----------
alter publication supabase_realtime add table public.reports;
