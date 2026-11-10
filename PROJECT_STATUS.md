# PROJECT_STATUS.md — T2 Rental (handoff for coding agents)

Read this together with `AGENTS.md` (product rules, architecture, billing rules, roadmap). Where this file and AGENTS.md conflict, THIS file reflects the current reality; tell the owner about the conflict.

---

## 1. Project in one paragraph

**T2 Rental** is an offline-first Android app (Flutter) for one shop that rents construction materials (formwork panels now; more types later). Customers deny rental dates/quantities, so the app keeps tamper-resistant evidence: customer name + address + **photo of the National ID**, rental date/time (locked to "now"), materials and quantities, returns, and a price-per-day billing calculation shown when materials come back. Single staff member, single device, no login. Currency ETB. Languages: English and Amharic (switchable in Settings).

Owner/developer: Yonas Tigistu. Dart package `t2_rental`, Android id `com.yonastigistu.t2_rental`, app label "T2 Rental".

## 2. Environment (important)

- Windows 11, **PowerShell 5** (no `&&`; run commands one per line; never paste the `PS C:\...>` prompt).
- Project path has a space: `C:\Users\HCS\DEV\T2 ERP`.
- Flutter SDK at `C:\src\flutter` (3.47.7 stable, Dart 3.13.5). Android SDK 36. Android `minSdk` 24.
- Test device: owner's physical phone (data from earlier schema versions lives there; ALWAYS install over it, never uninstall, so migrations are tested on real data) and an emulator "Medium_Phone_API_36.1".
- Commands:
  ```powershell
  flutter pub get
  dart run build_runner build
  flutter gen-l10n
  dart format .
  flutter analyze                    # must be clean before running tests
  flutter test --timeout 60s
  ```
- Git: one commit per finished slice, message format `Phase X: description`. LF→CRLF warnings are harmless.

## 3. Tech stack (do not substitute without asking)

Flutter + Dart, Riverpod (`flutter_riverpod` 2.x), `go_router`, Drift (SQLite) + `drift_flutter`, `freezed`/`json_serializable`, `intl` + `flutter_localizations`, `image_picker` (system camera app, so NO camera permission in the manifest by design), `path_provider`, `fl_chart`, `mocktail`. Bundled font Noto Sans Ethiopic (`assets/fonts/NotoSansEthiopic-Regular.ttf`). Backup slice adds: `archive`, `cryptography`, `share_plus`, `file_picker`.

## 4. Architecture and naming (follow exactly)

Feature-first layers: `lib/features/<feature>/{domain,data,application,presentation}`, shared code in `lib/core/{database,services,utils,widgets,errors}`, app shell in `lib/app/`. Domain and billing code import no Flutter/Drift. UI never touches the DB directly (screen → provider → repository interface → Drift implementation).

**Name-clash rules learned the hard way:**
- Domain entity for materials is `RentalMaterial` (NOT `MaterialType`, which clashes with Flutter). Drift row classes use `@DataClassName`: `MaterialRow`, `CustomerRow`, `RentalRow`, `RentalItemRow`, etc.
- Never name a Notifier method `update` or anything shadowing Riverpod members (`updateMaterial` is used).
- In test files, `isNotNull`/`isNull` clash between drift and matcher: `hide`/alias drift imports.

**Fakes for UI tests:** `test/helpers/` has `FakeMaterialRepository`, `FakeCustomerRepository`, `FakeRentalRepository`, `FakeBackupService`, fake image services, fake Clock. Widget tests must use these. Real Drift inside `testWidgets` HANGS under FakeAsync; real in-memory Drift is only for plain `test()` (close DB in tearDown).

**Money:** integer minor units everywhere (1 ETB = 100). Never `double`. Formatter in `core/utils/money.dart`, parser in `core/utils/money_parser.dart`.

**Time:** timestamps stored UTC; displayed local. `Clock` abstraction (`core/utils/clock*.dart`) with a Riverpod provider; tests use a fake clock.

## 5. Business rules implemented (do not change without the owner's approval)

- **Billing:** calendar days, inclusive of the rental day, minimum 1 (rent and return the same date = 1 day; 1st→3rd = 3 days). Line amount = quantity × pricePerDay **snapshot** × days. Pure function in `features/billing/rental_billing.dart`. Hand-check examples: 10 × 25.00 ETB × 3 days = 750.00 ETB; partial 4 units on day 2 + 6 units on day 5 = 200 + 750 = 950.00 ETB.
- **Price snapshot:** each rental line copies name and price/day at creation; later catalog changes never alter old rentals.
- **Rental time is locked to now** (not editable). Return time is locked to now.
- **Rental numbers:** sequential, displayed `R-0001`.
- **Records are evidence:** nothing is hard-deleted. Archive customers/materials; **void** rentals/returns with a mandatory reason (≥5 chars); everything writes `AuditLog` rows (JSON old/new values) in the same transaction.
- **ID photos:** private app directory, relative paths in the DB, **old photos are never deleted** when replaced (audit logs old+new path). Front photo required for new customers; back optional.
- **Archived customers cannot get new rentals.** Duplicate customer detection warns but does not block.
- **Stock check:** if a material has `totalStock`, exceeding available shows a warning; staff may confirm (recorded in the audit log as `stockOverrideConfirmed`).
- **Revenue (earned)** = sum of return amounts grouped by the LOCAL month of `returnedAt`, excluding voided data.
- **Voiding:** voiding a return restores outstanding quantities and recomputes status; a rental can be voided only after all its returns are voided; "Void and recreate" opens a prefilled new rental (new number, new time).
- **Customer-level returns:** customers holding items across multiple open rentals can return items in a single customer-level flow. Quantities are allocated to the oldest open rental first (by `rentedAt`, then rental number) by default; staff can adjust allocations manually. Each line uses its own snapshot price and rental duration. All events share a `returnBatchId` and are committed atomically with per-rental and batch-level audit logs. Archived customers can return items.
- Not in scope for the client: late fees, damage/loss charges, deposits, multi-user, cloud sync.

## 6. Progress

Schema history (Drift `schemaVersion`): v1 base tables → v2 adds `Rentals.rentalNumber` (backfilled) → v3 `ReturnEvents` gets `rentalId`, `pricePerDaySnapshot`, `days`→`billableDays` → v4 (Phase 2A) void columns on `ReturnEvents` → v5 (Phase 2B) adds `return_batch_id` (nullable text) on `ReturnEvents`. Check `lib/core/database/database.dart` for the real current version and never edit earlier migration steps.

| Slice | Status |
|---|---|
| Phase 0: scaffold, l10n (en/am), Drift schema, router, theme, money formatter | Done, committed |
| 1A: Materials catalog (add/edit/deactivate, ETB prices, audit) | Done, committed |
| 1B: Customers + private ID photo capture, duplicate warning, photo viewer, independent photo replacement, back navigation | Done, committed |
| 1C: Create rental (customer picker, lines, price snapshot, stock warning), rental list/details, billing calculator, rental numbers (schema v2) | Done, committed |
| 1D: Returns (full/partial), return summary, per-event days/amount, status transitions, Home "this month's revenue" (schema v3) | Done, committed, device-tested |
| 2A: Void return / void rental with reason, void-and-recreate, audit history on rental details, voided filter | Done, committed, device-tested |
| Encrypted Backup & Restore (zip of `VACUUM INTO` DB snapshot + private photos + manifest/SHA-256, AES-256-GCM chunked, password-derived key, share sheet, restore with safety copy and RESTORE confirmation, Home reminder banner if no backup within 7 days) | Done, committed |
| **Phase 3: Dashboard & Analytics** (revenue per month chart `fl_chart`, average rental duration + 6-month trend, most rented materials ranking, currently out / long-running with configurable Settings threshold, customer insights, outstanding estimate, period filter, Home entry, full English/Amharic localization) | Done, committed |
| **Phase 2B: Partial Returns UX & Customer-level Return Flow** (Rented/Returned/Still-out line indicators, Partial badge, steppers/typing on return screen, customer profile "Items currently held" with return action, Home "Return materials" shortcut, customer picker, customer-level return screen with oldest-first allocation and manual adjustment, atomic batch transaction with `returnBatchId` [schema v5], batch summary receipt screen, full tests and localization) | Done, verified with hand-computed arithmetic tests |
| **Release APK & Signing Configuration** (Release signing config reading `android/key.properties`, example properties file, `.gitignore` keystore protections, `android:allowBackup="false"` in manifest, loud failure when missing keystore for release while keeping debug builds working, `docs/release.md` guide) | Done, verified |

## 7. Remaining roadmap (in order the owner agreed)

1. **Dashboard** (AGENTS.md §7A): revenue per month chart (`fl_chart`), average rental duration, most rented materials (unit-days default), currently out / long-running (default 14 days, configurable), top customers, new vs returning, outstanding estimate, period filter; pure-Dart aggregation with hand-verified tests.
2. **Payments and outstanding balance** (collected vs earned), stock/overdue indicators.
3. **Security:** app lock (PIN/biometric), encrypted DB and photos at rest, hide from recents.
4. Deferred by the owner: Phase 2B receipts (PDF + share) and 2C customer signature on screen.
5. Later/optional: Ethiopian calendar display, cloud sync, OCR.
