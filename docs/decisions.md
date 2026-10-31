# Decisions

# Phase 0 foundation

- The existing `t2_rental` Flutter project and Android application ID are preserved.
- Locale selection is persisted as a small file in the app-private documents directory using `path_provider`, avoiding an additional dependency.
- Drift uses schema version 1 with an explicit migration strategy; tests use `NativeDatabase.memory()`.
- `NotoSansEthiopic-Regular.ttf` is configured at `assets/fonts/NotoSansEthiopic-Regular.ttf`; it was not available offline and must be supplied before a device build.
- ETB formatting separates Birr and santim with integer quotient/remainder arithmetic, avoiding floating-point money calculations.

# Phase 1 — Materials Catalog

- The existing `MaterialTypes` and `AuditLogs` Drift tables satisfy the catalog slice, so schema version 1 is unchanged.
- Material category/name uniqueness is enforced case-insensitively in the repository, including inactive materials.
- Material changes are audited in the same Drift transaction; deactivation is represented by `isActive = false` and never deletes data.
- The catalog form uses string/integer parsing for ETB minor units and does not use floating-point money values.
- The domain catalog entity is named `RentalMaterial`, and the Drift row is named `MaterialRow`, to avoid clashes with Flutter's `MaterialType` enum.
- Widget tests use fake repositories; real Drift only in plain unit tests (FakeAsync incompatibility).
- Customers derive `isActive` from the existing `voidedAt` column, so the Customer schema remains unchanged; ID photos use relative paths in the private documents directory and are never deleted.
- Customer photo replacements write a separate audit entry containing the old and new file paths.
