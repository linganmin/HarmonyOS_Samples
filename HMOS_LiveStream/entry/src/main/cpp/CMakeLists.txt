# the minimum version of CMake.
cmake_minimum_required(VERSION 3.10)
project(videoCodecSample)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_CXX_STANDARD 17)
add_compile_definitions(-DOHOS_PLATFORM)
add_compile_definitions(-DEGL_EGLEXT_PROTOTYPES)
# Add global compilation macro ONLY_TEST_ROI_INFO
add_compile_definitions(-DONLY_TEST_ROI_INFO=1)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/capbilities/codec/include
                    ${NATIVERENDER_ROOT_PATH}/common
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/err
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/log
                    ${NATIVERENDER_ROOT_PATH}/render/include
                    ${NATIVERENDER_ROOT_PATH}/player/include
                    ${NATIVERENDER_ROOT_PATH}/recorder/include
)

set(BASE_LIBRARY
    libace_napi.z.so libEGL.so libGLESv3.so libace_ndk.z.so libuv.so libhilog_ndk.z.so
    libnative_media_codecbase.so libnative_media_core.so libnative_media_vdec.so libnative_window.so
    libnative_media_venc.so libnative_media_acodec.so libnative_media_avdemuxer.so libnative_media_avsource.so
    libnative_media_avmuxer.so libohaudio.so libnative_buffer.so libnative_vsync.so libnative_image.so  libdeviceinfo_ndk.z.so
)
add_library(player SHARED player/PlayerNative.cpp
                          player/Player.cpp
                          capbilities/codec/Demuxer.cpp
                          capbilities/codec/AudioDecoder.cpp
                          capbilities/codec/CodecCallback.cpp
                          capbilities/codec/AudioRender.cpp)

add_library(recorder SHARED recorder/RecorderNative.cpp
                            recorder/Recorder.cpp
                            capbilities/codec/Muxer.cpp
                            capbilities/codec/VideoEncoder.cpp
                            capbilities/codec/AudioCapturer.cpp
                            capbilities/codec/AudioEncoder.cpp
                            capbilities/codec/CodecCallback.cpp
                            capbilities/render/egl_render_context.cpp
                            capbilities/render/render_thread.cpp
                            capbilities/render/shader_program.cpp
)

target_link_libraries(player PUBLIC ${BASE_LIBRARY})
target_link_libraries(recorder PUBLIC ${BASE_LIBRARY} player)