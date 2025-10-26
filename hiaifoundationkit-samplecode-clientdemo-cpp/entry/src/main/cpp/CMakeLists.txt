# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(HiaiDemo)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

include_directories(${HMOS_SDK_NATIVE}/sysroot/usr/lib)
FIND_LIBRARY(hiai_foundation-lib hiai_foundation)

add_library(entry SHARED Classification.cpp HIAIModelManager.cpp)

target_link_libraries(entry PUBLIC libace_napi.z.so
    libhilog_ndk.z.so
    librawfile.z.so
    ${hiai_foundation-lib}
    libneural_network_core.so
    )
