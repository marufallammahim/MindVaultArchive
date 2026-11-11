#include "mindvault/native_engine.h"

#include <cstdlib>
#include <iostream>

int main() {
    if (mv_cpp_api_version() != 1U) {
        std::cerr << "Unexpected C++ ABI version\n";
        return EXIT_FAILURE;
    }
    if (mv_cpp_healthcheck() != 0) {
        std::cerr << "C++ health check failed\n";
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
