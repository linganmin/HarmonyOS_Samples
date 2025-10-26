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
#include "AVCodecSampleError.h"
#include "AudioDecoder.h"

#undef LOG_TAG
#define LOG_TAG "AudioDecoder"

AudioDecoder::~AudioDecoder() { Release(); }

int32_t AudioDecoder::Create(const std::string &codecMime)
{
    decoder_ = OH_AudioCodec_CreateByMime(codecMime.c_str(), false);
    if (decoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Create failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::SetCallback(CodecUserData *codecUserData)
{
    int32_t ret = AV_ERR_OK;
    ret = OH_AudioCodec_RegisterCallback(decoder_,
                                         {SampleCallback::OnCodecError, SampleCallback::OnCodecFormatChange,
                                          SampleCallback::OnNeedInputBuffer, SampleCallback::OnNewOutputBuffer},
                                         codecUserData);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set callback failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::Configure(const SampleInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    if (format == nullptr) {
        OH_LOG_ERROR(LOG_APP, "AVFormat create failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUDIO_SAMPLE_FORMAT, sampleInfo.audioSampleForamt);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_CHANNEL_COUNT, sampleInfo.audioChannelCount);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_SAMPLE_RATE, sampleInfo.audioSampleRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_CHANNEL_LAYOUT, sampleInfo.audioChannelLayout);
    if (sampleInfo.codecConfigLen > 0) {
        OH_LOG_INFO(LOG_APP, "====== AudioDecoder config ====== codecConfig:%{public}p, len:%zu, "
                            "adts:%{public}i, 0:0x%{public}02x, 1:0x%{public}02x",
                    sampleInfo.codecConfig, sampleInfo.codecConfigLen, sampleInfo.aacAdts,
                    sampleInfo.codecConfig[0], sampleInfo.codecConfig[1]);
        uint8_t tmpCodecConfig[2];
        tmpCodecConfig[0] = 0x13;                      // 0x11
        tmpCodecConfig[1] = 0x10;                      // 0x90
        tmpCodecConfig[0] = sampleInfo.codecConfig[0]; // 0x11
        tmpCodecConfig[1] = sampleInfo.codecConfig[1]; // 0x90
        OH_LOG_INFO(LOG_APP, "====== AudioDecoder config ====== 0:0x%{public}02x, 1:0x%{public}02x", tmpCodecConfig[0],
                    tmpCodecConfig[1]);
        OH_AVFormat_SetBuffer(format, OH_MD_KEY_CODEC_CONFIG, sampleInfo.codecConfig, sampleInfo.codecConfigLen);
    }

    OH_LOG_INFO(LOG_APP, "====== AudioDecoder config ======");
    int ret = OH_AudioCodec_Configure(decoder_, format);
    OH_LOG_INFO(LOG_APP, "====== AudioDecoder config ======");
    OH_AVFormat_Destroy(format);
    format = nullptr;
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Config failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::Config(const SampleInfo &sampleInfo, CodecUserData *codecUserData)
{
    if (decoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Decoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (codecUserData == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Invalid param: codecUserData");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    // Configure audio decoder
    int32_t ret = Configure(sampleInfo);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Configure failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    // SetCallback for audio decoder
    ret = SetCallback(codecUserData);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set callback failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    // Prepare audio decoder
    {
        int ret = OH_AudioCodec_Prepare(decoder_);
        if (ret != AV_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Prepare failed, ret: %{public}d", ret);
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::Start()
{
    if (decoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Decoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    int ret = OH_AudioCodec_Start(decoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Start failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::PushInputBuffer(CodecBufferInfo &info)
{
    if (decoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Decoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t ret = OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(info.buffer), &info.attr);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set avbuffer attr failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = OH_AudioCodec_PushInputBuffer(decoder_, info.bufferIndex);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Push input data failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::FreeOutputBuffer(uint32_t bufferIndex)
{
    if (decoder_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Decoder is null");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    int32_t ret = AVCODEC_SAMPLE_ERR_OK;
    ret = OH_AudioCodec_FreeOutputBuffer(decoder_, bufferIndex);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Free output data failed, ret: %{public}d", ret);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t AudioDecoder::Release()
{
    if (decoder_ != nullptr) {
        OH_AudioCodec_Flush(decoder_);
        OH_AudioCodec_Stop(decoder_);
        OH_AudioCodec_Destroy(decoder_);
        decoder_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}