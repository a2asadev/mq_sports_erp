# API Design (approved)

Part of docs/target_stack.md, Phase 1. The Flutter models in `lib/models` are the source of truth for fields. Approved on 2026-11-14.

## Approved decisions

1. Existing Firestore data: one-time import script (written after the API works), user uid mapped to a new UUID.
2. Client-generated UUIDs and client-made numbers (ORD-, PUR-, AUD-) stay; unique constraint on the server.
3. Overselling: API confirms check stock inside the transaction with a row lock on `stock_balances` and reject negative stock. Offline sync pushes may still go negative, as today (todo_decisions 1).
4. A cancelled order can never change status again; the server refuses it (changes todo_decisions 3).
5. Cancel stays a customer ledger `payment` carrying `order_id` (todo_decisions 2). `entry_type` is stored as text so a `reversal` type can be added later.
6. Stock audit: the server re-reads the system quantity inside the audit transaction (todo_decisions 4).
7. Sync cursor: a server-assigned sequence per row (`server_seq`), not device `updatedAt`.
8. Single branch/warehouse for now; `location_id` added later.
9. Variant SKU is unique across the catalog.

## Tables (snake_case)

- `users`, `refresh_tokens`
- `categories` (`parent_id` self FK, null = top level)
- `products` (`category_id` FK), `product_variants` (`product_id` FK, unique `sku`, cost/sale/wholesale price, `alert_threshold`, `attributes` jsonb)
- `vendors`, `customers` (opening balance; credit limit on customers)
- `ledger_entries` (`party_type`, `party_id`, `entry_type` charge|payment, positive `amount`, nullable `purchase_id`, `order_id`)
- `purchases`, `purchase_items` (name snapshots)
- `stock_movements` (append-only, signed quantity, type purchase|sale|adjustment, `source_type`, `source_id`)
- `stock_balances` (cached on-hand per variant, updated in the same transaction)
- `stock_audits`, `stock_audit_items` (append-only)
- `orders` (`channel` pos|admin|web, `sale_type`, discount), `order_items`, `order_status_history`
- `activity_logs` (append-only, user taken from the JWT)

Later: product images (object key only), store accounts, purchase orders, GRNs, `location_id`.

## Endpoints (`/v1`)

| Module | Endpoints | Roles |
|---|---|---|
| Auth | login, refresh, logout, me | all |
| Users | CRUD, admin-created logins | admin |
| Categories / products / variants | CRUD, deactivate, paginated list with filters | read all; write admin, manager |
| Customers / vendors | CRUD, deactivate, `GET /:id/balance` | read all; write admin, manager |
| Ledger | list by party, manual entry | admin, manager |
| Purchases | `POST /purchases/confirm`, `POST /purchases/:id/payments`, list, detail | admin, manager |
| Stock | `GET /stock` (on hand, low-stock filter, negative flag), movements list | all |
| Stock audit | `POST /stock-audits/confirm`, list, detail | admin, manager |
| Orders | `POST /orders/confirm`, `POST /orders/:id/status`, `POST /orders/:id/cancel`, `POST /orders/:id/payments`, list, detail | all; cancel admin, manager |
| Dashboard | `GET /dashboard` | admin, manager |
| Logs | list with filters and paging | admin |
| Sync (later) | `GET /sync/:collection?since=seq`, `POST /sync/push` | all |

Each "confirm" is one database transaction (replaces `groupId` and undo-on-failure).

## Contract rules (so Flutter models keep working)

- Money: `numeric(14,2)` in Postgres, JSON numbers in responses (Flutter reads `as num`).
- Empty string means "none" in Flutter; Postgres uses NULL with real FKs; the API maps null to `''`.
- Dates: ISO-8601 strings. Field names in JSON match the Flutter `toMap` keys (camelCase).
- Totals (`subtotal`, `totalAmount`, balances, paid amounts) are recomputed by the server; client totals are ignored.
- Variants referenced by purchases, orders or stock cannot be deleted (FK RESTRICT); deactivate instead.
- Permissions are enforced in API guards, mirroring `firestore.rules`.
