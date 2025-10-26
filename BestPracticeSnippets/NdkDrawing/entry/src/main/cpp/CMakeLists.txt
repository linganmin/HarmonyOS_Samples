# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(NdkDrawing)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
  include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH} ${NATIVERENDER_ROOT_PATH}/include)

add_library(ndkDrawing SHARED native_bridge.cpp)

find_library(hilog-lib hilog_ndk.z)

target_link_libraries(ndkDrawing PUBLIC libace_napi.z.so)
target_link_libraries(ndkDrawing PUBLIC ${hilog-lib})
target_link_libraries(ndkDrawing PUBLIC libnative_window.so)
target_link_libraries(ndkDrawing PUBLIC libnative_drawing.so)
target_link_libraries(ndkDrawing PUBLIC libpixelmap_ndk.z.so)
target_link_libraries(ndkDrawing PUBLIC libimage_source_ndk.z.so)
target_link_libraries(ndkDrawing PUBLIC librawfile.z.so)