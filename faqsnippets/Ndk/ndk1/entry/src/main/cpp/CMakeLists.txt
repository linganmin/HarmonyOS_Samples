# FAQ:如何在Native侧添加debug版本声明
# FAQ:Native侧如何使用hilog打印出日志信息
# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(ndk1)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

# [Start native_debug]
if(CMAKE_BUILD_TYPE STREQUAL Debug)
    add_definitions(-D_DEBUG)
endif()
# [End native_debug]

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED napi_init.cpp NativeMap/NativeMap.cpp Test/Test.cpp)
target_link_libraries(entry PUBLIC libace_napi.z.so  libhilog_ndk.z.so)
#target_link_libraries(entry PUBLIC ${NATIVERENDER_ROOT_PATH}/../../../libs/arm64-v8a/libnativeSub.so)

# [Start napi_hilog_libraries]
target_link_libraries(entry PUBLIC libhilog_ndk.z.so)
# [End napi_hilog_libraries]