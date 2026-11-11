cmake_minimum_required(VERSION 3.18)
project(mindvault_native_cpp LANGUAGES CXX)

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
