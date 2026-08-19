DISPATCH — Customer & Job Tracker (shared/cloud edition)
==========================================================

WHAT CHANGED
This version stores everything in a shared cloud database (Supabase)
instead of the browser's local storage. Every device — your Windows 11
PC and your Android phone — reads and writes the SAME customers, jobs,
and user accounts, and updates appear on other signed-in devices within
a second or two (no refresh needed).

WHAT YOU NEED
A free Supabase account and project. Supabase's free tier is more than
enough for a small team's job tracker. Setup takes about 10 minutes and
you only do it once.

------------------------------------------------------------
STEP 1 — Create the Supabase project
------------------------------------------------------------
1. Go to https://supabase.com and sign up (free).
2. Click "New project". Pick any name/region, set a database password
   (save it somewhere — you likely won't need it day-to-day, but keep it
   safe), and create the project. Wait ~1-2 minutes for it to spin up.

------------------------------------------------------------
STEP 2 — Run the schema
------------------------------------------------------------
1. In your project, open the SQL Editor (left sidebar).
2. Click "New query".
3. Open schema.sql (included alongside this README), copy everything,
   paste it into the SQL editor, and click "Run".
   This creates the customers/jobs/users tables, turns on the security
   rules that keep the data properly access-controlled, and sets up
   real-time sync.

------------------------------------------------------------
STEP 3 — (Recommended) turn off email confirmation
------------------------------------------------------------
By default, Supabase requires people to click a confirmation link in
their email before they can sign in for the first time. For an internal
team tool this is usually unnecessary friction:
  Dashboard -> Authentication -> Providers -> Email -> turn OFF
  "Confirm email".
Leave it ON if you'd rather have that extra verification step — the app
handles either way, it'll just tell people to check their inbox first.

------------------------------------------------------------
STEP 4 — Connect the app to your project
------------------------------------------------------------
1. In Supabase: Project Settings -> API. Copy the "Project URL" and the
   "anon public" key (NOT the service_role key — never put that one in
   the app).
2. Open index.html in a text editor (Notepad is fine). Near the very
   top of the big <script> section, find:
       const SUPABASE_URL = "YOUR_SUPABASE_URL";
       const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   Replace the placeholder text with your actual URL and key, keeping
   the quotes. Save the file.
3. That's it — index.html (plus manifest.json, sw.js, icon.svg sitting
   next to it) is now a fully working shared app. Copy this same
   index.html to every device; they'll all talk to the same database.

NOTE: the "anon" key is meant to be public-ish (it's what every visitor's
browser uses) — access control is enforced by the security rules
(Row Level Security) in schema.sql, not by keeping this key secret. Just
don't publish the service_role key anywhere.

------------------------------------------------------------
SIGNING IN — how accounts work now
------------------------------------------------------------
There's no more built-in "admin/admin123" account. Instead:
- The FIRST person to click "Create account" on the sign-in screen
  automatically becomes the admin.
- Everyone after that signs up the same way and starts as a regular
  "User" — an admin then promotes them to Admin from the Users tab if
  needed.
- Sign-in uses a username (like before), but sign-up also asks for an
  email address behind the scenes — that's only used for password
  resets and is never shown elsewhere in the app.
- Forgot a password? Use "Forgot password?" on the sign-in screen.
- To change your own password once signed in, use "Change password" in
  the sidebar.

WHAT ADMINS CAN DO DIFFERENTLY NOW
Because real authentication (Supabase Auth) now handles passwords
securely, admins can no longer set or see anyone else's password, and
can't fully delete an account from inside the app (only deactivate it,
which blocks sign-in immediately). Admins CAN still: edit a user's
name/username, promote/demote Admin <-> User, and activate/deactivate
accounts, from the Users tab. To permanently delete an account, go to
your Supabase dashboard -> Authentication -> Users, and delete it there.

------------------------------------------------------------
USING THE APP
------------------------------------------------------------
- Customers tab: add name, phone, email, address, notes. Search box
  filters by any of those fields.
- Jobs tab: create a job, attach it to a customer, set a status, due
  date, and price. "Mark delivered" on a ticket closes it out in one tap.
- Dashboard: quick counts + all open (undelivered) jobs sorted by due date.
- Sidebar "Export data": downloads a read-only .json snapshot of
  everything currently loaded — handy for backups or spreadsheets, but
  it does not restore/import (all real changes go through the shared
  database now, from any device).
- A small dot near your name in the sidebar shows "Synced — live" when
  connected, or "Connection issue" if the app can't reach the database
  (e.g. you're offline) — data entered while disconnected won't be saved.

------------------------------------------------------------
OPENING THE APP ON EACH DEVICE
------------------------------------------------------------
Windows 11: double-click index.html, or right-click it -> Open with ->
Chrome. Pin to Start/taskbar for quick access.

Android: copy the folder to your phone (or just re-download index.html
after editing the config), open it with Chrome, then "Add to Home
screen" from Chrome's menu so it behaves like an app.

Because both devices now hit the same database over the internet, you
need an internet connection to see/save data (this is different from
the old local-only version, which worked fully offline but only on one
device at a time).

------------------------------------------------------------
FILES
------------------------------------------------------------
  index.html    - the app itself (edit the SUPABASE_URL/KEY near the top)
  schema.sql    - run once in Supabase's SQL editor to set up the database
  manifest.json, sw.js, icon.svg - optional, used if you host the app so
                  it can be "installed" like a native app (see below)

------------------------------------------------------------
OPTIONAL — host it for a nicer "installed app" experience
------------------------------------------------------------
You don't have to host this anywhere — opening index.html locally on
each device works fine and always talks to the same live database.
Hosting (e.g. free on GitHub Pages) just gets you a proper install icon
and a URL you can share instead of passing the file around:
  - Create a GitHub repo, upload index.html/manifest.json/sw.js/icon.svg,
    enable Pages in Settings -> Pages, visit the resulting URL, and
    "Install" from the browser's address bar (desktop) or "Install app"
    (Chrome on Android).

------------------------------------------------------------
LIMITS OF THIS VERSION
------------------------------------------------------------
- Requires internet access to load or save anything — no offline mode.
- The SUPABASE_URL/SUPABASE_ANON_KEY are visible to anyone who views the
  page source; that's expected for this kind of app (see the anon-key
  note above) — the real access control is the security rules in
  schema.sql, so don't weaken those without understanding the trade-off.
- No file/photo attachments on jobs in this version.
- If you outgrow the free Supabase tier (very generous for a small
  team), Supabase's paid tiers scale up without needing to change the
  app itself.
