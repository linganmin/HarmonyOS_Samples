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
#include "dfx/error/SampleError.h"

#undef LOG_TAG
#define LOG_TAG "Muxer"

namespace {
constexpr int32_t CAMERA_ANGLE = 90;
constexpr int32_t SAMPLE_RATE = 16000;
} // namespace

Muxer::~Muxer() { Release(); }

// Create an encapsulator instance object and set the encapsulation format to mp4
int32_t Muxer::Create(int32_t fd)
{
    muxer_ = OH_AVMuxer_Create(fd, AV_OUTPUT_FORMAT_MPEG_4);
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, SAMPLE_ERR_ERROR, "Muxer create failed, fd: %{public}d", fd);
    return SAMPLE_ERR_OK;
}

int32_t Muxer::Config(SampleInfo &sampleInfo)
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, SAMPLE_ERR_ERROR, "Muxer is null");

    OH_AVFormat *formatAudio =
        OH_AVFormat_CreateAudioFormat(sampleInfo.audioInfo.audioCodecMime.data(), sampleInfo.audioInfo.audioSampleRate,
                                      sampleInfo.audioInfo.audioChannelCount);
    CHECK_AND_RETURN_RET_LOG(formatAudio != nullptr, SAMPLE_ERR_ERROR, "Create audio format failed");
    OH_AVFormat_SetIntValue(formatAudio, OH_MD_KEY_PROFILE, AAC_PROFILE_LC);
    int32_t ret = OH_AVMuxer_AddTrack(muxer_, &audioTrackId_, formatAudio);
    OH_AVFormat_Destroy(formatAudio);

    OH_AVFormat *formatVideo = OH_AVFormat_CreateVideoFormat(
        sampleInfo.videoInfo.videoCodecMime.data(), sampleInfo.videoInfo.videoWidth, sampleInfo.videoInfo.videoHeight);
    CHECK_AND_RETURN_RET_LOG(formatVideo != nullptr, SAMPLE_ERR_ERROR, "Create video format failed");

    OH_AVFormat_SetDoubleValue(formatVideo, OH_MD_KEY_FRAME_RATE, sampleInfo.videoInfo.frameRate);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_WIDTH, sampleInfo.videoInfo.videoWidth);
    OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_HEIGHT, sampleInfo.videoInfo.videoHeight);
    OH_AVFormat_SetStringValue(formatVideo, OH_MD_KEY_CODEC_MIME, sampleInfo.videoInfo.videoCodecMime.data());
    if (sampleInfo.videoInfo.isHDRVivid) {
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_VIDEO_IS_HDR_VIVID, 1);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_RANGE_FLAG, sampleInfo.videoInfo.rangFlag);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_COLOR_PRIMARIES, sampleInfo.videoInfo.primary);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_TRANSFER_CHARACTERISTICS, sampleInfo.videoInfo.transfer);
        OH_AVFormat_SetIntValue(formatVideo, OH_MD_KEY_MATRIX_COEFFICIENTS, sampleInfo.videoInfo.matrix);
    }

    ret = OH_AVMuxer_AddTrack(muxer_, &videoTrackId_, formatVideo);
    OH_AVFormat_Destroy(formatVideo);
    formatVideo = nullptr;
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "AddTrack failed");
    return SAMPLE_ERR_OK;
}

int32_t Muxer::Start()
{
    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, SAMPLE_ERR_ERROR, "Muxer is null");

    int ret = OH_AVMuxer_Start(muxer_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

int32_t Muxer::WriteSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr)
{
    std::lock_guard<std::mutex> lock(writeMutex_);

    CHECK_AND_RETURN_RET_LOG(muxer_ != nullptr, SAMPLE_ERR_ERROR, "Muxer is null");
    CHECK_AND_RETURN_RET_LOG(buffer != nullptr, SAMPLE_ERR_ERROR, "Get a empty buffer");

    int32_t ret = OH_AVBuffer_SetBufferAttr(buffer, &attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "SetBufferAttr failed");

    ret = OH_AVMuxer_WriteSampleBuffer(muxer_, trackId, buffer);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Write sample failed");
    return SAMPLE_ERR_OK;
}

int32_t Muxer::Release()
{
    if (muxer_ != nullptr) {
        OH_AVMuxer_Destroy(muxer_);
        muxer_ = nullptr;
    }
    return SAMPLE_ERR_OK;
}

int32_t Muxer::GetVideoTrackId() { return videoTrackId_; }
int32_t Muxer::GetAudioTrackId() { return audioTrackId_; }