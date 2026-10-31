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
