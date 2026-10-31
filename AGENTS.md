# AGENTS.md — Construction Material Rental Tracker

Guidance for AI coding agents (Codex) working in this repository. Read fully before making changes.

---

## 1. Product Summary

A mobile app (Flutter, Android first) for a shop that rents out construction materials (currently formwork **panels**, more types later).

**Core problem:** customers deny the rental date and the quantity they took. The app must create a **trustworthy, tamper-resistant digital record** of every rental: who, with what ID, what, how many, when, and what was returned and when.

**Core flows**
1. Register or find a customer (name, address, phone, **photo of National ID**).
2. Create a rental: one or more material lines (type + quantity), date/time, optional signature and notes.
3. When materials come back: mark returned (fully or partially), compute total price from days × price/day, show it.
4. Same customer returns later: reuse their stored info, create a **new, separate rental record**. Never overwrite old ones.

---

## 2. Guiding Principles

1. **Records are evidence.** Never hard-delete rentals, customers with rentals, or returns. Use soft-delete/void with reason, and write an audit log entry for every change.
2. **Price snapshot.** The price/day is copied onto each rental line at creation. Later price changes must NOT alter old rentals.
3. **Offline-first.** The shop may have poor connectivity. All features work offline with local storage. Cloud sync is an optional later phase.
4. **Money is integer.** Store amounts as integer minor units (e.g. cents/santim). Never use `double` for money.
5. **Time is UTC in storage**, displayed in local time. Rental day-count logic lives in one pure, unit-tested function.
6. **Simple UI for non-technical staff.** Big touch targets, few steps, clear confirmations, minimal typing.
7. **Privacy.** National ID photos are sensitive personal data. Protect them (see §8).

---

## 3. Tech Stack (do not substitute without asking)

| Concern | Choice |
|---|---|
| Framework | Flutter (stable), Dart null-safety |
| State management | Riverpod (`flutter_riverpod`, with `riverpod_generator` optional) |
| Local DB | Drift (SQLite) with migrations |
| Charts | `fl_chart` |
| Navigation | `go_router` |
| Models | `freezed` + `json_serializable` for domain/DTO models |
| Camera / images | `image_picker` (or `camera`), `image` / `flutter_image_compress` for compression |
| File paths | `path_provider` |
| Secure storage | `flutter_secure_storage` (DB/encryption keys, PIN hash) |
| App lock | `local_auth` + PIN fallback |
| Signature | `signature` package |
| Receipts / export | `pdf`, `printing`, `share_plus` |
| i18n / formatting | `flutter_localizations`, `intl` (English + Amharic, switchable in Settings) |
| Tests | `flutter_test`, `mocktail`, Drift in-memory DB |
| Lints | `flutter_lints` or `very_good_analysis` |

---

## 4. Architecture

Feature-first, layered (presentation → application → domain ← data).

```
lib/
  main.dart
  app/                    # app widget, router, theme, l10n
  core/
    database/             # Drift database, tables, migrations
    errors/               # Failure types, Result helpers
    utils/                # money, date, id generators
    widgets/              # shared UI components
    services/             # image storage, app lock
  features/
    customers/
      domain/             # entities, repository interfaces
      data/               # DAOs, repository impls
      application/        # providers/controllers
      presentation/       # screens, widgets
    materials/            # catalog: material types + price/day
    rentals/              # create rental, list, details
    returns/              # return flow, billing calculation
    billing/              # pure pricing logic (no Flutter imports)
    dashboard/            # analytics screens, metric providers (see §7A)
    reports/              # exports (CSV/PDF) of analytics data
    settings/             # language, security
test/                     # mirrors lib/
```

Rules:
- `domain` and `billing` have **no Flutter or Drift imports**.
- UI never talks to the DB directly; it goes through providers → repositories.
- Repositories return domain entities, not Drift row classes.
- Every feature gets unit tests for logic and at least one widget test for its main screen.

---

## 5. Data Model

All tables: `id` (UUID v4 string), `createdAt`, `updatedAt` (UTC). Soft-delete via `voidedAt` + `voidReason` where relevant.

**Customer**
- `fullName`, `phone`, `address`
- `idPhotoFront` (file path, required), `idPhotoBack` (optional file path)
- The ID is captured **as a photo only**; no ID number field in v1. Only `fullName` and `address` are typed.
- `notes`

**MaterialType** (catalog)
- `category` (e.g. "Panel")
- `name` / `variant` (e.g. "Panel 60x120", per client's types)
- `pricePerDay` (integer minor units)
- `totalStock` (optional, enables availability checks)
- `isActive`

**Rental** (one visit/contract; the thing that "comes back")
- `customerId`
- `rentedAt` (UTC datetime)
- `status`: `active | partiallyReturned | returned | voided`
- `notes`
- `customerSignature` (file path, optional)
- `handoverPhoto` (file path, optional)

**RentalItem** (line items)
- `rentalId`, `materialTypeId`
- `materialNameSnapshot`, `pricePerDaySnapshot`
- `quantity`, `quantityReturned`

**ReturnEvent** (supports partial returns)
- `rentalItemId` (or `rentalId` + lines), `quantity`, `returnedAt`, `conditionNote`
- Computed per event: `days`, `amount`

**Payment** (Phase 4)
- `rentalId`, `amount`, `paidAt`, `method`, `note`

**AuditLog**
- `entityType`, `entityId`, `action`, `oldValue` (JSON), `newValue` (JSON), `at`, `by`

Key requirement mapping: "reuse customer next time but different record" = one `Customer` → many `Rental`s. Creating a new rental pre-fills customer data and lets the user keep or re-capture the ID photo; the new rental has its own date, items, and status.

---

## 6. Billing Rules (pure function, heavily tested)

Confirmed with client:
- **Calendar-day counting.** Billable days = number of calendar dates from the rental date to the return date, **inclusive of the rental day**, minimum 1. (Rent and return on the same date = 1 day; rent on the 1st, return on the 3rd = 3 days.) Use local-date comparison (strip time), not 24-hour blocks.
- Currency is **ETB (Birr)**. Format amounts consistently (e.g. `1,250.00 ETB` / `ብር 1,250.00`).
- Line amount = `quantity × pricePerDaySnapshot × billableDays`.
- Partial returns are billed per return event for the returned quantity.
- Rental total = sum of all line amounts. **No late fees, damage or loss charges in scope.** Show the total clearly; show amount due after payments only once Payments exist (Phase 3).
- While a rental is active, show a **running estimate** ("if returned today").

Revenue reporting depends on these calculations being correct (see §7A definitions). Required unit tests: same-day return, midnight boundaries (23:59 vs 00:01 on consecutive dates), month/year rollovers, multi-day, partial returns across different dates, price change after rental creation, zero/negative quantity rejection, over-return rejection (cannot return more than outstanding).

---

## 7. Screens & UX

1. **Home:** big "New Rental" button, search, active rentals list, quick stats (active rentals, items currently out, this month's revenue). Tapping stats opens the full **Dashboard** (§7A).
2. **New Rental (stepper):** (1) pick or create customer → (2) capture ID photo (guide overlay, compress) → (3) add items (material type picker, quantity stepper) → (4) review + optional signature → (5) save and show/share receipt.
3. **Rental Details:** customer, items, outstanding quantities, timeline of events, actions: Return, Add payment, Share receipt, Void (with reason).
4. **Return Flow:** pick quantities returned per line (default: all), confirm → shows days, per-line cost, total, amount due.
5. **Customers:** searchable list, profile with full rental history.
6. **Materials Catalog:** add/edit types and price/day.
7. **Settings:** **language switch (Amharic / English)**, app lock, about. (Currency is fixed to ETB. Backup/restore is deferred.)

Validation: customer name and address required, ID photo required (with an explicit override + reason), quantity ≥ 1, availability check if stock tracked.

The app is **single-user** (one staff member, one device). No login or roles in v1.

---

## 7A. Dashboard & Analytics

Purpose: let the owner see how the business is doing at a glance. Read-only; computed from local data. Voided rentals are always excluded.

**Period filter** (applies to the whole dashboard): This month (default), Last month, Last 3 months, This year, Custom range.

**Metrics**
1. **Revenue per month:** bar chart of the last 12 months plus a month-vs-previous-month change. Includes a year selector.
2. **Average rental duration:** average days from rental date to the date of the final return, over completed rentals in the period. Also show trend per month. (Optional toggle: weighted by quantity.)
3. **Most rented materials:** ranked list/bar chart by *unit-days* (quantity × days) as default, with a toggle for *times rented* and *total quantity*.
4. **Currently out:** active rentals count, total units out per material type, and rentals running longer than a configurable threshold (default 14 days, set in Settings) highlighted as "long-running".
5. **Customers:** new vs returning customers in the period, top customers by revenue and by number of rentals.
6. **Outstanding estimate:** running estimated amount for rentals still active ("if returned today"), shown separately from earned revenue and clearly labelled as an estimate.
7. **Utilization** (only when stock tracking exists, Phase 3): units out ÷ total stock per material type.

**Definitions (must be consistent everywhere)**
- **Revenue (earned)** = sum of `ReturnEvent.amount` grouped by the *local month of `returnedAt`*. A partial return counts in the month it was returned. Active rentals contribute nothing until returned.
- **Collected** (Phase 3, once Payments exist) = sum of payments by `paidAt` month. Show beside earned revenue so the owner sees billed vs received.
- **Month grouping** uses the device's local timezone, not UTC (Ethiopia has no DST, but never hard-code the offset).
- All money is integer minor units, formatted as ETB. Dashboard labels are localized (Amharic/English).

**Implementation rules**
- Metrics live in `features/dashboard`; the aggregation logic is pure Dart functions (input: rentals/return events/items; output: metric models) with unit tests, even if some aggregation is pushed to Drift queries for speed.
- Expose metrics through Riverpod providers that recompute when underlying data changes.
- Provide empty-state UI (no data yet) and handle a single data point gracefully in charts.
- Charts must remain readable on small screens and in both languages; don't rely on color alone.
- Tests: revenue across partial returns in different months, month/year boundaries, voided exclusion, average duration with mixed single/partial returns, ranking ties, empty data.

---

## 8. Security & Privacy

- Store ID photos and signatures in the app's **private directory** (not gallery). Never save to shared storage.
- Encrypt the DB (e.g. `sqlcipher` via Drift's encrypted executor) and/or encrypt image files; keep the key in `flutter_secure_storage`.
- App lock with PIN/biometric on launch and after inactivity.
- No analytics or third-party SDKs that send personal data.
- Exclude sensitive screens from screenshots/recents where practical (`FLAG_SECURE`).
- Backup/restore is deferred; when added later it must be encrypted and password-protected.
- Do not log personal data or file contents.
- Note for the client: storing national ID images may be subject to local data-protection law; recommend a short consent statement on the receipt.

---

## 9. Roadmap (build in phases; do one phase at a time)

**Phase 0 — Foundation**
Scaffold project, lints, theme, router, **l10n setup with English and Amharic ARB files and a locale provider persisted locally**, Drift setup with migrations, Riverpod, folder structure, CI-style `flutter analyze` + `flutter test` passing. Seed demo data in debug builds only.

**Phase 1 — MVP core (the client's actual request)**
- Materials catalog with price/day.
- Customers (create, search, edit) with ID photo capture.
- Create rental with multiple items.
- Rental list + details.
- Mark returned (full), billing calculation and display.
- Customer reuse: new rental for existing customer.
- Simple Home stats (active rentals, items currently out, this month's revenue).
- Settings screen with **Amharic/English language switch** (all strings localized from day one; Amharic-capable font e.g. Noto Sans Ethiopic).
- ETB money formatting.
- Unit tests for billing.

**Phase 2 — Trust & evidence**
- Audit log, void-with-reason, no hard deletes.
- Customer signature capture, handover photo.
- PDF receipt (rental receipt + return receipt) with share (WhatsApp/Telegram/print).
- Partial returns.

**Phase 3 — Operations**
- Stock/availability tracking, overdue indicators and filters.
- Payments and outstanding balance per customer.
- **Full Dashboard (§7A):** revenue per month, average rental duration, most rented materials, currently out/long-running, customer insights, utilization, period filter.
- Collected vs earned revenue once Payments exist.
- CSV/PDF export of dashboard data.

**Phase 4 — Safety & polish**
- DB/image encryption, app lock (PIN/biometric).
- Accessibility, performance on low-end devices.
- (Deferred by client: backup/restore. Revisit when requested.)

**Phase 5 — Optional**
- Backup/restore, multi-device/multi-staff with cloud sync (Supabase/Firebase), roles, late fees/damage charges, deposits, ID number OCR (ML Kit), SMS/Telegram reminders.

Do not start a later phase until the current phase's acceptance checks pass.

---

## 10. Definition of Done (every task)

- `dart format .` clean, `flutter analyze` has zero warnings.
- Unit/widget tests added or updated and passing (`flutter test`).
- No hard-coded user-facing strings (use l10n) and no `double` money.
- Migration added when the schema changes (never edit old migrations).
- Audit log written for any state-changing rental/customer operation.
- Short note in `CHANGELOG.md` and any new decisions in `docs/decisions.md`.

---

## 11. Working Agreement for the Agent

- Make small, reviewable changes; one feature slice per task.
- Before large changes, state the plan briefly, then implement.
- Do not add dependencies outside §3 without asking.
- Do not invent business rules; if unclear, add an entry to `docs/open-questions.md` and use the default in this file.
- Never commit real customer data, ID images, keys, or secrets. Use fake data in tests and seeds.
- Prefer clear, boring code over clever abstractions.

---

## 12. Client Decisions & Open Questions

**Confirmed**
1. Day counting: calendar days, inclusive of rental day, minimum 1.
2. Single staff member, single device, local data only.
3. No late fees, damage or loss charges for now.
4. Currency ETB; languages Amharic and English, switchable from Settings.
5. National ID is captured as a **photo only**; customer name and address are typed.
6. Backup is deferred to a later phase.

**Still open (defaults assumed)**
- Customer on-screen signature: optional, Phase 2.
- Deposits: not in scope; Phase 5 if requested.
- Date display: Gregorian by default. Ask whether the client wants Ethiopian calendar display (switchable) later.
- Material type names/variants and prices: client supplies the list; seed through the Materials Catalog screen, not hard-coded.