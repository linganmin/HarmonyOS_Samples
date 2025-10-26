# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(XComponent)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM)


include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/3rdParty
    ${NATIVERENDER_ROOT_PATH}/3rdParty/assimp
)

add_library(nativerender SHARED
    render/egl_core.cpp
    render/plugin_render.cpp
    render/model_3d_sponza.cpp
    manager/plugin_manager.cpp
    napi_init.cpp
    file/file_operator.cpp
    file/file.cpp
    model/shader.cpp
    model/model.cpp
)

find_library(
    # Sets the name of the path variable.
    EGL-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    EGL
)

find_library(
    # Sets the name of the path variable.
    GLES-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    GLESv3
)

find_library(
    # Sets the name of the path variable.
    XEngine-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    xengine
)

find_library(
    # Sets the name of the path variable.
    hilog-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    hilog_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libace-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_ndk.z
)

find_library(
    # Sets the name of the path variable.
    libnapi-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    ace_napi.z
)

find_library(
    # Sets the name of the path variable.
    libuv-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    uv
)

find_library(
    # Sets the name of the path variable.
    native-buffer-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    native_buffer
)

find_library(
    # Sets the name of the path variable.
    native-window-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    native_window
)

find_library(
   # Sets the name of the path variable.
   xengine-lib
   # Specifies the name of the NDK library that
   # you want CMake to locate.
   xengine
)

add_library(libassimp-shared SHARED IMPORTED)
set_target_properties(
        libassimp-shared
        PROPERTIES
        IMPORTED_LOCATION
        ${CMAKE_CURRENT_SOURCE_DIR}/libs/arm64-v8a/libassimp.so
)

target_link_libraries(nativerender PUBLIC
    ${EGL-lib} ${GLES-lib} ${hilog-lib} ${libace-lib} ${libnapi-lib} ${libuv-lib} libc++.a librawfile.z.so libassimp-shared libc.so libz.so ${libvsync-lib}
    ${native-window-lib}
    ${native-buffer-lib}
    ${xengine-lib})