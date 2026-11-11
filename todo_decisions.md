# Open decisions

Issues the owner chose to leave open for now. Each one names what the code does today, so a later decision can change it deliberately. Nothing here is a bug the code hides: the current behaviour is intentional until a decision is made.

## 1. Overselling across devices (Sales)
**Today:** an order checks stock against the stock ledger on *this device* only. Stock is a sum of ledger entries, and sync is manual, so two devices that each sell the last unit before syncing both succeed. After both sync the variant's stock is negative.
**What exists:** the Stock screen marks negative stock (warning icon on the row and a banner above the list). Nothing else is done: no blocking, no automatic correction.
**To decide later:** accept it as is, force a sync before confirming a sale, or add a server-side check at upload time (hard, because stock is a sum and not a stored number). Also how corrections should be made (a stock adjustment module does not exist yet; `StockMovementType.adjustment` has no producer).

## 2. Cancelling an order and the customer ledger (Sales)
**Today:** the ledger only has `charge` and `payment`. Cancelling an order posts the reversal of its charge as a customer ledger **payment** with the order's `orderId` and the description "Cancelled order ORD-…", the same way vendor purchases record payments. Stock goes back through positive `sale` entries.
**Side effects to be aware of:**
- The reversal shows up as "Payment received" in the customer's ledger and in the order's payment list.
- Money the customer already paid stays on the ledger as credit ("Advance received"). There is no refund flow.
- A cancelled order's paid total includes the reversal, so the screens hide payment progress for cancelled orders.
**To decide later:** a real `reversal`/`adjustment` entry type (old app versions would read an unknown `entryType` as `charge`, so this needs a compatibility plan), and a refund flow.

## 3. Two users changing the same order at once (Sales)
**Today:** an order is edited only by status changes. When two devices change the same order before syncing, the newer `updatedAt` wins (the normal `applyRemote` policy) and the other change is dropped.
**Risky case:** one user cancels (stock returned, ledger reversed) while another marks the order Shipped or Delivered. If the other change is newer, the order ends up shipped/delivered while its stock and ledger reversal entries from the cancel still exist.
**To decide later:** a rule that a cancelled order can never be overwritten by a later status change (for example an upload/merge check like the proposed `uploadBlockReason` hook), or keeping the status history as an append-only list that merges.

## 4. A stock count is a snapshot (Stock Audit)
**Today:** confirming an audit measures each counted variant against the stock ledger *on this device* at that moment, and posts the difference as an `adjustment` entry. Entries are deltas, so if another device sells or receives that variant after the count but before sync, its entry still applies on top of the adjustment and the final number differs from what was physically counted (same root cause as decision 1).
**What exists:** every audit is saved with the system and counted quantities, who counted, and the adjustment entries point to it (`sourceId`), so a discrepancy can be traced. Nothing blocks or warns about concurrent movements.
**To decide later:** require a fresh sync before an audit can be applied, show the sync state on the audit screen, or let a later audit simply correct the difference (what happens today).

## 5. Dashboard figures follow the local copy (Dashboard)
**Today:** sales, stock value, pending orders and top sellers are calculated from this device's data. They include unsynced local work and exclude other devices' work until the next sync. Stock is valued at the *catalog* cost and sale price (not what each purchase actually cost), only positive stock counts, and the top-sellers revenue is the sum of line totals (order-level discounts are not spread over products).
**To decide later:** show "as of last sync" on the dashboard, value stock at average purchase cost, or spread order discounts over lines for top-seller revenue.

## 6. Activity logs: limits to be aware of (Logs)
**Today:** logs are written locally at once, uploaded on every sync (also after a failed sync) to the append-only `activity_logs` collection, and read by admins only. Things that are deliberately simple:
- **Best effort.** A log that cannot be written (for example a full disk) is silently lost; logging never blocks or fails the action.
- **Other devices' logs appear after they sync.** The screen shows this device's logs plus the latest 500 from the cloud after "Load from cloud" (500 reads per press). There is no paging beyond 500 and no server-side filtering.
- **The `userId` in a log is claimed by the device.** The rules require an active user and block edits/deletes, but do not check that `userId` is the uploader (a device may upload logs written by a user who used it before). A modified client could forge a log.
- **Failed sign-in attempts are not logged** (nobody is signed in, so there is nobody to upload them).
- **Cloud logs are kept forever.** Only uploaded logs older than 90 days are removed from the device. Cloud cost grows with usage (one write per log), and there is no cloud cleanup job.
- **History starts with this release.** Earlier actions have no logs. Changes made by older app versions on other devices are not logged.
- Many logs per action are normal: an order writes the order, its stock entries and its ledger entries (linked by one group id) plus a readable "order confirmed" entry.
**To decide later:** a retention/cleanup policy for the cloud, stronger rules (uploader checks), paging or export for the cloud view, and whether failed sign-ins should be recorded.

## 7. Known sync gaps (see the Referential integrity section of CLAUDE.md)
Gap 1 (cross-collection delete versions) and Gap 2 (pending creates are not re-validated against a parent deleted in the cloud) are still open. For Sales, Gap 2 means an unsynced order for a customer that someone else deleted could still upload. Customers with ledger entries cannot be deleted, and customers with orders are blocked locally, so this needs a customer with no ledger entries and no orders on the deleting device.
