# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(VideoWaterMark)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
add_definitions(-DOHOS_PLATFORM) #must add this

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/camera
                    ${NATIVERENDER_ROOT_PATH}/capbilities
                    ${NATIVERENDER_ROOT_PATH}/capbilities/include
                    ${NATIVERENDER_ROOT_PATH}/common
                    ${NATIVERENDER_ROOT_PATH}/common/config
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/err
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/log
                    ${NATIVERENDER_ROOT_PATH}/common/file
                    ${NATIVERENDER_ROOT_PATH}/drawing
                    ${NATIVERENDER_ROOT_PATH}/manager
                    ${NATIVERENDER_ROOT_PATH}/recorder
                    ${NATIVERENDER_ROOT_PATH}/render
                    ${NATIVERENDER_ROOT_PATH}/transform
)

add_library(nativerender SHARED
    napi_init.cpp
    camera/ndk_camera.cpp
    render/egl_render_context.cpp
    render/render_thread.cpp
    render/plugin_render.cpp
    render/shader_program.cpp
    capbilities/audio_capturer.cpp
    capbilities/audio_decoder.cpp
    capbilities/audio_encoder.cpp
    capbilities/muxer.cpp
    capbilities/demuxer.cpp
    capbilities/video_decoder.cpp
    capbilities/video_encoder.cpp
    common/sample_callback.cpp
    common/config/config.cpp
    common/file/file.cpp
    drawing/sample_bitmap.cpp
    manager/plugin_manager.cpp
    recorder/recorder.cpp
    transform/transform.cpp
)

find_library(
    # Sets the name of the path variable.
    native-drawing-lib
    # Specifies the name of the NDK library that
    # you want CMake to locate.
    native_drawing
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

set(BASE_LIBRARY
    libohcamera.so libace_napi.z.so libhilog_ndk.z.so libuv.so
        ${native-drawing-lib} ${native-window-lib} ${hilog-lib} ${libace-lib} ${libnapi-lib}
        libnative_media_codecbase.so libnative_media_core.so libnative_media_avsource.so
        libnative_media_venc.so libnative_media_vdec.so libnative_media_avmuxer.so libnative_media_avdemuxer.so
        libEGL.so libGLESv3.so libnative_image.so libnative_window.so libnative_buffer.so libnative_vsync.so
        libohaudio.so libnative_media_acodec.so
)

target_link_libraries(nativerender PUBLIC ${BASE_LIBRARY})