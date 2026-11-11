#ifndef MINDVAULT_NATIVE_ENGINE_H
#define MINDVAULT_NATIVE_ENGINE_H

#include <stdint.h>

#if defined(_WIN32)
  #if defined(MINDVAULT_CPP_BUILD)
    #define MV_API __declspec(dllexport)
  #else
    #define MV_API __declspec(dllimport)
  #endif
#else
  #define MV_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

/// Returns the C++ module ABI version.
MV_API uint32_t mv_cpp_api_version(void);

/// Health probe. Does not allocate memory or process user data.
MV_API int32_t mv_cpp_healthcheck(void);

#ifdef __cplusplus
}
#endif

#endif
