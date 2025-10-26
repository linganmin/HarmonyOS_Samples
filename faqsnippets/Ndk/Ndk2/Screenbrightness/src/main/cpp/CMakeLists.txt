# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(Ndk5)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(screenbrightness SHARED napi_init.cpp)

# FAQ: 如何在Native侧获取屏幕亮度
# [Start screen_brightness_c_make]
# Screenbrightness/src/main/cpp/CMakeLists.txt
target_link_libraries(screenbrightness PUBLIC libace_napi.z.so libhilog_ndk.z.so)
# [End screen_brightness_c_make]