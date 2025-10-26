# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(AVScreenCaptureScreenRecord)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include)

add_library(entry SHARED napi_init.cpp CAVScreenCaptureToFile/CAVScreenCaptureToFile.cpp
                                       CAVScreenCaptureToStream/CAVScreenCaptureToStream.cpp
                                       CAVScreenCaptureToStream/Muxer.cpp
                                       CAVScreenCaptureToStream/VideoEncoder.cpp
                                       CAVScreenCaptureToStream/AudioEncoder.cpp
                                       CAVScreenCaptureToStream/AudioCapturer.cpp)

target_link_libraries(entry PUBLIC libace_napi.z.so libEGL.so libGLESv3.so libace_ndk.z.so libuv.so libhilog_ndk.z.so
                                       libnative_media_codecbase.so libnative_media_core.so libnative_media_vdec.so libnative_window.so
                                       libnative_media_venc.so libnative_media_acodec.so libnative_media_avdemuxer.so libnative_media_avsource.so libnative_media_avmuxer.so
                                       libohaudio.so libnative_avscreen_capture.so)