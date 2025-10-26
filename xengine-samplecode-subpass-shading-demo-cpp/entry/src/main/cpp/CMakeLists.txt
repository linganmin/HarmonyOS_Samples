# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(SubpassShading)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

ADD_DEFINITIONS(-DVK_USE_PLATFORM_OHOS=1)
#ADD_DEFINITIONS(-DVK_NO_PROTOTYPES=1)
add_definitions(-DOHOS_PLATFORM)


include_directories(
    ${NATIVERENDER_ROOT_PATH}
    ${NATIVERENDER_ROOT_PATH}/include
)

add_library(nativerender SHARED
    file/file_operator.cpp
    file/file.cpp
    manager/plugin_manager.cpp
    render/plugin_render.cpp
    render/scene.cpp
    render/texture.cpp
    render/third_party.cpp
    render/util.cpp
    render/vulkan_context.cpp
    render/vulkan_model.cpp
    render/vulkan_renderer.cpp
    render/vulkan_util.cpp
    napi_init.cpp
)

target_include_directories(nativerender PRIVATE
        3rdParty
        3rdParty/glm
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
    libvulkan-lib
    vulkan
)

find_library( # Sets the name of the path variable.
               libvsync-lib
               # Specifies the name of the NDK library that
               # you want CMake to locate.
               native_vsync)


target_link_libraries(nativerender PUBLIC
    ${EGL-lib} ${GLES-lib} ${hilog-lib} ${libace-lib} ${libnapi-lib} ${libuv-lib} ${libvulkan-lib} libnative_window.so libc++.a librawfile.z.so ${libvsync-lib})