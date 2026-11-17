# Mobile and desktop app (offline-first)

The same Flutter app on Android, iOS, Windows, macOS and Linux. It keeps its own
database on the device (SQLite) and works with no connection at all: what you do is
saved on the device and uploaded to the server when there is a connection.
Architecture: see `CLAUDE.md`. The web admin is different (online-only):
`docs/web_admin.md`.

## Run it

1. Start the backend (`c:\src\a2_stocks_api`): `docker compose up -d`, then `pnpm api:dev`.
   Check http://localhost:3000/v1/health. Dev login: `admin@mq.test` / `DevPass123`.
2. Run the app and tell it where the API is (`--dart-define=API_BASE_URL=...`):

| Where | Command |
|---|---|
| Windows / macOS / Linux | `flutter run -d windows --dart-define=API_BASE_URL=http://localhost:3000` |
| Android emulator | `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000` (10.0.2.2 is the emulator's name for your computer) |
| A real phone on the same Wi-Fi | `flutter run --dart-define=API_BASE_URL=http://<your computer's IP>:3000` (allow Node through the Windows firewall when asked) |
| iOS simulator | `flutter run --dart-define=API_BASE_URL=http://localhost:3000` |

Plain `http://` works in **debug** builds only. A release build must use `https://`
(see `c:\src\a2_stocks_api\docs\deploy.md`):
`flutter build apk --release --dart-define=API_BASE_URL=https://api.yourshop.com`.

## The first time

Sign in **with a connection**: the app downloads everything the first time (the chip
in the top bar says "Syncing", then "Synced"). From then on it opens and works with
no connection, as the same user, and renews its login by itself when the connection
is back.

## What to try (a day without internet)

1. Sign in, wait for "Synced". Add a category and a product, then buy stock with a
   purchase.
2. **Cut the connection**: stop the API (Ctrl+C) or switch off Wi-Fi.
3. Keep working: make sales, take a payment, move an order along, count stock. The
   stock and what customers owe change at once. The chip says "N waiting (offline)".
4. Close the app completely and open it again, still offline. You are still signed in
   and your work is still there.
5. **Restore the connection.** Within a minute (or press the chip, then "Sync now")
   it uploads everything in order, then downloads. The chip returns to "Synced".
6. Open the **Sync** screen (tap the chip): it lists what is waiting, and anything the
   server **refused** with the reason, with Retry and Discard.
7. Two devices: sell the last items on both while one is offline. When it reconnects
   the sale is still recorded and the stock shows negative with a warning (the goods
   have already left the shop).
8. Creating a **user login** needs a connection (the server makes the account).

## What happens to unsent work

- It lives in the signed-in user's own database file on the device, so it survives
  closing the app and restarting the device.
- Signing out keeps it; it is uploaded the next time that user signs in with a
  connection. Another person signing in on the same device cannot upload it.
- Uninstalling the app, or clearing its data, deletes it. Sync before you do.

## Known limits

- Edits to the catalog, customers and vendors made offline are "last writer wins":
  if someone changed the same record meanwhile, the upload overwrites it.
- Sales made offline skip the server's stock and credit-limit checks (the sale already
  happened). Negative stock is flagged on the Stock screen.
- The login is kept in the app's plain preferences (not yet in the system's secure
  storage).
- Activity logs are written by the server and read from it, so they need a connection.
