-- ============================================================
-- QA/Inventory board - Supabase schema
-- Paste this whole file into the Supabase SQL Editor and Run.
-- Safe to re-run: it drops and recreates the tables.
-- ============================================================

drop table if exists tasks;
drop table if exists people;

-- ---------- people ----------
create table people (
  name       text primary key,
  role       text not null default 'member' check (role in ('member','boss')),
  created_at timestamptz not null default now()
);

-- ---------- tasks (one row per task) ----------
create table tasks (
  id           text primary key,
  title        text not null,
  project      text not null,
  dept         text,
  assignee     text not null,
  priority     text not null default 'green' check (priority in ('red','yellow','green')),
  due_date     date,
  status       text not null default 'open'  check (status in ('open','awaiting','validated')),
  created_at   timestamptz not null default now(),
  completed_at timestamptz,
  validated_at timestamptz
);

-- Indexes for the lookups the board does on every load.
create index tasks_project_idx  on tasks (project);
create index tasks_assignee_idx on tasks (assignee);
create index tasks_status_idx   on tasks (status);

-- ============================================================
-- Access
--
-- Supabase blocks everything by default, so without the policies
-- below the board will load but stay empty. These grant the
-- public "anon" key full read/write. That is deliberate for an
-- internal board with a shared password, but understand what it
-- means: anyone who has your page URL can read and change the
-- data. There is no per-user permission here.
-- ============================================================

alter table people enable row level security;
alter table tasks  enable row level security;

create policy "anon full access to people"
  on people for all to anon using (true) with check (true);

create policy "anon full access to tasks"
  on tasks for all to anon using (true) with check (true);

-- ---------- optional: a couple of rows to prove it works ----------
-- insert into people (name, role) values ('Your Name', 'boss');
-- insert into tasks (id, title, project, dept, assignee, priority, status)
--   values ('demo1', 'Recount bay 3 irons', 'Bay 3 Retag', 'Receiving', 'Your Name', 'red', 'open');
