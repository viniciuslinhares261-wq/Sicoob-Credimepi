-- Gestão de Mídias · Sicoob Credimepi
-- Rode este arquivo inteiro em Supabase → SQL Editor → New query → Run.

-- 1) Tabela única com todos os cadastros (campanhas, outdoors, radios, posts e config)
create table if not exists public.registros (
  colecao       text not null,
  id            text not null,
  dados         jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now(),
  primary key (colecao, id)
);

-- Envia o registro completo também nas exclusões (usado pela atualização em tempo real)
alter table public.registros replica identity full;

-- 2) Segurança: só usuários logados leem e escrevem
alter table public.registros enable row level security;

drop policy if exists "equipe le" on public.registros;
create policy "equipe le" on public.registros
  for select to authenticated using (true);

drop policy if exists "equipe grava" on public.registros;
create policy "equipe grava" on public.registros
  for insert to authenticated with check (true);

drop policy if exists "equipe altera" on public.registros;
create policy "equipe altera" on public.registros
  for update to authenticated using (true) with check (true);

drop policy if exists "equipe exclui" on public.registros;
create policy "equipe exclui" on public.registros
  for delete to authenticated using (true);

-- 3) Tempo real: todos veem as alterações na hora
do $$
begin
  alter publication supabase_realtime add table public.registros;
exception when duplicate_object then null;
end $$;

-- 4) Arquivos (artes, áudios, contratos): bucket privado "midias"
insert into storage.buckets (id, name, public, file_size_limit)
values ('midias', 'midias', false, 52428800)
on conflict (id) do nothing;

drop policy if exists "equipe le arquivos" on storage.objects;
create policy "equipe le arquivos" on storage.objects
  for select to authenticated using (bucket_id = 'midias');

drop policy if exists "equipe envia arquivos" on storage.objects;
create policy "equipe envia arquivos" on storage.objects
  for insert to authenticated with check (bucket_id = 'midias');

drop policy if exists "equipe altera arquivos" on storage.objects;
create policy "equipe altera arquivos" on storage.objects
  for update to authenticated using (bucket_id = 'midias');

drop policy if exists "equipe exclui arquivos" on storage.objects;
create policy "equipe exclui arquivos" on storage.objects
  for delete to authenticated using (bucket_id = 'midias');
