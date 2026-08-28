# QA/Inventory Board — setup

A shared task and sign-off board. Static HTML page hosted on GitHub Pages, data in Supabase.
Team members open one URL in any browser and all see the same board.

Files:

- `index.html` — the app. **This is the only file that gets deployed.**
- `schema.sql` — run once in Supabase to create the tables
- `preview.html` — a demo copy with fake data, for looking at the board without a database.
  Do not deploy this one; it saves nothing to Supabase.

---

## Step 1 — Create the Supabase project

1. Sign up at [supabase.com](https://supabase.com) and click **New project**.
2. Name it whatever you like. Pick the region closest to you (`us-east-1` or `us-central`).
3. Save the database password it generates somewhere safe. You won't need it for this app, but you'll want it later.
4. Wait about two minutes for the project to finish provisioning.

## Step 2 — Create the tables

1. In the left sidebar, open **SQL Editor** → **New query**.
2. Paste the entire contents of `schema.sql` and click **Run**.
3. You should see "Success. No rows returned." Check **Table Editor** — you'll now have `people` and `tasks`.

## Step 3 — Get your two connection values

1. Left sidebar → **Project Settings** → **API**.
2. Copy the **Project URL**. Looks like `https://abcdefghijkl.supabase.co`.
3. Copy the **anon public** key. It's a long string starting with `eyJ`.

Take the **anon public** key, not the service role key. The service role key bypasses all
access rules and must never go in a web page.

## Step 4 — Put your values in the file

Open `index.html` in any text editor. Near the top of the script block, about 600 lines
down, you'll find:

```js
const SUPABASE_URL      = 'PASTE_YOUR_PROJECT_URL_HERE';
const SUPABASE_ANON_KEY = 'PASTE_YOUR_ANON_PUBLIC_KEY_HERE';

const MEMBER_PASSWORD     = '1234';
const SUPERVISOR_PASSWORD = 'manager';
```

Paste your two values between the quotes. Change the passwords here too if you ever want to.
Save the file.

If you skip this step the page shows a "Setup needed" screen instead of the board, so you'll
know right away.

## Step 5 — Put it on GitHub

1. On [github.com](https://github.com), click **+** → **New repository**. Name it `qa-board`.
   Private is fine.
2. On the empty repo page, click **uploading an existing file**.
3. Drag in `index.html`. Commit.
4. Go to **Settings** → **Pages**.
5. Under *Build and deployment*, set **Source** to `Deploy from a branch`, branch `main`,
   folder `/ (root)`. Click **Save**.
6. Wait a minute, then refresh. Your URL appears at the top: `https://<you>.github.io/qa-board/`

Send that link to the team. That's the whole deployment.

To make changes later: edit `index.html` in the GitHub web editor, commit, and the live site
updates within a minute.

## Step 6 — First login

Open the URL. Nobody exists yet, so add yourself:

- Name: your name
- Role: **Supervisor**
- Password: `manager`

Then add your team members from the board, or have them add themselves with password `1234`.

---

## How the passwords work

| Who | Password |
|---|---|
| Team member | `1234` |
| Supervisor | `manager` |

Everyone shares these — there are no individual accounts. Whoever you pick from the dropdown
is who the board thinks you are. Your choice is remembered on that browser, so people only
sign in once per computer.

## How projects get sorted into tabs

The supervisor board has four tabs, and the **Dept** field on a task decides where its project
lands:

| Dept | Tab |
|---|---|
| `Dev` | Dev Projects |
| `Build Shop` | Build Shop Projects |
| anything else, or blank | QA Projects |

All Projects shows everything.

The match ignores case, spaces and punctuation, so `Dev`, `dev`, `Build Shop`, `build-shop` and
`buildshop` all route correctly. The Dept box suggests `Dev`, `Build Shop` and `QA` as you type,
plus any other department already in use.

Routing is per project, not per task: if any task in a project is tagged `Dev`, the whole project
moves to the Dev tab with all its tasks. That keeps a project from splitting across two tabs. If
a project somehow has both a `Dev` task and a `Build Shop` task, Dev wins.

Each tab has its own Excel export on the Completed view, so you can hand Build Shop their own
sign-off log without QA's work mixed in.

## Concurrent use

Each task is its own database row, and every action writes only that row. Two people working
at the same time won't overwrite each other's work. The board re-reads from the database every
5 seconds, so changes show up on everyone's screen within a few seconds without refreshing.
Typing is protected — a refresh won't wipe a form you're filling in.

The one case still to avoid: two people editing *the same task* at the same moment. Last save
wins there.

## Things worth knowing

**Anyone with the URL can use the board.** The anon key is inside the page, which is normal for
this kind of setup, but it means there's no real access control — the passwords just pick a
role, they don't protect the data. Fine for an internal punch list. Not fine for anything
confidential.

**Free Supabase projects pause after 7 days with no activity.** A board used on weekdays never
hits this. After a long shutdown, someone clicks Restore in the Supabase dashboard and the data
comes back exactly as it was. Nothing is lost.

**Free tier limits** are 500 MB of database and unlimited API requests. This board will use a
fraction of a percent of that.

**If the database is unreachable**, a red bar appears across the top of the page with the error.
It will not silently lose your work.

## Backups

Free Supabase keeps no backups. If the data matters, use the Excel export on the Completed view
periodically, or in **Table Editor** open the `tasks` table and use **Export → CSV**.
