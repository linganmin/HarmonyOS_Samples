/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "Muxer.h"
#include <cstdint>
#include <hilog/log.h>

#undef LOG_TAG
#define LOG_TAG "Muxer"


Muxer::~Muxer() { Release(); }

/*
 * Create an encapsulate instance object and set the encapsulation format to mp4
 */
// [Start create_muxer2]
int32_t Muxer::Create(int32_t fd) {
    muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_MPEG_4);
    return 0;
}
// [End create_muxer2]

// [Start config_muxer2]
int32_t Muxer::Config(SampleInfo &sampleInfo) {
    // 创建并添加音频轨
    OH_AVFormat *formatAudio = OH_AVFormat_CreateAudioFormat(sampleInfo.audioCodecMime.data(),
                                                             sampleInfo.audioSampleRate, sampleInfo.audioChannelCount);
    // 设置相关参数
    OH_AVFormat_SetIntValue(formatAudio, OH_MD_KEY_PROFILE, AAC_PROFILE_LC);

    int32_t ret = OH_AVMuxer_AddTrack(muxer_, &audioTrackId_, formatAudio);
    OH_AVFormat_Destroy(formatAudio);

    // 创建并添加视频轨
    OH_AVFormat *formatVideo =
        OH_AVFormat_CreateVideoFormat(sampleInfo.videoCodecMime.data(), sampleInfo.videoWidth, sampleInfo.videoHeight);
    
    // 设置相关参数
    OH_AVFormat_SetDoubleValue(formatVideo, OH_MD_KEY_FRAME_RATE, sampleInfo.frameRate);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_WIDTH, sampleInfo.videoWidth);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_HEIGHT, sampleInfo.videoHeight);
    OH_AVFormat_SetStringValue(formatVideo, OH_MD_KEY_CODEC_MIME, sampleInfo.videoCodecMime.data());

    ret = OH_AVMuxer_AddTrack(muxer_, &videoTrackId_, formatVideo);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "AddTrack failed");
    }
    OH_AVFormat_Destroy(formatVideo);
    formatVideo = nullptr;
    return ret;
}
// [End config_muxer2]

int32_t Muxer::Start() {
    int ret = OH_AVMuxer_Start(muxer_);
    return ret;
}

int32_t Muxer::WriteSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr) {
    std::lock_guard<std::mutex> lock(writeMutex_);

    int32_t ret = OH_AVBuffer_SetBufferAttr(buffer, &attr);

    ret = OH_AVMuxer_WriteSampleBuffer(muxer_, trackId, buffer);
    return ret;
}

void Muxer::Release() {
    if (muxer_ != nullptr) {
        OH_AVMuxer_Destroy(muxer_);
        muxer_ = nullptr;
    }
}

int32_t Muxer::GetVideoTrackId() { return videoTrackId_; }
int32_t Muxer::GetAudioTrackId() { return audioTrackId_; }