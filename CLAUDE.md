# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

MQ Sports ERP: a Flutter app (package `mq_sports_erp`, folder `mq_admin`) for Android, iOS, Windows, macOS, Linux and the web, talking to the backend API in the sibling repository `c:\src\mq_erp` (NestJS + PostgreSQL; see its `README.md`, `docs/target_stack.md`, `docs/api_design.md`). The **source code is the source of truth**; the markdown specs in this repo's root are partly outdated (see "Doc drift").

- **Mobile and desktop** are offline-first: a local SQLite database (Drift) plus a queue of unsent actions, synced with the API.
- **Web** is online-only: no local database, every action is an API call (`docs/web_admin.md`).
- There is **no Firebase and no Hive any more**. `firestore.rules`, `firebase.json` and the Android `google-services` setup are leftovers that can be deleted.

## Commands

- `flutter pub get` · `flutter run` · `flutter analyze` (lints: `flutter_lints`, strict casts/inference)
- `dart run build_runner build` after changing `lib/data/local/tables.dart` (regenerates `app_database.g.dart`, which is committed).
- `flutter test` runs the unit tests. Two real-server suites are skipped unless asked for (`--dart-define=RUN_API_TESTS=true --dart-define=API_BASE_URL=...`, API on an EMPTY database with one admin login): `test/online/api_flow_test.dart` (web mode) and `test/data/offline_flow_test.dart` (a day without internet with two devices). Commands are at the top of each file.
- Web: `flutter run -d chrome --web-port 8080 --dart-define=API_BASE_URL=http://localhost:3000` (see `docs/web_admin.md`). Desktop: `flutter run -d windows`.
- Imports are always absolute: `package:mq_sports_erp/...`.

## Development rules

- Production-ready code only: no `// TODO`, no stubs. Explicit types everywhere (`final List<X> x = ...`), avoid `dynamic`, immutable models with `final` fields, null-safe.
- Expected failures are `AppException` subclasses (`lib/core/errors/app_exceptions.dart`): `RemoteSyncException` (server unreachable or failing), `AuthFailureException`, `PermissionDeniedException`, `ValidationException` (also what 400/404/409 from the API become). Catch `AppException`, expose via `AsyncValue.error` / `reportFailure`; never crash the UI.
- Models are pure Dart: dates as ISO-8601 strings; ids are client-side `Uuid().v4()`; each has `toMap/fromMap/copyWith` and implements `SyncableModel`. The JSON keys of `toMap` are the API's JSON keys.
- Permissions are enforced twice: in notifiers (`canManage…Provider` → `PermissionDeniedException`) and by the API. **The server has the final say.** Roles: `admin`, `manager`, `staff` (`UserRole`; unknown → staff).
- Money/stock derive from append-only records rather than stored totals (see below).

## Architecture

Layers: `models` → `data` / `online` (storage and API) → `providers` (Riverpod 2.x) → `screens`/`widgets`. Screens only talk to providers.

`app.dart`: `_AuthGate` (login) → `_AccessGate` (needs an active user, else `AccessDeniedScreen`; starts the sync controller on mobile/desktop) → `HomeScreen`.

### The repository interface
`Repository<T>` ([lib/repositories/repository.dart](lib/repositories/repository.dart)) is all the providers use: `getLocal`, `getLocalById`, `save`, `delete`, `deleteBlockReason`; plus `PurchaseOperations`, `OrderOperations`, `StockAuditOperations` for the multi-record actions (`confirm`, `cancel`). `DataMode` ([lib/providers/data_mode.dart](lib/providers/data_mode.dart)) picks the implementation: `onlineOnly` on web (`lib/online/online_repositories.dart`), `localFirst` elsewhere (`lib/data/local_repositories.dart`). Each repository provider in `*_providers.dart` makes that choice.

`BaseListNotifier<T>` reads `repository.getLocal()`, does optimistic add/update/delete with rollback, and reloads when `syncTickProvider` increments (bump it after any multi-repo action or sync).

### Mobile and desktop: local database + outbox + sync (lib/data)
- **Database**: Drift/SQLite with typed relational tables mirroring the server's ([lib/data/local/tables.dart](lib/data/local/tables.dart), mapped to models in `collections.dart`). One database file per signed-in user (`databaseProvider`), so one person's unsent work is never uploaded under another name. It holds only **server-confirmed** data plus the `outbox` and `sync_kv` (cursor) tables.
- **Writes never touch the records.** `LocalRepository.save` queues an outbox entry (`OutboxStore`: coalesces edits of an unsent record, drops a delete of a never-uploaded one; states `pending` / `sent` / `failed`). Actions (`orderConfirm`, `orderStatus`, `orderCancel`, `orderPayment`, `purchaseConfirm`, `purchasePayment`, `ledgerEntry`, `auditConfirm`) are queued as one command each.
- **Reads = confirmed data + queue.** `pending_effects.dart` works out, from the queued commands alone, the order, the stock leaving and the ledger charge the user will cause, so they see their work at once. They are never stored: after upload the server's own records arrive and replace them, and every overlay function skips an action whose records are already there (nothing is shown twice).
- **Sync engine** ([lib/data/sync_engine.dart](lib/data/sync_engine.dart)): upload the queue oldest first, each entry with its own id as `Idempotency-Key` (a lost response cannot double an action); a 4xx marks the entry `failed` with the server's reason (user retries/discards on the Sync screen); a network or 5xx error stops the upload and keeps order. Then download everything since the cursor (`GET /v1/sync/changes`), writing data and the new cursor in ONE transaction. Accepted entries stay (state `sent`) until their records have arrived.
- **Offline sales** are always recorded: orders are uploaded with `recordedOffline: true`, so the server skips its stock and credit-limit refusals (the goods already left). Stock can go negative; the Stock screen flags it.
- `SyncController` ([lib/providers/sync_controller.dart](lib/providers/sync_controller.dart)) syncs by itself: at sign-in, when the connection returns, ~3 s after something is queued, every minute. `syncSummaryProvider` feeds the app-bar chip; `screens/sync_screen.dart` shows the queue.
- **Server calls** are all in one class, `ApiCommands` ([lib/online/api_commands.dart](lib/online/api_commands.dart)), used by both the web repositories and the sync engine. Times go out in UTC, amounts rounded to 2 decimals.

### Auth
`ApiAuthService` signs in through the API (`ApiClient`: single-flight token refresh, errors mapped to `AppException`s). The refresh token and the user are kept (`SharedPrefsTokenStore`) so the app **opens offline** as the saved user and renews the token when a request first gets through. `currentUserProvider` = server's `/auth/me`, else the saved user. Creating a login (`ApiAuthAdminService`) needs a connection. Users are never deleted: "delete" turns the login off.

### Web (lib/online)
`RemoteStore` is an in-memory copy filled from the sync endpoint (first call = everything, then only changes; polled every 30 s and after each own action). Server timestamps are converted to local time on the way in (`normalizeDates`). See `docs/web_admin.md`.

### Derived data via append-only ledgers
- Stock on hand = sum of `StockLedgerModel.quantity` per variant (`stockOnHandProvider`); `VariantModel` has no stock count. Entries are never edited.
- Party balance = opening balance + `LedgerModel` charges − payments (vendors and customers share `LedgerModel` with `partyType`). Purchase/order paid amount = sum of its ledger payments; payment status is derived (`purchaseStatusFor`).
- Purchases, orders, stock movements and audits are never deletable. Parties and products with history can only be deactivated (local `deleteGuard`s give a quick answer; the server enforces it with foreign keys).

### Referential integrity
The server's PostgreSQL foreign keys and transactions enforce it, so the old sync gaps (a child uploaded under a parent deleted elsewhere) are closed: the server refuses such an action and the entry shows as `failed` for the user to resolve. Keep display names on child records (as `PurchaseItem` does) so history stays readable.

### Activity logs
The server writes every log (in the same transaction as the action, user taken from the login). The app's `ActivityLogger` is a no-op hook; the Activity Logs screen (admin) reads `GET /v1/logs` and needs a connection.

### Adding a module
1. Backend first (`c:\src\mq_erp`): table, endpoints, tests, and the sync collection.
2. Here: model, a Drift table in `tables.dart` + a `LocalCollection` in `collections.dart` (+ `LocalCollections`), `build_runner`; an overlay in `pending_effects.dart` if actions create records; an `ApiCommands` method; an `Online…Repository` and a local repository; the repository provider choosing between them; an `OutboxKind` and its case in `SyncEngine._send`/`_arrived` if it is an action.
3. Add an `ErpModule` (id, title, icon, `allowedRoles`, builder) in [lib/providers/module_registry_provider.dart](lib/providers/module_registry_provider.dart).

## Completed modules (all in `lib/screens/<module>`)
- **Users** (admin) · **Categories** (tree, `category_tree.dart`) · **Products** with nested **Variants** (SKU generator, attributes, cost/sale/wholesale prices, price warnings, `variant_picker`)
- **Customers / Vendors** with balance ledgers, party detail screen, ledger entry dialog, `party_picker`
- **Purchases** (create/confirm, detail, payments, status chip) → feeds **Stock** (read-only stock ledger screen; flags negative stock)
- **Stock Audit** (admin/manager): counted quantities, confirming adjusts stock; history screen included.
- **Low-stock alerts**: `VariantModel.alertThreshold` and `isLowStock()` in `core/utils/stock_alerts.dart`.
- **Executive dashboard** (`dashboard_providers.dart`, admin/manager): computed in the app from the lists (`computeDashboardStats`, unit-tested); the server's `GET /v1/dashboard` gives the same figures (checked by the flow tests).
- **Sales & Orders**: customer required, Retail/Wholesale tag, per-line and per-order discounts, status pipeline Pending → Processing → Shipped → Delivered (+ Cancelled, admin/manager only, not after Delivered), payments, credit limit. A cancelled order is final (the server refuses any later change). **Online-store orders** (`channel` `web`, placed by shoppers on the Next.js store in `c:srcmq_erpappsstore`, cash on delivery) arrive through sync like any order: `OrderModel.shippingFee` is part of `totalAmount`, `shippingAddress` holds the delivery details, and the web customers are ordinary customer records. Stock is taken out at checkout; an admin/manager cancels fake orders. The shop's own offline orders never carry a delivery fee. Drift schema is version 2 (the `orders` table gained `shippingFee`, `shippingAddress`, `channel`).
- **Photos everywhere** (`lib/online/photo_service.dart`, `lib/widgets/photo_widgets.dart`): products have up to 10 photos (add, delete, make main; `ProductModel.images`, stored as JSON in the Drift `products.imagesJson`); users, categories, customers and vendors have one photo each (`photoUrl`). The file is chosen with `file_picker`, checked on the device (JPEG/PNG/WebP by content, 10 MB), uploaded straight to storage with a link the API signs (`/v1/photos/:kind/:id/...`, `/v1/products/:id/images/...`), then the changed record is pulled back (web: RemoteStore refresh, others: sync pull). Photos need a connection and a record the server already has; saving a form never sends photo fields (the explicit `ApiCommands` bodies leave them out), forms pass `photoUrl`/`images` through `copyWith` so the local copy stays right. Drift schema is version 3.
- **Settings** (all roles; `lib/screens/settings/settings_screen.dart`): your profile photo, the welcome guide, and for admin/manager the online store settings (`/v1/store-settings`, only admin saves; "Send test e-mail" checks the server's SMTP).
- **Welcome guide** (`lib/screens/onboarding/`): role-specific pages (staff, manager, admin with a first-setup checklist) shown once per person per device after sign-in (`OnboardingGate` in the home screen, flag in SharedPreferences, `OnboardingStore.version` shows a changed guide again); reopened from Settings.
- **Sync screen** + `sync_status_chip` (queue, refused entries with Retry/Discard, Sync now, download everything again). On web an "Online" chip replaces it.
- Module access: categories/products/customers/stock/sales = admin+manager+staff; vendors/purchases = admin+manager; users and Activity Logs = admin. Staff may create orders, advance status and record payments; the server sends staff no vendors, purchases or audits.

## Pending / planned
- The Next.js online store is built (backend monorepo `apps/store`, see its README); online payment, e-mail/SMS and shopper password reset are not.
- Not built yet: Purchase Orders, Goods Receipt Notes, POS checkout (barcode, tax, split payments, receipts), refunds.
- Web: server-side paging for the big lists (orders, ledger, movements) once they grow; refresh token in an httpOnly cookie.
- Mobile/desktop: the refresh token is in plain preferences (move to secure storage); product photos are downloaded in the product JSON (`images`) but not shown yet; the stock sum has a SQL query (`onHandByVariant`) that the Stock screen does not use yet.
- Offline catalog/party edits are last-writer-wins: a stale offline edit can overwrite someone's newer one when it uploads (an agreed trade-off; versioned edits would fix it).
- Tests: `test/data` (database round trips, outbox, pending effects, sync engine with a fake server), `test/online` (API client, in-memory store, web flow), `test/models`, `test/providers`, `test/core`. Screens are untested.

## Doc drift
- `state_management_and_sync.md`, `architecture_overview.md` and `todo_decisions.md` describe the old Hive/Firestore design (automatic or manual Firestore sync, version metadata, known sync gaps). The decisions in `todo_decisions.md` are now settled by the server: see `c:\src\mq_erp\docs\api_design.md`.
- `README.md` is Flutter boilerplate.
