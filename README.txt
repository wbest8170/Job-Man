DISPATCH — Customer & Job Tracker
==================================

WHAT THIS IS
A single-page app for capturing customers and tracking jobs from intake
through delivery (New -> In progress -> Ready -> Delivered), with sign-in,
user maintenance, and basic reports. All data is stored locally in the
browser (localStorage) — no server, no internet required day-to-day.

SIGNING IN
First run creates one default account automatically:
    Username: admin
    Password: admin123
Sign in, then go to Users and either change that password or create a
named account for yourself and deactivate/delete the default one (you
can't delete or lock out the very last admin account, so create a
replacement admin first).

IMPORTANT — please read: this login is client-side only. It's enough to
stop casual access on a shared device and to tell who logged what job,
but anyone with access to the browser's developer tools or local storage
on that device could theoretically get at the underlying data. Don't
reuse an important password here, and don't treat this as a substitute
for real access control on sensitive data.

USER MAINTENANCE (Users tab, admin only)
- Add users with a username, role (Admin or User), and password.
- Admins can manage users and see the Team report; Users can work
  Customers/Jobs and see the Customers/Jobs reports.
- Edit a user to change their role, activate/deactivate them, or reset
  their password (leave the password blank to keep it unchanged).
- You can't delete your own account, and you can't delete or deactivate
  the last remaining active admin — that prevents locking everyone out.

REPORTS (Reports tab)
- Customers: totals, new-this-month, average jobs per customer, and a
  per-customer breakdown (jobs, open, delivered, total billed) — with
  CSV export.
- Jobs: totals, overdue-and-open count, delivered count, total billed,
  a status breakdown, and a full job list — with CSV export.
- Team (admin only): who's added how many customers/jobs and when they
  last signed in — with CSV export.

FILES
  index.html   - the app itself (this is the only file you actually need)
  manifest.json, sw.js, icon.svg - optional, only used if you host the
                 app so it can be "installed" like a native app

------------------------------------------------------------
OPTION A — FASTEST: just open the file (works today, zero setup)
------------------------------------------------------------
Windows 11:
  1. Copy the whole "jobtrack" folder anywhere (Desktop, USB, OneDrive).
  2. Double-click index.html — it opens in your default browser
     (Edge or Chrome recommended).
  3. Right-click index.html > "Pin to Start" or make a desktop shortcut
     for one-click access.

Android:
  1. Copy the "jobtrack" folder to your phone (via USB, email, or a
     cloud drive like Google Drive/OneDrive).
  2. Open index.html with Chrome (use a file manager app, tap the file,
     choose "Open with Chrome").
  3. In Chrome's menu, tap "Add to Home screen" so it behaves like an app.

NOTE: with this option, each device keeps its OWN data — a customer you
add on your PC won't automatically show up on your phone, and neither
will user accounts you create. Use the "Export backup" / "Import backup"
buttons in the app's sidebar to move everything — customers, jobs, and
user accounts — between devices (export a .json file on one device,
import it on the other; importing signs you out so you can log in with
the imported accounts).

------------------------------------------------------------
OPTION B — RECOMMENDED FOR REAL USE: host it so both devices share data
------------------------------------------------------------
Hosting the folder on a small web server lets you install it as a real
app (installable icon, works offline, no browser address bar) AND —
if you're comfortable adding a tiny backend later — sync data between
devices. Two easy, free ways to host as-is (still device-local storage,
but with the installable-app experience):

  1. GitHub Pages (free):
     - Create a GitHub repo, upload these files, enable Pages in
       Settings > Pages. You'll get a URL like
       https://yourname.github.io/jobtrack/
     - Open that URL on your Windows 11 PC in Edge/Chrome: click the
       "Install" icon in the address bar.
     - Open the same URL on Android in Chrome: menu > "Install app".

  2. Any local network: run a tiny static server from the folder, e.g.
     with Python already on most machines:
         python -m http.server 8000
     then visit http://<your-pc-ip>:8000 from your phone on the same Wi-Fi.

------------------------------------------------------------
USING THE APP
------------------------------------------------------------
- Customers tab: add name, phone, email, address, notes. Search box
  filters by any of those fields.
- Jobs tab: create a job, attach it to a customer, set a status, due
  date, and price. "Mark delivered" on a ticket closes it out in one tap.
- Dashboard: quick counts + all open (undelivered) jobs sorted by due date.
- Sidebar "Export backup": downloads a .json snapshot of everything —
  keep this somewhere safe, and use "Import backup" to restore or move
  data to another device/browser.

LIMITS OF THIS "BASIC" VERSION
- Data lives in the browser's local storage, per device/browser. Clearing
  browser data will erase it — export backups regularly.
- No multi-user logins or real-time sync between devices out of the box.
  If you outgrow this, the natural next step is adding a small backend
  (e.g. a free database + login) so every device reads/writes the same
  data instead of its own local copy — happy to build that next if useful.
