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

#include "include/AudioEncoder.h"

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
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Create failed");
    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::SetCallback(CodecUserData *codecUserData)
{
    int32_t ret = AV_ERR_OK;
    ret = OH_AudioCodec_RegisterCallback(encoder_,
                                         { CodecCallback::OnCodecError, CodecCallback::OnCodecFormatChange,
                                           CodecCallback::OnNeedInputBuffer, CodecCallback::OnNewOutputBuffer },
                                         codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Set callback failed, ret: %{public}d", ret);
    SAMPLE_LOGI("====== AudioEncoder SetCallback ======");

    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Configure(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    CHECK_AND_RETURN_RET_LOG(format != nullptr, SAMPLE_ERR_ERROR, "AVFormat create failed");

    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUDIO_SAMPLE_FORMAT, sampleInfo.audioInfo.audioSampleForamt);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_CHANNEL_COUNT, sampleInfo.audioInfo.audioChannelCount);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_SAMPLE_RATE, sampleInfo.audioInfo.audioSampleRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.audioInfo.audioBitRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_CHANNEL_LAYOUT, sampleInfo.audioInfo.audioChannelLayout);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_MAX_INPUT_SIZE, sampleInfo.audioInfo.audioMaxInputSize);
    SAMPLE_LOGI("audioChannelCount:%{public}d audioSampleRate:%{public}d audioBitRate:%{public}d "
                "audioChannelLayout:%{public}ld",
                sampleInfo.audioInfo.audioChannelCount, sampleInfo.audioInfo.audioSampleRate,
                sampleInfo.audioInfo.audioBitRate, sampleInfo.audioInfo.audioChannelLayout);

    int ret = OH_AudioCodec_Configure(encoder_, format);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Config failed, ret: %{public}d", ret);
    OH_AVFormat_Destroy(format);
    format = nullptr;

    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");
    CHECK_AND_RETURN_RET_LOG(codecUserData != nullptr, SAMPLE_ERR_ERROR, "Invalid param: codecUserData");

    // Configure audio encoder
    int32_t ret = Configure(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR, "Configure failed");

    // SetCallback for audio encoder
    ret = SetCallback(codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, SAMPLE_ERR_ERROR,
                             "Set callback failed, ret: %{public}d", ret);

    // Prepare audio encoder
    {
        int ret = OH_AudioCodec_Prepare(encoder_);
        CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Prepare failed, ret: %{public}d", ret);
    }

    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Start()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_AudioCodec_Start(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Start failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::PushInputData(CodecBufferInfo &info)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");
    int32_t ret = OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(info.buffer), &info.attr);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Set avbuffer attr failed");
    ret = OH_AudioCodec_PushInputBuffer(encoder_, info.bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Push input data failed");
    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::FreeOutputData(uint32_t bufferIndex)
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int32_t ret = SAMPLE_ERR_OK;
    ret = OH_AudioCodec_FreeOutputBuffer(encoder_, bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Free output data failed");
    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Stop()
{
    CHECK_AND_RETURN_RET_LOG(encoder_ != nullptr, SAMPLE_ERR_ERROR, "Encoder is null");

    int ret = OH_AudioCodec_Flush(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Flush failed, ret: %{public}d", ret);

    ret = OH_AudioCodec_Stop(encoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, SAMPLE_ERR_ERROR, "Stop failed, ret: %{public}d", ret);
    return SAMPLE_ERR_OK;
}

int32_t AudioEncoder::Release()
{
    if (encoder_ != nullptr) {
        OH_AudioCodec_Flush(encoder_);
        OH_AudioCodec_Stop(encoder_);
        OH_AudioCodec_Destroy(encoder_);
        encoder_ = nullptr;
    }
    return SAMPLE_ERR_OK;
}
