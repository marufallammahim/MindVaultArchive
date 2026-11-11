//! Domain primitives for the MindVaultArchive native core.
//!
//! This crate intentionally contains no database or cryptographic implementation
//! yet. Those capabilities require reviewed designs and migration tests.

/// Version of the native domain contract.
pub const CORE_API_VERSION: u32 = 1;

/// Stable, language-neutral status values used at native boundaries.
#[repr(i32)]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CoreStatus {
    Ok = 0,
    InvalidArgument = 1,
    NotImplemented = 2,
    InternalError = 3,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn api_version_is_nonzero() {
        assert_eq!(CORE_API_VERSION, 1);
    }

    #[test]
    fn status_codes_are_stable() {
        assert_eq!(CoreStatus::Ok as i32, 0);
        assert_eq!(CoreStatus::NotImplemented as i32, 2);
    }
}
