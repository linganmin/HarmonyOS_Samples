# NDK开发ArkTS侧编码规范
# [Start NDKDevelopArkTSohPackage]
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(StabilityCodingSpecification)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

# 声明一个产物libentry.so，SHARED表示产物为动态库，hello.cpp为产物的源代码
add_library(entry SHARED napi_init.cpp)

# 声明产物entry链接时需要的三方库libace_napi.z.so
target_link_libraries(entry PUBLIC libace_napi.z.so)
# [End NDKDevelopArkTSohPackage]