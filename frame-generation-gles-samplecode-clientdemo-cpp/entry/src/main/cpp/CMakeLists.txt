# the minimum version of CMake.
cmake_minimum_required(VERSION 3.16.5)
set(CMAKE_CXX_STANDARD 20)
project(FrameGeneration)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM)

include_directories(${HMOS_SDK_NATIVE}/sysroot/usr/lib)

set(FRAMEGENERATION_SOURCES
    sources/aabb.cpp
    sources/camera.cpp
    sources/gui.cpp
    sources/matrix4x4.cpp
    sources/opaque_layer.cpp
    sources/opaque_layer_base.cpp
    sources/projection_clip_planes.cpp
    sources/renderer.cpp
    sources/scene_base.cpp
    sources/scene_extrapolation.cpp
    sources/scene_interpolation.cpp
    sources/sprite.cpp
    sources/texture_loader.cpp
    sources/timer.cpp
    sources/vector3d.cpp
    sources/vector4d.cpp
    sources/wanted_level.cpp
    sources/asset.cpp
    sources/core.cpp
    sources/log.cpp
    napi_init.cpp
)

# Treat compile warnings as errors
set(FRAMEGENERATION_COMPILE_OPTIONS
    -fno-exceptions
    -fno-rtti
    -Wall
    -Werror
    -Wextra
    -Wpedantic
    -Wshadow
)

set(FRAMEGENERATION_INCLUDE_DIRECTORIES
    ./include
)

set(FRAMEGENERATION_COMPILE_DEFINITIONS
    # Comment to remove GLES debug output overhead. Useful for release builds.
    #-DUSE_GL_DEBUG_OUTPUT
)

# Suppress OHOS specific toolchain warnings
list(APPEND FRAMEGENERATION_COMPILE_OPTIONS
    -Wno-unused-command-line-argument
)
list(APPEND FRAMEGENERATION_COMPILE_DEFINITIONS
    -DNAPI_VERSION=8
)

find_library(EGL-lib EGL REQUIRED)
find_library(GLES-lib GLESv3 REQUIRED)
find_library(ace-lib ace_ndk.z REQUIRED)
find_library(hilog-lib hilog_ndk.z REQUIRED)
find_library(napi-lib ace_napi.z REQUIRED)
find_library(rawfile-lib rawfile.z REQUIRED)
find_library(uv-lib uv REQUIRED)
find_library(framegeneration-lib libframegeneration.so REQUIRED)

set(FRAMEGENERATION_LINK_LIBRARIES
    ${EGL-lib}
    ${GLES-lib}
    ${ace-lib}
    ${hilog-lib}
    ${rawfile-lib}
    ${napi-lib}
    ${uv-lib}
    ${framegeneration-lib}
    pixelmap_ndk.z
    image_source_ndk.z
    libc++.a
)
    
# Collecting building setup...

add_library(entry SHARED
    ${FRAMEGENERATION_SOURCES}
)

target_compile_options(entry PRIVATE
    ${FRAMEGENERATION_COMPILE_OPTIONS}
)

target_link_libraries(entry PRIVATE
    ${FRAMEGENERATION_LINK_LIBRARIES}
)

target_include_directories(entry PRIVATE
    ${FRAMEGENERATION_INCLUDE_DIRECTORIES}
)

# Disable libentry.so symbol publishing
set_target_properties(entry PROPERTIES
    CXX_VISIBILITY_PRESET hidden
)

target_compile_definitions(entry PRIVATE
    ${FRAMEGENERATION_COMPILE_DEFINITIONS}
)