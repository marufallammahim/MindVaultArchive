//! Minimal C ABI bootstrap. Keep this surface small and versioned.

use mindvault_core::{CoreStatus, CORE_API_VERSION};

/// Returns the native API version. Safe to call without initializing services.
#[no_mangle]
pub extern "C" fn mindvault_native_api_version() -> u32 {
    CORE_API_VERSION
}

/// Returns a status probe; no database, filesystem or key material is touched.
#[no_mangle]
pub extern "C" fn mindvault_native_healthcheck() -> i32 {
    CoreStatus::Ok as i32
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn exported_probes_are_stable() {
        assert_eq!(mindvault_native_api_version(), 1);
        assert_eq!(mindvault_native_healthcheck(), 0);
    }
}
