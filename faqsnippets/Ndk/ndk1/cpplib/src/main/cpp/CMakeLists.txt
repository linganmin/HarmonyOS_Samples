# Native侧如何引入头文件deviceinfo.h
# the minimum version of CMake.
# [Start device_info]
# CMakeLists.txt
# [StartExclude device_info]
cmake_minimum_required(VERSION 3.5.0)
project(ndk1)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(cpplib SHARED hello.cpp NumberType.cpp)
# [EndExclude device_info]
target_link_libraries(cpplib PUBLIC libace_napi.z.so libdeviceinfo_ndk.z.so)
# [End device_info]