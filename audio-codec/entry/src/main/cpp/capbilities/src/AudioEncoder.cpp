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

#include <hilog/log.h>
#include <multimedia/player_framework/native_avcodec_audiocodec.h>
#include "AVCodecSampleError.h"
#include "AudioEncoder.h"
#undef LOG_TAG
#define LOG_TAG "AudioEncoder"

namespace {
constexpr int LIMIT_LOGD_FREQUENCY = 50;
}

AudioEncoder::~AudioEncoder()
{
    Release();
}

int32_t AudioEncoder::Create(const std::string &codecMime)
{
    encoder_ = OH_AudioCodec_CreateByMime(codecMime.c_str(), true);
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Create failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::SetCallback(CodecUserData *codecUserData)
{
    int32_t ret = AV_ERR_OK;
    ret = OH_AudioCodec_RegisterCallback(encoder_,
                                         { SampleCallback::OnCodecError, SampleCallback::OnCodecFormatChange,
                                           SampleCallback::OnNeedInputBuffer, SampleCallback::OnNewOutputBuffer },
                                         codecUserData);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set callback failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "====== AudioEncoder SetCallback ======");

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Configure(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    if (format == nullptr) {
        OH_LOG_ERROR(LOG_APP, "AVFormat create failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUDIO_SAMPLE_FORMAT, sampleInfo.audioSampleOutForamt);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_CHANNEL_COUNT, sampleInfo.audioChannelOutCount);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_SAMPLE_RATE, sampleInfo.audioSampleOutRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.audioBitRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_CHANNEL_LAYOUT, sampleInfo.audioChannelOutLayout);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_MAX_INPUT_SIZE, sampleInfo.audioMaxInputOutSize);
    OH_LOG_INFO(LOG_APP, "audioChannelCount:%{public}d audioSampleRate:%{public}d audioBitRate:%{public}d "
                        "audioChannelLayout:%{public}d",
                sampleInfo.audioChannelOutCount, sampleInfo.audioSampleOutRate, sampleInfo.audioSampleForamt,
                sampleInfo.audioMaxInputOutSize);
    int ret = OH_AudioCodec_Configure(encoder_, format);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Config failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_AVFormat_Destroy(format);
    format = nullptr;

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData)
{
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Encoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (codecUserData == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Invalid param: codecUserData");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    // Configure audio encoder
    int32_t ret = Configure(sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Configure failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    // SetCallback for audio encoder
    ret = SetCallback(codecUserData);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set callback failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    // Prepare audio encoder
    {
        int ret = OH_AudioCodec_Prepare(encoder_);
        if (ret != AV_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Prepare failed, ret: %{public}d", ret);
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Start()
{
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Encoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int ret = OH_AudioCodec_Start(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Start failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isPaused_ = false;
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::PushInputData(CodecBufferInfo &info)
{
    if (isPaused_) {
        return AVCODEC_SAMPLE_ERR_OK;
    }
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Encoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (info.buffer == 0 || info.bufferIndex < 0) {
        OH_LOG_ERROR(LOG_APP, "Invalid buffer or index");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "In PushInputData: size = %{public}d, pts = %{public}ld",
                info.attr.size, info.attr.pts);
    int32_t ret = OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(info.buffer), &info.attr);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set avbuffer attr failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = OH_AudioCodec_PushInputBuffer(encoder_, info.bufferIndex);
    OH_LOG_INFO(LOG_APP, "Set OH_AudioCodec_PushInputBuffer, ret: %{public}d", ret);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "PushInputBuffer: index=%u, size=%d, pts=%ld, flags=%u",
            info.bufferIndex, info.attr.size, info.attr.pts, info.attr.flags);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::FreeOutputData(uint32_t bufferIndex)
{
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Encoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t ret = AVCODEC_SAMPLE_ERR_OK;
    ret = OH_AudioCodec_FreeOutputBuffer(encoder_, bufferIndex);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Free output data failed, ret: %{public}d, bufferIndex: %{public}d", ret, bufferIndex);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Stop()
{
    if (encoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Encoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int ret = OH_AudioCodec_Flush(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Flush failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = OH_AudioCodec_Stop(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Stop failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Release()
{
    if (encoder_ != nullptr) {
        OH_AudioCodec_Flush(encoder_);
        OH_AudioCodec_Stop(encoder_);
        OH_AudioCodec_Destroy(encoder_);
        encoder_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}