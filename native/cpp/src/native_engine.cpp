#define MINDVAULT_CPP_BUILD
#include "mindvault/native_engine.h"

extern "C" MV_API uint32_t mv_cpp_api_version(void) {
    return 1U;
}

extern "C" MV_API int32_t mv_cpp_healthcheck(void) {
    return 0;
}
