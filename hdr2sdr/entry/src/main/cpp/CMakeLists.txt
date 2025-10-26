# Copyright (c) 2025 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(HDR2SDR)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/capbilities/include
                    ${NATIVERENDER_ROOT_PATH}/common
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/err
                    ${NATIVERENDER_ROOT_PATH}/common/dfx/log
                    ${NATIVERENDER_ROOT_PATH}/render/include
                    ${NATIVERENDER_ROOT_PATH}/sample/player
                    ${NATIVERENDER_ROOT_PATH}/sample/recorder
)

set(BASE_LIBRARY
    libace_napi.z.so libEGL.so libGLESv3.so libace_ndk.z.so libuv.so libhilog_ndk.z.so
    libnative_media_codecbase.so libnative_media_core.so libnative_media_vdec.so libnative_window.so
    libnative_media_venc.so libnative_media_acodec.so libnative_media_avdemuxer.so libnative_media_avsource.so libnative_media_avmuxer.so
    libohaudio.so
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
    libnative_buffer.so
    libnative_vsync.so
    libnative_image.so
    libohaudio.so
    libpixelmap.so
)

add_library(recorder SHARED sample/recorder/RecorderNative.cpp
                            sample/recorder/Recorder.cpp
                            capbilities/Muxer.cpp
                            capbilities/VideoEncoder.cpp
                            capbilities/AudioCapturer.cpp
                            capbilities/AudioEncoder.cpp
                            common/SampleCallback.cpp
)

add_library(player SHARED sample/player/PlayerNative.cpp
                          sample/player/Player.cpp
                          capbilities/Demuxer.cpp
                          capbilities/VideoDecoder.cpp
                          capbilities/AudioDecoder.cpp
                          render/ProcessingPluginRender.cpp
                          render/ProcessingPluginManager.cpp
                          common/SampleCallback.cpp
)

target_link_libraries(recorder PUBLIC ${BASE_LIBRARY})
target_link_libraries(player PUBLIC ${VIDEO_BASE_LIBRARY})