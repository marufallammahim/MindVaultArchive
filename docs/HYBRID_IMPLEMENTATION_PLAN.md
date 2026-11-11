# Hybrid Architecture Implementation Plan

This plan is intentionally incremental and protects the existing application.
The current branch is `feature/hybrid-native-architecture`, based on
`feature/ultimate-all-in-one-mindvault`; the source branch is not modified.

## Workstream A — Flutter baseline
- [x] Preserve existing screens, Riverpod providers, GoRouter and Drift schema.
- [ ] Inventory repository boundaries and isolate platform-independent domain
      contracts.
- [ ] Add repeatable release-mode startup, search, editor and memory benchmarks.
- [x] Keep FTS5 as the single full-text search index.
- [x] Verify Dart formatting, static analysis, Flutter regression tests and
      Android debug APK generation in GitHub Actions.

## Workstream B — Rust foundation
- [x] Add Cargo workspace and separate core/FFI crates.
- [x] Add stable API-version and health probes.
- [ ] Select and pin flutter_rust_bridge version compatible with project toolchains.
- [ ] Generate Dart bindings and add native build integration per platform.
- [ ] Add structured errors, cancellation and panic containment.
- [ ] Design key lifecycle before adding cryptographic dependencies.
- [ ] Implement and test authenticated encryption and encrypted attachments.

## Workstream C — C++ foundation
- [x] Add CMake library and narrow C ABI probes.
- [x] Add a C ABI contract executable and run it through CTest in CI.
- [ ] Add Dart FFI loader with recoverable missing-library/version errors.
- [ ] Benchmark existing Dart/image library behavior first.
- [ ] Implement only a measured hotspot; define allocator ownership and limits.
- [ ] Add sanitizer-enabled CI where supported.

## Workstream D — Persistence and sync
- [x] Keep Drift as the sole database owner during initial integration.
- [ ] Define a versioned repository DTO contract.
- [ ] Evaluate Rust database ownership as a separate migration proposal.
- [x] Prohibit independent Drift and Rust writers during the initial phase.
- [ ] Design an outbox with idempotency keys and conflict preservation.
- [ ] Implement sync only after a real provider/backend and auth model exist.

## Workstream E — Release quality
- [ ] Android, iOS, Linux and macOS build matrix.
- [x] Rust unit tests, Clippy and C++ ABI contract test on Linux CI.
- [ ] FFI contract and ABI compatibility tests across supported targets.
- [ ] Database migration, backup/restore and recovery tests on device.
- [ ] P50/P95/P99 and memory/CPU benchmark reports.
- [ ] Retain native debug symbols for crash diagnosis.

## Verified CI baseline

The following all passed on commit
`531e36e63de9f8779c013cc6f064d2f07f8d8e59`:
- Flutter static analysis: no issues found.
- Flutter regression tests: 47 tests passed.
- Rust workspace: 3 unit tests passed; formatting and Clippy passed.
- C++ shared library: Release build passed.
- Android debug APK: built and uploaded as a GitHub Actions artifact.

The later C++ ABI contract test is a new change and must pass CI before it is
considered complete. A successful Linux probe build does not establish
production Flutter/native integration or cross-platform readiness.

## Acceptance gate

No native subsystem is considered production-ready until it builds on each
claimed platform, has automated tests, has defined ownership/error semantics,
and demonstrates a measured benefit without regressions to existing features.
