# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(NativeSoIntegration)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(multiply SHARED napi_init.cpp)
target_link_libraries(multiply PUBLIC libace_napi.z.so)

# Compile the source code
add_library(nativeAdd SHARED add/add.cpp)
add_library(nativeSub SHARED sub/sub.cpp)