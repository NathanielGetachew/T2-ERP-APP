# Decisions
# Phase 0 foundation

- The existing `t2_rental` Flutter project and Android application ID are preserved.
- Locale selection is persisted as a small file in the app-private documents directory using `path_provider`, avoiding an additional dependency.
- Drift uses schema version 1 with an explicit migration strategy; tests use `NativeDatabase.memory()`.
- `NotoSansEthiopic-Regular.ttf` is configured at `assets/fonts/NotoSansEthiopic-Regular.ttf`; it was not available offline and must be supplied before a device build.
- ETB formatting separates Birr and santim with integer quotient/remainder arithmetic, avoiding floating-point money calculations.
