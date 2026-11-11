# MindVaultArchive Hybrid Architecture

## Status
Architecture foundation on `feature/hybrid-native-architecture`.
This branch is based on `feature/ultimate-all-in-one-mindvault`; existing Flutter
features and database behavior are intentionally preserved.

## Target ownership
- Flutter/Dart: presentation, routing, Riverpod state, editor interaction,
  accessibility, localization and application orchestration.
- Rust: future security, cryptographic services, synchronization engine,
  data-integrity services and (only after a separately tested migration)
  authoritative database ownership.
- C++: opt-in computational acceleration for measured hotspots such as image
  transforms and specialized compression. It does not own rich-text layout or
  the existing FTS5 search index.
- SQLite/FTS5: existing persistence and full-text search remain authoritative
  during the first phases.

## Non-goals
- No immediate Drift-to-Rust database rewrite.
- No duplicate database writers.
- No custom text renderer.
- No claim of zero crashes.
- No remote sync until a backend, authentication and conflict policy exist.
- No encryption rollout until key lifecycle, recovery, backup compatibility
  and migration behavior are designed and tested.

## Integration sequence
1. Preserve and benchmark the current Flutter + Riverpod + Drift application.
2. Introduce Rust as an isolated native service with a versioned bridge.
3. Add C++ only for workloads where profiling demonstrates a material win.
4. Evaluate database ownership migration independently, with migration and
   rollback tests, before Rust becomes the sole writer.
5. Add an outbox-based sync protocol after local security is established.
6. Validate every supported target in CI and retain native crash symbols.

## Performance and reliability
Measure P50/P95/P99 latency, frame build/raster times, peak and steady-state
memory, CPU, battery, FFI overhead, query latency and crash-free sessions.
Profile release/profile builds on representative low-, mid- and high-tier
hardware. Native calls must validate inputs, bound allocations, define buffer
ownership and return structured errors. No C++ exception or Rust panic may
cross a C ABI boundary.

## Platform policy
Flutter remains the cross-platform UI. Native artifacts are built per target:
Android NDK ABIs, iOS device/simulator, Linux shared libraries and macOS
architectures. Platform enablement is separate from merely adding source
folders. Desktop support must be compiled and tested before being advertised.
