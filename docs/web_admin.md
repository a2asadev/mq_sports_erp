# The web admin (online-only)

The same Flutter app, built for the browser. It has **no local database and no
Firebase**: every action goes to the backend API (`c:\src\mq_erp`), which
enforces all the rules, and what the screens show is what the server saved.
Mobile and desktop are unchanged (Hive + Firebase, manual sync) until Phase 3.

## Run it on your computer

1. Start the backend (see `c:\src\mq_erp\README.md`): `docker compose up -d`, then
   `pnpm api:dev` (it listens on http://localhost:3000). Make sure you have an
   admin login (`pnpm create-admin you@mail.com 'a long password'`).
2. Run the web app on port 8080, because the API's development settings allow
   that address (`CORS_ORIGINS` in `apps/api/.env`):

   ```
   flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3000
   ```

If the page loads but every request fails, open the browser console: a message
about "CORS" means the page's address is not in the API's `CORS_ORIGINS`.

## Build and deploy

```
flutter build web --release --dart-define=API_BASE_URL=https://api.yourshop.com
```

Copy `build/web/*` to the server's `admin-web/` folder (see
`c:\src\mq_erp\docs\deploy.md`). It is then served at `https://admin.yourshop.com`.
The API address is fixed into the build, so build once per environment.

## How it works

| | Mobile / desktop | Web |
|---|---|---|
| Choice | `DataMode.localFirst` | `DataMode.onlineOnly` (automatic on web, see `lib/providers/data_mode.dart`) |
| Reads | Hive | in-memory copy of the server's data (`lib/online/remote_store.dart`) |
| Writes | Hive + pending changes, uploaded by a manual sync | one API call per action (`lib/online/online_repositories.dart`) |
| Sign-in | Firebase | the API (`lib/online/api_auth_service.dart`) |
| Activity log | written on the device, uploaded | written by the server |
| Sync screen / chip | yes | replaced by an "Online" chip |

- **Data loading:** the first screen downloads everything the user may see, through the server's
  "changes since" endpoint. Later the app only asks for what changed (every 30
  seconds, and right after each of your own actions), so other people's work
  appears without reloading. Nothing is kept on the device: a reload downloads
  again.
- **Confirm actions are single requests**: confirming a purchase, an order or a
  stock count, and cancelling an order, each succeed or fail as a whole on the
  server. A retry after a dropped connection cannot create a second sale or
  purchase (the request carries the document's id as an `Idempotency-Key`).
- **Rules live on the server.** The app still checks the obvious things first
  (to give quick messages), but the server has the final say: not enough stock,
  credit limit, permissions, duplicate SKUs and so on come back as clear messages.
- **Staff see less**: the server sends staff no vendors, purchases or stock counts.

## Tests

- `flutter test`: unit tests, including the API client and the in-memory store
  with a fake server (`test/online/api_client_test.dart`, `remote_store_test.dart`).
- `flutter test --platform chrome test/online`: the same, compiled to JavaScript.
- The full flow against a real API (sign-in, catalog, purchase, sales, stock
  count, users, logs, sessions) is `test/online/api_flow_test.dart`. It is skipped
  unless you ask for it, and needs the API running on an **empty database that
  has one admin login**:

  ```
  flutter test test/online/api_flow_test.dart \
    --dart-define=RUN_API_TESTS=true \
    --dart-define=API_BASE_URL=http://127.0.0.1:3100 \
    --dart-define=FLOW_ADMIN_EMAIL=flow-admin@mq.test \
    --dart-define=FLOW_ADMIN_PASSWORD=FlowPass123
  ```

## Known limits

- **Everything is loaded into memory.** Fine for a shop's first years, but the
  orders, ledger and stock-movement lists only ever grow. When they get large
  (tens of thousands of rows) those screens should move to server-side paging.
  The dashboard figures can already be read from the server (`GET /v1/dashboard`);
  the app currently computes them itself, and the test shows both agree.
- **The refresh token is kept in the browser's local storage** so a reload does
  not sign you out. Any script on the page could read it, so the web admin must
  never load third-party scripts. A later step can move it to an httpOnly cookie.
- **Users cannot be deleted**, only turned off (their history refers to them).
  "Delete user" in the app therefore turns the login off.
- **Not verified in a browser by me**: the online layer is tested against the real
  API and compiles for the web, but nobody has clicked through the screens in a
  browser yet. Do that once before relying on it.
