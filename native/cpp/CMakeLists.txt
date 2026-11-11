cmake_minimum_required(VERSION 3.18)
project(mindvault_native_cpp LANGUAGES CXX)

include(CTest)

add_library(mindvault_cpp SHARED src/native_engine.cpp)
target_include_directories(mindvault_cpp PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_compile_features(mindvault_cpp PUBLIC cxx_std_17)
set_target_properties(mindvault_cpp PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES
)

if(MSVC)
    target_compile_options(mindvault_cpp PRIVATE /W4 /WX)
else()
    target_compile_options(mindvault_cpp PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()

if(BUILD_TESTING)
    add_executable(mindvault_cpp_abi_test tests/native_engine_test.cpp)
    target_link_libraries(mindvault_cpp_abi_test PRIVATE mindvault_cpp)
    target_compile_features(mindvault_cpp_abi_test PRIVATE cxx_std_17)
    if(MSVC)
        target_compile_options(mindvault_cpp_abi_test PRIVATE /W4 /WX)
    else()
        target_compile_options(mindvault_cpp_abi_test PRIVATE -Wall -Wextra -Wpedantic -Werror)
    endif()
    add_test(NAME mindvault_cpp_abi_contract COMMAND mindvault_cpp_abi_test)
endif()
