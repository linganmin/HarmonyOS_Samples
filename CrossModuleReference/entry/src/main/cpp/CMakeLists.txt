# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(CrossModuleReference)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED napi_init.cpp)

# [Start target_link_libraries_start]
# entry\src\main\cpp\CMakeLists.txt
target_link_libraries(entry PUBLIC libace_napi.z.so static_module::add shared_module::calc)
# [End target_link_libraries_start]