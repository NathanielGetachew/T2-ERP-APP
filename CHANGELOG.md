# Changelog

# Phase 0 foundation

- Replaced the default counter app with the T2 Rental shell.
- Added localization, Riverpod, go_router, Drift, ETB formatting, and tests.
- Updated ETB formatting to use integer-only arithmetic and expanded money tests.
- Made the Home smoke test hermetic with Riverpod provider overrides and an in-memory database.

# Phase 1 — Materials Catalog

- Added the offline Materials Catalog with Drift persistence, active/inactive filtering, search, and add/edit forms.
- Added case-insensitive duplicate validation, UTC timestamps, UUID v4 IDs, and transactional audit logging.
- Added integer-only ETB input parsing and English/Amharic catalog localization.
- Renamed catalog model types to avoid a name clash with Flutter's `MaterialType` enum.
- Widget tests use fake repositories; real Drift only in plain unit tests (FakeAsync incompatibility).
- Added Phase 1 customer registration, private National ID photo storage/capture, duplicate warnings, profiles, archive/reactivate, and audit logging.
- Customer widget tests now use stable control keys, a tall viewport, and explicit visibility before taps.
- Added stack-safe navigation and independent, audited customer ID-photo replacement while preserving old photo files.
## Unreleased

- Added Phase 1 Slice C rental creation, rental list/details, rental numbering, stock warnings, and calendar-day billing.
- Fixed Slice C audit Value typing, stock-override exception coverage, billing estimate arithmetic, and editor form lints.
- Added Phase 1 return recording, return summaries, per-event billing, and earned monthly revenue.
- Fixed Slice D test import ambiguity, billing summary expectation, and Home smoke-test overflow.
- Added Phase 2 Slice A audited void and correction flows for returns and rentals, including v4 return-event void metadata and void-and-recreate navigation.
- Added the Phase 4-early encrypted backup and restore foundation with chunked AES-GCM, manifest checksums, safety copies, replacement restore, and backup reminders.
- Consolidated duplicate UUID v4 generators across repositories and services into a single shared helper in `core/utils/uuid.dart`.
- Updated PROJECT_STATUS.md progress table and AGENTS.md backup status.
- Added Phase 3 Dashboard slice with pure metrics calculation, Drift repository, and rich presentation:
  - Period filters: This month, Last month, Last 3 months, This year, and Custom date range picker.
  - Revenue per month BarChart using `fl_chart` with accessible monthly list, ETB tooltips, and month-over-month growth percentage badge.
  - Average rental duration for completed rentals in the period with 6-month historical trend.
  - Most rented materials ranked list with toggles for Unit-days (default), Times rented, and Total quantity, plus show-all expandable view.
  - Currently out card tracking active rentals, units out per material type, and long-running rentals flagged against a configurable threshold.
  - Configurable long-running threshold in Settings (default 14 days, validated 1-365 days, persisted to storage).
  - Customers insights tracking new vs returning customer counts and top customers by earned revenue and rental count.
  - Running outstanding estimate ("if returned today") clearly labelled as an estimate.
  - Added home quick stats tap navigation and Dashboard button.
  - Fixed Dashboard infinite loop ("keeps searching") caused by immediate Drift stream subscription emissions invalidating `dashboardMetricsProvider`; added `.skip(1)` on database change streams and converted to `StreamProvider.autoDispose`.
- Modernized complete app UI and layout across all core screens:
  - Theme: Rich executive palette (Deep Cyan `#0284C7`, Slate `#0F172A`, Amber `#D97706`), 16px radius cards with subtle borders, rounded input fields, chip styling, and modern button shapes.
  - Home: Hero gradient New Rental action card, interactive quick stats overview card, and balanced 2x2 grid navigation hub.
  - Rentals: Elevated cards with contract number pills, color-coded status badges (Active, Returned, Partial, Voided), calendar icons, and clear estimate/total amounts.
  - Customers: ID thumbnail previews, gradient initials avatars, phone and address badges, and archived indicators.
  - Materials: Catalog cards with category tags, pricing rate badges, inventory counts, and status chips.
  - Settings: Categorized sections, clean language switch segments, long-running threshold parameter card, and encrypted backup card.
  - Dashboard: Gradient chart styling, responsive metric cards, and clean period filter chips.
