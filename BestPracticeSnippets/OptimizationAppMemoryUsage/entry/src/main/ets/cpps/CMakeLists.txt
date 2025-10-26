# [Start link_version]
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(MyNativeApplication)
set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)
add_library(entry SHARED napi_init.cpp)
# Introduce libpurgeable_memory_ndk.z.so dynamic link library.
target_link_libraries(entry PUBLIC libace_napi.z.so libpurgeable_memory_ndk.z.so)
# [End link_version]