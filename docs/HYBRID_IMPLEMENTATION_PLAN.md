# Hybrid Architecture Implementation Plan

This plan is intentionally incremental and protects the existing feature branch.

## Workstream A — Flutter baseline
- [ ] Preserve existing screens, Riverpod providers, GoRouter and Drift schema.
- [ ] Inventory repository boundaries and isolate platform-independent domain
      contracts.
- [ ] Add repeatable release-mode startup, search, editor and memory benchmarks.
- [ ] Keep FTS5 as the single full-text search index.

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
- [ ] Add Dart FFI loader with recoverable missing-library/version errors.
- [ ] Benchmark existing Dart/image library behavior first.
- [ ] Implement only a measured hotspot; define allocator ownership and limits.
- [ ] Add native unit tests and sanitizer-enabled CI where supported.

## Workstream D — Persistence and sync
- [ ] Keep Drift as the sole database owner during initial integration.
- [ ] Define a versioned repository DTO contract.
- [ ] Evaluate Rust database ownership as a separate migration proposal.
- [ ] Never permit Drift and Rust to independently write the same database.
- [ ] Design an outbox with idempotency keys and conflict preservation.
- [ ] Implement sync only after a real provider/backend and auth model exist.

## Workstream E — Release quality
- [ ] Android, iOS, Linux and macOS build matrix.
- [ ] Rust unit tests and C++ tests.
- [ ] FFI contract and ABI compatibility tests.
- [ ] Database migration, backup/restore and recovery tests.
- [ ] P50/P95/P99 and memory/CPU benchmark reports.
- [ ] Retain native debug symbols for crash diagnosis.

## Acceptance gate
No native subsystem is considered production-ready until it builds on each
claimed platform, has automated tests, has defined ownership/error semantics,
and demonstrates a measured benefit without regressions to existing features.
