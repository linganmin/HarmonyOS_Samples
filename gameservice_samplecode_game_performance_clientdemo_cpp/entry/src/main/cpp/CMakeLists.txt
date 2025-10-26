# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(GamePerformanceDemoForC)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED napi_init.cpp
                         src/init.cpp
                         src/query_gpuinfo.cpp
                         src/query_thermalinfo.cpp
                         src/thermallevel_callback.cpp
                         src/update_gameinfo.cpp)

target_include_directories(entry PUBLIC ${HMOS_SDK_NATIVE}/sysroot/usr/include)
target_link_directories(entry PUBLIC ${HMOS_SDK_NATIVE}/sysroot/usr/lib/aarch64-linux-ohos)
target_link_libraries(entry PUBLIC libace_napi.z.so)
target_link_libraries(entry PUBLIC libgame_performance.z.so)

