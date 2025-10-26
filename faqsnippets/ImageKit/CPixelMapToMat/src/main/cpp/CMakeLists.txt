# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(Project3)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(cpixelmaptomat SHARED napi_init.cpp)
target_link_libraries(cpixelmaptomat PUBLIC libace_napi.z.so libhilog_ndk.z.so libpixelmap_ndk.z.so libimage_ndk.z.so)
target_link_libraries(cpixelmaptomat PUBLIC
                       libace_napi.z.so
                       ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a/libopencv_core.so
                       ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a/libopencv_imgproc.so
                       ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a/libopencv_highgui.so
                       ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a/libopencv_imgcodecs.so
                       ${CMAKE_CURRENT_SOURCE_DIR}/../../../libs/arm64-v8a/libopencv_videoio.so
                       mindspore_lite_ndk
                       libhilog_ndk.z.so)