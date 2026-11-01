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
