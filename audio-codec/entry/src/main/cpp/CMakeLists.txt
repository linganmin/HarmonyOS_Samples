# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(NewAvCode)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/capbilities/include
                    ${NATIVERENDER_ROOT_PATH}/player/include
                    ${NATIVERENDER_ROOT_PATH}/recorder/include
)

set(BASE_LIBRARY
    libace_napi.z.so libEGL.so libGLESv3.so libace_ndk.z.so libuv.so libhilog_ndk.z.so
    libnative_media_codecbase.so libnative_media_core.so libnative_media_vdec.so libnative_window.so
    libnative_media_venc.so libnative_media_acodec.so libnative_media_avdemuxer.so libnative_media_avsource.so libnative_media_avmuxer.so
    libohaudio.so
)
add_library(player SHARED player/src/PlayerNative.cpp
                          player/src/Player.cpp
                          player/src/Summary.cpp
                          player/src/Transcoding.cpp
                          capbilities/src/Demuxer.cpp
                          capbilities/src/AudioDecoder.cpp
                          capbilities/src/SampleCallback.cpp
                          capbilities/src/Muxer.cpp
                          capbilities/src/AudioEncoder.cpp
)

add_library(recorder SHARED recorder/src/RecorderNative.cpp
                            recorder/src/Recorder.cpp
                            capbilities/src/Muxer.cpp
                            capbilities/src/AudioCapturer.cpp
                            capbilities/src/AudioEncoder.cpp
                            capbilities/src/SampleCallback.cpp
)
target_link_libraries(player PUBLIC ${BASE_LIBRARY})
target_link_libraries(recorder PUBLIC ${BASE_LIBRARY})