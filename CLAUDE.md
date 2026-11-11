# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

MQ Sports ERP: an offline-first Flutter app (Android/iOS; package `mq_sports_erp`, folder `mq_admin`) backed by Hive (local) and Cloud Firestore + Firebase Auth (cloud). The **source code is the source of truth**; the markdown specs in the repo root are partly outdated (see "Doc drift").

## Commands

- `flutter pub get` · `flutter run` · `flutter analyze` (lints: `flutter_lints`)
- `flutter test` / `flutter test test/models/order_model_test.dart` / `flutter test --plain-name "..."` — tests cover pure models/calculations only (see Pending section).
- Firebase config: `lib/firebase_options.dart`, `firebase.json`, `firestore.rules` (deploy rules with the Firebase CLI after editing).
- Imports are always absolute: `package:mq_sports_erp/...`.

## Development rules (coding_standards.md, architecture_overview.md, observed conventions)

- Production-ready code only: no `// TODO`, no stubs. Explicit types everywhere (`final List<X> x = ...`), avoid `dynamic`, immutable models with `final` fields, null-safe.
- Expected failures are `AppException` subclasses (`lib/core/errors/app_exceptions.dart`: `LocalStorageException`, `RemoteSyncException`, `AuthFailureException`, `PermissionDeniedException`, `ValidationException`, `VersionConflictException`, `GroupVersionConflictException`). Catch `AppException`, expose via `AsyncValue.error` / `reportFailure`; never crash the UI.
- Models are pure Dart: no Firebase types; dates serialized as ISO-8601 strings; ids are client-side `Uuid().v4()`; each has `toMap/fromMap/copyWith` and implements `SyncableModel` (`id`, `updatedAt`, `toMap`).
- Aggregate roots only get their own Hive box/Firestore collection (names in `StorageKeys`). Nested entities live inside the parent (`VariantModel` in `ProductModel`, `PurchaseItem` in `PurchaseModel`).
- Permissions are enforced twice: in notifiers (`canManage…Provider` → `PermissionDeniedException`) and in `firestore.rules`. Roles: `admin`, `manager`, `staff` (`UserRole`; unknown → staff).
- Money/stock derive from append-only records rather than stored totals (see below).

## Architecture

Layers: `models` → `services` → `repositories` → `providers` (Riverpod 2.x) → `screens`/`widgets`. `main.dart` inits Hive + Firebase and **disables Firestore persistence** (Hive is the only local cache). `app.dart` has `_AuthGate` (login) → `_AccessGate` (needs an active Firestore `users/{uid}` record, else `AccessDeniedScreen`) → `HomeScreen`, and keeps `syncCoordinatorProvider` alive.

### Local-first manual sync (not automatic)
- `BaseRepository<T>` ([lib/repositories/base_repository.dart](lib/repositories/base_repository.dart)) touches **only Hive**. Each save/delete also writes a `PendingChange` (`PendingChangeStore`, one per record, keyed `collection:id`, optional `groupId`); if logging fails the Hive write is undone. It implements `SyncableRepository` (`pullFromCloud`, `applyRemote`, `localMap`, `deleteBlockReason`, `restoreFromCloud`).
- `BaseListNotifier<T>` ([lib/providers/base_list_notifier.dart](lib/providers/base_list_notifier.dart)): `AsyncNotifier` reading from Hive, optimistic add/update/delete with rollback; reloads when `syncTickProvider` increments (bump it after any multi-repo write or sync merge).
- `SyncCoordinator` ([lib/providers/sync_coordinator.dart](lib/providers/sync_coordinator.dart)) is the only code that syncs. A live listener on Firestore `metadata/{collection}` gives per-collection cloud versions; `SyncStateStore` keeps the local version. Download happens on login (`syncOnLogin`) and on the sync button (`syncNow`) only for stale collections; upload sends only pending changes (chunks of 400, version-conflict retries, `VersionConflictException`). Pending deletes are never uploaded while collections are stale: it downloads first, re-checks with `deleteBlockReason`, then the user syncs again. Pending changes sharing a `groupId` upload in **one atomic Firestore transaction**.
- `connectivity_plus` is only used for `isOnlineProvider` (status display), not to trigger sync.

### Derived data via append-only ledgers
- Stock on hand = sum of `StockLedgerModel.quantity` per variant (`stockOnHandProvider`); `VariantModel` has no stock count. Entries are never edited (avoids multi-device overwrite).
- Party balance = opening balance + `LedgerModel` charges − payments (vendors and customers share `LedgerModel` with `partyType`). Purchase paid amount = sum of its ledger payments (`purchasePaidProvider`); `PurchaseStatus` (pending/partial/paid) is derived, not stored.
- `PurchaseRepository.confirm` writes purchase + one stock entry per item + vendor charge (+ payment) under one `groupId`, undoing local writes on failure. Purchases and stock ledgers are never deletable (rules: `delete: false`).
- Parties can't be deleted once they have ledger entries or an opening balance (`deleteGuard`); deactivate instead.

### Referential integrity rule (applies to every module)
Wherever one record references another (category → subcategory → product, vendor/customer → ledger, variant → purchase/stock entry, and future orders, POS lines, purchase orders, GRNs), sync must never leave an orphan, whichever user syncs first. Example: User A deletes a category offline, User B adds a child under it; or A's delete is already on the server while B (unsynced) adds a child.
- **Deletes:** every referenced entity needs a `deleteGuard` on its `BaseRepository` that checks local data. `SyncCoordinator` downloads first whenever deletes are pending and the cloud is newer, re-runs the guards, and cancels/restores blocked deletes (`_cancelBlockedDeletes`). Prefer deactivating over deleting where possible.
- **Known gaps (deliberately not fixed yet, by the owner's decision):** (1) `commitChanges` only checks the version of the collection being written, so a delete in one collection (e.g. `categories`) can commit while a child is uploaded to another (`products`) in the meantime; (2) pending creates/edits are not re-validated against a parent that was deleted in the cloud, because `applyRemote` keeps pending creates. Proposed fixes: an `uploadBlockReason` hook per repository and read-only version assertions on dependent collections in the delete transaction.
- **New modules:** before implementing, list every parent/child link and say how each is protected (delete guard, cross-collection check, behaviour when the parent vanished). Keep display names on child records (as `PurchaseItem` does) so history stays readable.

### Activity logs (every action leaves a log)
- `ActivityLogger` ([lib/services/activity_logger.dart](lib/services/activity_logger.dart)) writes to `ActivityLogStore` (own Hive boxes `activity_logs` + `activity_log_pending`; **no PendingChange records**, so logging never causes more logging). `record()` never throws. Provided by `activityLoggerProvider` in `activity_log_providers.dart`, which resolves the actor from `FirebaseAuth` + the local `users` box (it must not import the user providers: they depend on the logger).
- **Automatic:** `BaseRepository.save/delete/discardNewLocally` log every create / update (field-level before/after via `diffMaps`; lists of records with an `id` such as variants and order items are compared element by element) / delete / undo. This only happens when the repository got `logger:`, so **every repository provider must pass `logger: ref.watch(activityLoggerProvider)`** (subclasses forward it to `super`). `BaseListNotifier.reportFailure`/`_rollback`/`logFailure` log refused (warning) and failed (error) actions; notifiers that catch errors themselves must call `logFailure(e)`. `main.dart` logs uncaught Flutter/platform errors. `AuthController` logs login/logout. `SyncCoordinator` logs sync completed/failed/conflict/cancelled deletes.
- **Manual:** every new business action (like order confirmed/cancelled, payment, audit applied) should call `ref.read(activityLoggerProvider).record(kind: LogKind.action, ...)` with a readable summary after it succeeds.
- **Cloud:** logs are NOT in `syncRepositoriesProvider` and have no metadata version. `SyncCoordinator._uploadLogs` (runs after every sync, also failed ones) sends pending logs with `FirestoreService.uploadLogs` and then purges uploaded logs older than 90 days locally. Admins view them in the Activity Logs module (`screens/logs`): local logs plus "Load from cloud" (latest 500 via `fetchRecentLogs`). Rules: only admins read, any active user creates, identical re-writes allowed (safe retry), no deletes.
- Never put secrets (passwords) in log summaries or changes.

### Adding a module (several registries must be touched)
1. Model + repository (`BaseRepository` or subclass) + providers file; add box/collection name to `StorageKeys`.
2. Add the repository to `syncRepositoriesProvider` ([lib/providers/sync_registry_provider.dart](lib/providers/sync_registry_provider.dart)).
3. Add an `ErpModule` (id, title, icon, `allowedRoles`, builder) in [lib/providers/module_registry_provider.dart](lib/providers/module_registry_provider.dart).
3b. Pass `logger: ref.watch(activityLoggerProvider)` to the repository and log its business actions (see Activity logs).
4. Add a `match` block in `firestore.rules` (collections not listed fall through to a generic "any active user" rule, and the exclusion list in that fallback must be updated too).

### Users & auth
`AuthService` (sign-in, uid stream), `AuthAdminService` (admins create logins through a temporary secondary Firebase app so their own session survives; deletes the login if the Firestore user write fails), `user_profile_*` (personal profile/last login). Users sync like other collections; only active admins manage `users`.

## Completed modules (all in `lib/screens/<module>`)
- **Users** (admin) · **Categories** (tree, `category_tree.dart`) · **Products** with nested **Variants** (SKU generator, attributes, cost/sale/wholesale prices, price warnings, `variant_picker`)
- **Customers / Vendors** with balance ledgers, party detail screen, ledger entry dialog, `party_picker`
- **Purchases** (create/confirm, detail, payments, status chip) → feeds **Stock** (read-only stock ledger screen; flags negative stock)
- **Stock Audit** (`stock_audit_screen.dart`, `StockAuditRepository`, collection `stock_audits`): admin/manager only, opened from the Stock screen's Audit button. The user enters counted quantities; confirming re-reads the system quantity from the stock ledger, saves an append-only `StockAuditModel` (system vs counted per item, who counted) and one `adjustment` stock entry per difference (`sourceId` = audit id), all in one `groupId`. History screen included.
- **Low-stock alerts**: `VariantModel.alertThreshold` (optional, default 0 = no alert; set in the variant dialog) and `isLowStock()` in `core/utils/stock_alerts.dart` (on hand ≤ threshold, threshold > 0, active products/variants only). The Stock screen has a Low stock filter, highlighting and count.
- **Executive dashboard** (`dashboard_providers.dart`, `screens/dashboard/dashboard_panel.dart`, embedded at the top of `HomeScreen`, admin/manager only): sales today/month (non-cancelled orders by `orderDate`, after discounts), stock valuation at catalog cost vs sale price (positive stock only), pending/processing/shipped counters, low-stock count and top 5 sellers (Today/This month). Pure functions `computeDashboardStats`/`computeTopSellers` are unit-tested; everything is computed from Hive, no cloud reads or new collections beyond `stock_audits`.
- **Sales & Orders** (`lib/screens/sales`, `sales_providers.dart`, `OrderRepository`): customer required (no walk-in), a Retail/Wholesale tag per order (`OrderModel.saleType`, optional field: old orders load as retail; the form starts it from the customer's type and re-prices lines still at the old catalog price; list has a filter), per-line and per-order discounts stored as amounts, status pipeline Pending → Processing → Shipped → Delivered (+ Cancelled). Confirming = one `groupId` with the order, negative `sale` stock entries, a customer ledger charge and an optional payment (mirrors purchases). Stock is checked against the local stock ledger before confirming; the customer credit limit is checked too. Cancel (admin/manager only, not after Delivered) returns stock with positive `sale` entries and posts the charge reversal as a customer ledger *payment* carrying `orderId`. Payment state reuses `purchaseStatusFor`/`PurchaseStatusChip`; the paid amount is the sum of the order's ledger payments (`orderPaidProvider`). Cancelling an order that is not uploaded yet reuses its pending `groupId` (`_groupIdFor`) so a group is never split. Updates are local-instant; other devices see changes after sync (no extra Firestore listeners, by decision).
- **Sync screen** + `sync_status_chip` (pending list, versions, manual upload/download)
- Module access: categories/products/customers/stock/sales = admin+manager+staff; vendors/purchases = admin+manager; users and Activity Logs = admin.
- Sales permissions: staff may create orders, advance status and record payments. For that, `firestore.rules` lets any active user create `stock_ledgers` entries of type `sale` with negative quantity, and customer `ledgers` entries (charge/payment) that carry an `orderId`; only admin/manager can write `status == 'cancelled'`. `LedgerModel.orderId` is an optional field (default empty) so old records still load.

## Pending / planned (the old `todo` file was removed by the owner; open issues live in `todo_decisions.md`)
- Update Firebase **Storage** rules (draft in `todo`, commented): product images under `products/`, writes for admin/manager.
- Role-aware UI helper idea (`isAdminOrManager`) noted in `todo`.
- Not built yet: Purchase Orders, Goods Receipt Notes (receive workflow), POS checkout (barcode, tax, split payments, receipts), stock adjustments/audit (`StockMovementType.adjustment` has no producer), refunds. `StorageKeys` already reserves `purchase_orders`, `goods_receipt_notes`, `user_profiles`.
- **Open decisions** are tracked in [todo_decisions.md](todo_decisions.md): overselling across devices (negative stock), cancel-as-ledger-payment, concurrent status edits on one order, stock counts being snapshots, dashboard figures following the local copy, limits of the activity logs, and the two sync gaps. Do not change that behaviour without asking the owner.
- Tests: `test/models/order_model_test.dart`, `test/providers/dashboard_providers_test.dart`, `test/core/stock_alerts_test.dart`, `test/core/map_diff_test.dart`, `test/services/activity_log_test.dart` (models, calculations, log store/logger and `BaseRepository` logging with a temp Hive dir; sync coordinator, notifiers and screens are untested).

## Doc drift
- `state_management_and_sync.md` describes automatic connectivity-triggered bulk sync via a `SyncService`; the real design is the manual, version-based `SyncCoordinator` above.
- `architecture_overview.md` says repositories fetch in the background and write to Firestore concurrently; they don't. It still lists Orders/PO/GRN as entities, which don't exist yet.
- `README.md` is Flutter boilerplate. Earlier chat history (Claude Web) is not available in the repo; the git log (4 commits: Initial, Catalog, Sync, Parties/Ledgers) plus uncommitted Purchasing/Stock work is the only history.
