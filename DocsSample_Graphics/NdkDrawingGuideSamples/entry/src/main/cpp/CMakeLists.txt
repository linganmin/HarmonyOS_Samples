# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(NdkDrawingGuideSamples)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED
    napi_init.cpp
    samples/native_draw_canvas.cpp
    samples/native_draw_complex.cpp
    samples/native_draw_path.cpp
    samples/native_draw_pictext.cpp
    samples/native_draw_shape.cpp
    samples/sample_demo.cpp
    plugin/plugin_manager.cpp
)
find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)
message("hilog path is :" ${hilog-lib})
target_link_libraries(entry PUBLIC ${hilog-lib})
target_link_libraries(entry PUBLIC libnative_window.so)
target_link_libraries(entry PUBLIC libnative_drawing.so)
target_link_libraries(entry PUBLIC libace_napi.z.so libace_ndk.z.so libpixelmap_ndk.z.so)