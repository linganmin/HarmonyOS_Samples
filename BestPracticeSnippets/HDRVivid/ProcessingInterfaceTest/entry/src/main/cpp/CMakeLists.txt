# the minimum version of CMake.
cmake_minimum_required(VERSION 3.4.1)
project(ProcessingInterfaceTest)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/capbilities/include
                    ${NATIVERENDER_ROOT_PATH}/common
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/err
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/log
                    ${NATIVERENDER_ROOT_PATH}/render/include
                    ${NATIVERENDER_ROOT_PATH}/sample/player
                    ${NATIVERENDER_ROOT_PATH}/delpixmap
                    ${NATIVERENDER_ROOT_PATH}/
)
set(VIDEO_BASE_LIBRARY
    libpixelmap_ndk.z.so
    libace_napi.z.so
    libEGL.so
    libGLESv3.so
    libace_ndk.z.so
    libuv.so
    libhilog_ndk.z.so
    libvideo_processing.so
    libnative_media_codecbase.so
    libnative_media_core.so
    libnative_media_vdec.so
    libnative_window.so
    libnative_media_venc.so
    libnative_media_acodec.so
    libnative_media_avdemuxer.so
    libnative_media_avsource.so
    libnative_media_avmuxer.so
    libohaudio.so
    libpixelmap.so
)
set(IMAGE_BASE_LIBRARY
    libpixelmap_ndk.z.so
    libace_napi.z.so
    libEGL.so
    libGLESv3.so
    libace_ndk.z.so
    libuv.so
    libhilog_ndk.z.so
    libimage_processing.so
    libnative_media_codecbase.so
    libnative_media_core.so
    libnative_media_vdec.so
    libnative_window.so
    libnative_media_venc.so
    libnative_media_acodec.so
    libnative_media_avdemuxer.so
    libnative_media_avsource.so
    libnative_media_avmuxer.so
    libohaudio.so
    libpixelmap.so
)
add_library(player SHARED sample/player/PlayerNative.cpp
                          sample/player/Player.cpp
                          capbilities/Demuxer.cpp
                          capbilities/VideoDecoder.cpp
                          capbilities/AudioDecoder.cpp
                          render/EglCore.cpp
                          render/PluginRender.cpp
                          render/PluginManager.cpp
                          common/SampleCallback.cpp
)

add_library(delpixmap SHARED delpixmap/ProccessPixmap.cpp)

target_link_libraries(player PUBLIC ${VIDEO_BASE_LIBRARY})
target_link_libraries(delpixmap PUBLIC ${IMAGE_BASE_LIBRARY})