# Target Stack: MQ Sports ERP + Online Store

Agreed plan (Nov 2026). Follow strictly; do not propose alternative stacks unless asked.
Source of truth for current behaviour is the Flutter code in this repo (see CLAUDE.md).

## Stack

| Layer | Choice |
|---|---|
| Mobile + desktop (Android, iOS, macOS, Windows, Linux) | Flutter + Riverpod, Drift (SQLite) offline-first, "changes since X" sync (replaces Hive) |
| Web admin | Same Flutter app on web, online-only (no local DB, no sync coordinator) |
| Online store | Separate Next.js (React + TypeScript) app, SEO-friendly, shares API types |
| API | Node + TypeScript, NestJS, REST, JWT + refresh tokens (httpOnly cookie on web) |
| Database | PostgreSQL with Prisma (or Drizzle) |
| Jobs / cache | Redis + BullMQ (emails, image resizing, order processing) |
| Images | Self-hosted MinIO (S3-compatible) on the VPS, `sharp` for WebP sizes (thumbnail/medium/large), Cloudflare free CDN in front, nightly mirror to Backblaze B2 |
| Payments (store) | Stripe, or a local Pakistan gateway |
| Hosting | One VPS, Docker Compose + Caddy (auto HTTPS). Cloudflare Pages optional for static admin |
| Backups | Daily `pg_dump` + image mirror to Backblaze B2 |
| Repo | Monorepo: `apps/api`, `apps/store`, `apps/flutter`, `packages/types` |

## Domains

```
admin.yourshop.com -> Flutter web (static files)
yourshop.com       -> Next.js store
api.yourshop.com   -> Node API
media.yourshop.com -> MinIO via Cloudflare CDN
```
Postgres, Redis and the MinIO admin console stay private.

## Architecture

```
Flutter (mobile, desktop, web admin) -+
Next.js store                        -+-> Node API -> Postgres / MinIO / Redis
```

## Flutter: one app, two data modes

```
Screens / Providers (shared)
        |
   Repository interface
     |- LocalFirst impl -> Drift + sync   (mobile, desktop)
     '- OnlineOnly impl  -> REST API only (web)
```
- Pick the implementation in `main.dart` with `kIsWeb` through Riverpod overrides.
- Web skips the pending-changes queue, sync coordinator and sync screen; writes go straight to the API and surface errors.
- Notifier interfaces stay the same so screens do not change.
- Avoid `dart:io` and plugins without web support (check connectivity, Hive replacement, file picker).
- Dashboard and lists on web use server-side pagination, filters and aggregates; never load everything and compute in the client.

## Key design rules

1. One `orders` table with a `channel` field (pos, admin, web).
2. Ledgers stay append-only. Keep a cached stock-per-variant value, updated in the same transaction as each ledger entry (the store needs fast available stock).
3. Postgres foreign keys and transactions replace delete guards and `groupId` batches; this closes the two known referential-integrity sync gaps.
4. Sync for mobile/desktop is "changes since X" using `updated_at` or a server sequence; replaces per-collection version metadata.
5. Permissions (admin / manager / staff) move from `firestore.rules` to API middleware/guards.
6. Staff users and store customers use separate auth flows.
7. Images: API issues presigned upload URLs; Postgres stores only the object key. Resize in a BullMQ job.
8. Separate subdomains for admin and store (clean cookies and CORS). Keep each app as its own container so it can be split to another server later.

## Build order

1. Postgres schema + Node API: auth, catalog, parties, purchases, sales, stock.
2. Flutter web admin (online-only) to prove the API.
3. Mobile and desktop on Drift with sync against the same API.
4. Next.js store: catalog, cart, checkout, payments.
5. Scale out only when needed.

## Migration notes

- Migrate in stages: schema, API, web admin, switch mobile/desktop, then move data from Firestore.
- Keep the business rules documented in CLAUDE.md (ledger-derived stock and balances, order confirm/cancel flows, stock audit, activity logs, role permissions) when designing tables and endpoints.

## Next step

Draft the Postgres schema from the current Flutter models in `lib/models`.
