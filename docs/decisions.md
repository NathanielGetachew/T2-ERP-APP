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
- Navigation uses push for stacked feature screens; customer photo replacement keeps old files and audits every replacement. image_picker uses the system camera app, so no CAMERA permission is declared.
- Phase 1 Slice C locks the rental timestamp at save time, snapshots catalog prices on rental lines, and assigns sequential human-readable rental numbers through schema migration 2.
- Stock override confirmations are recorded in the rental audit payload. Billing uses an injected local offset and inclusive calendar-day counting.

# Phase 1 — Return flow and billing

- Return time is locked to the injected UTC Clock when the return is saved; staff cannot edit it.
- Each return event stores its calendar billable days, integer amount, and price/day snapshot.
- Earned revenue is the sum of return-event amounts grouped by the local month of `returnedAt`.
- Returns cannot be edited in this slice; a correction/void flow is planned for Phase 2.

# Phase 2 — Void and correction flows

- Voiding never deletes evidence; a trimmed reason of at least five characters is mandatory and the change is audited.
- Return events must be voided before their rental can be voided. Voiding a return restores its outstanding quantity and recalculates rental status.
- Voided returns and rentals are excluded from earned revenue, stock usage, estimates, and Home/list statistics, while remaining visible in history.
- Void and recreate creates a new rental record at the current time and keeps the original record voided.

# Phase 4-early — Encrypted backup and restore

- Backups use a versioned ZIP container with a manifest, a `VACUUM INTO` database snapshot, and all files under the single private-directory allowlist.
- The final container is encrypted with AES-256-GCM in authenticated 1 MiB chunks, with PBKDF2-HMAC-SHA256 using 210,000 iterations, a random salt, random nonces, and chunk-order/final-marker AAD.
- Restore is replace-not-merge. The current data receives an encrypted safety copy before the database and private photo directories are swapped.
- Passwords and key material are never persisted or written to audit logs. Backups are shared from temporary storage and the temporary file is removed afterward when possible.
- The Home reminder appears when no backup exists or the last backup is at least seven days old.
- UUID generation is unified into a single crypto-random RFC 4122 v4 generator in `core/utils/uuid.dart`, eliminating duplicated private implementations.

# Phase 3 — Dashboard and Analytics

- Metrics computation is pure Dart (`computeDashboardMetrics`) without Flutter or Drift dependencies, making all analytics 100% unit-testable with hand-computed arithmetic.
- Time grouping: All events and rental dates are stored in UTC and converted to the device's local timezone for day and month grouping. Ethiopia has no DST, but offsets are dynamically resolved without hard-coding.
- Revenue: Earned revenue is the sum of `ReturnEvent.amount` grouped by the local month of `returnedAt`. Voided rentals and voided returns are excluded. Active rentals contribute zero to earned revenue.
- Outstanding estimate: Running cost ("if returned today") of active rentals is computed from `rentedAt` to the current local date inclusive, and clearly labelled as an estimate.
- Average duration: Average calendar days from rental date to the date of the final return over completed rentals returned in the period.
- Material ranking: Ranked by unit-days (`quantity * days`) by default, with toggles for times rented and total quantity. Ties are broken alphabetically by name.
- Long-running threshold: Configurable between 1 and 365 days (default 14), editable from Settings, and persisted to app storage.
- Charting: Built with `fl_chart` using BarChart with responsive bar sizing, graceful zero/empty handling, ETB tooltips, and an accessible expandable monthly summary below the chart.

# Phase 2B — Partial returns UX and Customer-level return flow

- **Oldest-first default allocation**: When returning items across multiple rentals for a customer, units are allocated to the oldest open rental first (sorted by `rentedAt` ascending, then `rentalNumber` ascending). This matches customer/shop expectations and closes older open contracts earlier.
- **Independent line billing**: Each allocated return line is billed using its own rental's `rentedAt` (calendar days between that rental date and the return date) and its own `pricePerDaySnapshot`. This ensures that previous price snapshots and individual rental durations are preserved correctly.
- **Batch transaction with returnBatchId**: All return events created during a customer-level return share a single `returnBatchId` (UUID v4) and are saved in one atomic Drift transaction. If any line fails or exceeds outstanding, nothing is written. A batch-level audit log entry (`returnBatchRecorded`) references the batch ID, customer, grand total, and event count.
- **Returns allowed for archived customers**: An archived customer is never blocked from returning items. The shop must always be able to accept materials back and settle billing regardless of the customer's active/archived state.
- **Voiding remains per-event**: Voiding remains granular at the individual `ReturnEvent` level. A voided event preserves its `returnBatchId` and is shown muted/struck-through; voiding recalculates line outstanding and rental status.
- **Customer Held Items calculation**: Active rentals (both `active` and `partiallyReturned`) contribute their non-zero `outstandingQuantity` per material. Voided rentals and voided return events are strictly excluded.

# Release Signing & Manifest Configuration

- **`android:allowBackup="false"`**: Set in `AndroidManifest.xml` to prevent automatic Android OS cloud backups (Google Drive / ADB backups) from copying unencrypted SQLite databases and sensitive customer National ID photos to unencrypted third-party storage. T2 Rental provides its own user-controlled, password-protected AES-256-GCM encrypted backup mechanism.
- **Signed release configuration**: `android/app/build.gradle.kts` reads keystore credentials from `android/key.properties`. If `key.properties` is missing when attempting a release build, Gradle halts with an explicit error message to prevent accidental distribution of debug-signed APKs. Debug builds (`flutter run`) build without requiring `key.properties`.
- **R8 / Minification**: Follows Flutter's standard AOT compilation. Used plugins (`image_picker`, `file_picker`, `share_plus`, `drift/sqlite`, `archive`, `cryptography`) operate smoothly with Flutter's consumer proguard rules without extra keep rules since data access is fully typed and code-generated.


