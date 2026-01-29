# Accountanter — Workflow Audit & Product Redesign (Alpha Plan)

This document defines the **intended “perfect” workflow** for Accountanter, and a staged plan to reach an **alpha that feels coherent, fast, and trustworthy**—without breaking the offline-first promise.

## Alpha v0.2.0+2 — What’s included (implemented)

- Invoice saving/updating is reliable (insert vs update handled correctly in [`createOrUpdateInvoice()`](lib/data/database.dart:256)).
- Inventory stock is adjusted transactionally for invoice line items via persisted [`inventoryItemId`](lib/data/tables/line_items.dart:9) (decrement on save, revert on edit).
- Invoice status filtering uses canonical statuses (not localized tab labels) via [`_statusFilters`](lib/features/invoices/invoices_screen.dart:20).
- Invoice editor avoids per-row streams for inventory selection (reduces UI jank) in [`InvoiceEditorScreen`](lib/features/invoices/invoice_editor_screen.dart:406).

---

## 1) Product concept (north star)

**Accountanter** is a local-first bookkeeping tool for small businesses that need:
- Fast client → invoice → payment tracking
- Simple expenses and inventory
- Clear “what do I do next?” guidance
- English + Arabic (RTL) parity
- Zero cloud dependency by default

**Design pillars**
1. **Trust**: totals are correct, status is correct, destructive actions are safe.
2. **Speed**: common actions are 1–2 clicks, UI stays responsive.
3. **Clarity**: the app always tells the user where money is coming from / going to.
4. **Offline correctness**: DB integrity rules prevent invalid states.

---

## 2) Workflow audit (current state: what’s missing)

### A) Sales workflow gaps
- **Invoice lifecycle is not consistently surfaced**: “Draft / Pending / Paid / Overdue” needs a canonical internal representation and localized labels. (Filter logic & labels were previously coupled to translated tab labels; see [`_filterInvoices()`](lib/features/invoices/invoices_screen.dart:114).)
- **Inventory movement is not modeled**: invoice line items can reference inventory in the UI, but without a persisted link you can’t reliably decrement/revert stock on invoice create/edit/delete.

### B) Performance “sluggish” feel (likely causes)
- Rebuilding heavy widgets because of nested builders and per-row streams.
- Avoidable repeated queries (e.g., fetching client list repeatedly).
- Large `build()` trees doing work per keystroke without throttling.

A concrete example was repeated fetch patterns in the invoice editor, where client list loading and inventory selection were handled in ways that can trigger unnecessary rebuilds (see [`InvoiceEditorScreen`](lib/features/invoices/invoice_editor_screen.dart:232)).

### C) UX coherence gaps
- Some screens feel like “admin tables”, others feel like “cards”; needs a more consistent hierarchy: **header → summary → filters → list/table → action**.
- Empty states need consistent “what next?” guidance.
- A “first-run setup” path is needed: company profile + currency + default tax + demo toggle.

---

## 3) Proposed information architecture (navigation redesign)

Keep the left sidebar, but reorganize pages by real workflows:

### Primary sections
1. **Dashboard**: KPIs + “action required” + recent activity.
2. **Sales**
   - Invoices
   - Clients
   - Payments (or “Receipts”)
3. **Purchases**
   - Expenses
   - Vendors (optional later)
4. **Inventory**
5. **Reports**
6. **Documents**
7. **Settings**
8. **Help**

This improves discoverability: users naturally think “Sales vs Purchases”.

---

## 4) Redesigned workflows (target UX)

### 4.1 Onboarding / first run
**Goal:** user can create their first invoice in under 2 minutes.
1. Activation gate (keep).
2. Setup wizard (first-run only):
   - Company name + address
   - Currency symbol
   - Default tax rate
   - “Enable demo data?” toggle
3. Land on Dashboard with 3 clear next actions.

### 4.2 Clients
**Job:** “I need a client, so I can invoice them.”
- Add client form defaults (type, opening balance optional).
- Client page shows:
  - outstanding balance
  - last invoice date
  - quick buttons: “New invoice”, “Record payment”
- Deleting a client must be blocked or confirmed if they have invoices/payments.

### 4.3 Invoices (core workflow)
**Job:** “Create an invoice, mark it paid later, and always know what’s outstanding.”

#### Invoice creation UX
- Step A: Choose client (required)
- Step B: Add line items
  - Either “free text” item or “inventory item”
  - If inventory item selected: auto-fill description and unit price
  - Quantity validation: prevent negative/zero; prevent stock underflow if inventory-linked
- Step C: Totals section (always visible)
  - subtotal, discount, tax, total
- Step D: Save actions
  - Save Draft
  - Save Pending (sent)
  - (Later) Mark as Paid / Record Payment

#### Invoice listing UX
- Tabs: All / Draft / Pending / Overdue / Paid
- Search: invoice number + client
- Table rows open the invoice (edit/view)

**Canonical status rule**
- Internal persisted status remains one of: `Draft`, `Pending`, `Overdue`, `Paid`
- UI shows localized label, but filtering uses canonical values (see the approach in [`_statusFilters`](lib/features/invoices/invoices_screen.dart:20) and the mapping used by [`_buildStatusChip()`](lib/features/invoices/invoices_screen.dart:281)).

### 4.4 Payments
**Job:** “I received money for invoice X.”
- Record payment:
  - invoice selector
  - date
  - amount
  - method
  - reference (optional)
- Invoice status auto-updates:
  - paidAmount == total → Paid
  - paidAmount > 0 and previously Draft → Pending
  - paidAmount < total and previously Paid → Pending

This behavior should be consistent and predictable (logic currently lives in [`_recalculateInvoicePaymentStatus()`](lib/data/database.dart:344)).

### 4.5 Inventory (stock correctness)
**Job:** “If I sell items, stock goes down. If I edit/delete invoice, stock is corrected.”

#### Inventory movement rule
- When an invoice line references an inventory item, saving the invoice creates a stock movement:
  - decrement by quantity for new/updated lines
  - revert previous movements when editing an existing invoice
- Stock cannot go negative; block save with a clear error.

This requires:
- Persisted linkage between invoice line and inventory item
- Transactional update behavior (DB-level)

The DB write path is the single source of truth (see [`createOrUpdateInvoice()`](lib/data/database.dart:256)).

### 4.6 Expenses
**Job:** “Record business spending and keep it searchable.”
- Expense editor: vendor, category, date, amount, receipt/reference, notes
- Later: attach document/receipt

### 4.7 Reports
**Job:** “What happened this month/year?”
- 12-month charts and summaries
- Exports (CSV already exists; later PDF)

---

## 5) Data integrity rules (offline-first correctness)

1. **Invoice totals must match line items** (serverless means we must trust local math).
2. **Stock can’t go negative** for inventory-linked invoice lines.
3. **Deleting invoice/payments must leave DB consistent** (cascade or explicit transaction).
4. **Demo mode must never leak into real usage**:
   - demo seeding must be idempotent and removable, or isolated to a separate “demo” DB.

---

## 6) Alpha definition (what “ready for user test” means)

### Alpha acceptance criteria (must-have)
- Create invoice → it appears immediately in invoice list.
- Editing invoice does not duplicate / corrupt line items.
- If invoice line uses inventory item:
  - stock decrements on save
  - stock reverts on edit/delete
  - save blocked if insufficient stock
- App feels responsive:
  - no obvious UI hangs in invoice editor typing
  - lists and tables do not rebuild excessively
- English + Arabic:
  - no broken RTL layout
  - no untranslated core labels in “Sales / Invoices / Create invoice” flow

### Alpha scope boundary (not required yet)
- PDF generation
- Cloud sync
- Complex tax rules per-line
- Multi-currency

---

## 7) Recommended staged roadmap (small, compounding releases)

### v0.2.0 (Alpha) — “Core Sales & Stock Correctness”
- Canonical invoice status filtering + localized labels
- Stock movement on invoice save/edit/delete
- Invoice editor performance fixes (cache client list, reuse inventory stream)
- Fix top 10 hard-coded strings in critical flows (auth + invoices + taxes)

### v0.3.0 — “Purchases & Documents”
- Receipt/document attachments with safe path handling
- Expense filters + export parity
- Vendor/category UX improvements

### v0.4.0 — “Reports & Backups”
- Backup/export DB (zip) + restore flow
- Monthly reports improvements
- Printing/PDF (if needed)

---

## 8) Notes on implementation approach (to keep stability)

- Treat DB methods as the “business rules boundary”, not UI widgets.
- Keep canonical values in DB, localize only at the view layer.
- Prefer one query/stream per screen (avoid per-row streams).
- Always verify with `flutter analyze` and `flutter test` before tagging an alpha release (see [`docs/release_guide.md`](docs/release_guide.md:1)).
