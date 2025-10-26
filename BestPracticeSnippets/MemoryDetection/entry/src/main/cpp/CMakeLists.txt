# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(CppCrash)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED napi_init.cpp address_problems.cpp task_demo1.cpp task_demo2.cpp address_sanitizer_case1.cpp
    address_sanitizer_case2.cpp address_sanitizer_case3.cpp address_sanitizer_case4.cpp resource_leak.cpp)
target_link_libraries(entry PUBLIC libace_napi.z.so)