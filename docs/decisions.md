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

