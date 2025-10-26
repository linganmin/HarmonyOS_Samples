/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
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

#include <cstdint>
#include <hilog/log.h>
#include "AVCodecSampleError.h"
#include "Muxer.h"

#undef LOG_TAG
#define LOG_TAG "Muxer"

namespace {
constexpr int32_t AUDIOTRACKID = -1;
constexpr int32_t MUXER_ONE = 1;
constexpr int32_t SAMPLE_RATE = 16000;
} // namespace

Muxer::~Muxer() { Release(); }

int32_t Muxer::Create(int32_t fd, std::string EncapsulationFormat)
{
    if (EncapsulationFormat == "m4a") {
        muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_M4A);
    } else if (EncapsulationFormat == "aac") {
        muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_AAC);
    } else if (EncapsulationFormat == "amr") {
        muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_AMR);
    } else if (EncapsulationFormat == "mp3") {
        muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_MP3);
    } else if (EncapsulationFormat == "wav") {
        muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_WAV);
    } else {
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (muxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Muxer create failed, fd: %{public}d", fd);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Config(SampleInfo &sampleInfo)
{
    if (muxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Muxer is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_AVFormat *formatAudio = OH_AVFormat_CreateAudioFormat(sampleInfo.audioCodecMime_.data(),
        sampleInfo.audioSampleOutRate, sampleInfo.audioChannelOutCount);
    if (formatAudio == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Create audio format failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (sampleInfo.audioEncapsulationFormat == "aac") {
        OH_AVFormat_SetIntValue(formatAudio, OH_MD_KEY_PROFILE, AAC_PROFILE_LC);
        OH_AVFormat_SetIntValue(formatAudio, OH_MD_KEY_AAC_IS_ADTS, MUXER_ONE);
    } else if (sampleInfo.audioEncapsulationFormat == "m4a") {
        OH_AVFormat_SetIntValue(formatAudio, OH_MD_KEY_PROFILE, AAC_PROFILE_LC);
    } else if (sampleInfo.audioCodecMime == "G711mu" || sampleInfo.audioEncapsulationFormat == "wav") {
        OH_AVFormat_SetLongValue(formatAudio, OH_MD_KEY_BITRATE, sampleInfo.audioBitRate);
    }
    if (muxer_ == nullptr || formatAudio == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Invalid parameters for OH_AVMuxer_AddTrack");
        OH_AVFormat_Destroy(formatAudio);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t ret = OH_AVMuxer_AddTrack(muxer_, &audioTrackId_, formatAudio);
    OH_AVFormat_Destroy(formatAudio);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "AddTrack failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Start()
{
    if (muxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Muxer is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int ret = OH_AVMuxer_Start(muxer_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Start failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isPaused_ = false;
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::WriteSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr)
{
    std::lock_guard<std::mutex> lock(writeMutex_);

    if (isPaused_) {
        OH_LOG_INFO(LOG_APP, "Muxer is paused, skip writing sample");
        return AVCODEC_SAMPLE_ERR_OK;
    }
    if (muxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Muxer is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (buffer == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Get a empty buffer");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t ret = OH_AVBuffer_SetBufferAttr(buffer, &attr);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "SetBufferAttr failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = OH_AVMuxer_WriteSampleBuffer(muxer_, trackId, buffer);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Write sample failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::Release()
{
    if (muxer_ != nullptr) {
        int32_t ret = OH_AVMuxer_Stop(muxer_);
        if (ret != AV_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Failed to stop muxer: %d", ret);
        }
        ret = OH_AVMuxer_Destroy(muxer_);
        if (ret != AV_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Failed to destroy muxer: %d", ret);
        }
        muxer_ = nullptr;
        audioTrackId_ = AUDIOTRACKID;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Muxer::GetAudioTrackId() { return audioTrackId_; }