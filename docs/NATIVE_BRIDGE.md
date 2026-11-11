# Native Bridge Contract

## Rust
Use flutter_rust_bridge for generated, typed Dart APIs once the Rust service
surface is ready. Keep domain APIs asynchronous and coarse-grained. Prefer
typed domain errors over stringly typed failures. Do not expose database
connection handles or Rust-owned pointers to Dart.

## C++
Use Dart `dart:ffi` against a narrow C ABI. Export fixed-width scalar types,
opaque handles only where necessary, explicit allocation/free functions and
an ABI version. Never expose C++ classes, STL containers, exceptions or
compiler-specific layouts.

## Shared rules
- UI isolate must never perform long-running synchronous native work.
- Batch operations to reduce bridge crossings and copying.
- Validate all lengths, pointers, dimensions and enum values.
- Define allocator and buffer ownership at every boundary.
- Treat native library loading and version mismatch as recoverable errors.
- Cancellation and shutdown must be explicit.
- No panic/exception unwinding across FFI.
- Keep bridge DTOs independent of database implementation details.

## Current implementation status
The first native scaffold exports version/status probes only. No note content,
keys, database records or attachment bytes cross the bridge yet. Production
cryptography, compression and database APIs are deliberately not stubbed as
if they were implemented.
