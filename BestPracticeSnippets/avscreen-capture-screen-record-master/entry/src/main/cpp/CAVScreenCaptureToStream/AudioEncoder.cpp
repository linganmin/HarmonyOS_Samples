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
#include "AudioEncoder.h"
#include "hilog/log.h"
#include <multimedia/player_framework/native_avcodec_audiocodec.h>
#include <mutex>

#undef LOG_TAG
#define LOG_TAG "AudioEncoder"

// [Start create_audio_encoder2]
// 创建音频编码器
int32_t AudioEncoder::Create(const std::string &codecMime) {
    encoder_ = OH_AudioCodec_CreateByMime(codecMime.c_str(), true);
    return 0;
}
// [End create_audio_encoder2]

/*
 * Configure audio encoder
 */
// [Start config_audio_encoder2]
int32_t AudioEncoder::Config(SampleInfo &sampleInfo, CodecUserData *codecUserData) {
    OH_AVFormat *format = OH_AVFormat_Create();
    if (format == nullptr) {
        OH_LOG_ERROR(LOG_APP, "AVFormat create failed");
    }

    // 配置相关参数
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUDIO_SAMPLE_FORMAT, sampleInfo.audioSampleFormat);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_CHANNEL_COUNT, sampleInfo.audioChannelCount);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_SAMPLE_RATE, sampleInfo.audioSampleRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.audioBitRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_CHANNEL_LAYOUT, sampleInfo.audioChannelLayout);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_MAX_INPUT_SIZE, sampleInfo.audioMaxInputSize);
    int ret = OH_AudioCodec_Configure(encoder_, format);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Config failed, ret: %{public}d", ret);
    }
    OH_AVFormat_Destroy(format);
    format = nullptr;
    
    // 设置音频编码器处理回调
    OH_AudioCodec_RegisterCallback(encoder_,
                                   {AudioEncoder::OnCodecError, AudioEncoder::OnCodecFormatChange,
                                    AudioEncoder::OnNeedInputBuffer, AudioEncoder::OnNewOutputBuffer},
                                   codecUserData);
    // 准备编码器内部资源，必须在调用此接口之前调用配置接口
    ret = OH_AudioCodec_Prepare(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Prepare failed, ret: %{public}d", ret);
    }
    return 0;
}
// [End config_audio_encoder2]


void AudioEncoder::Start() {
    int ret = OH_AudioCodec_Start(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Start failed, ret: %{public}d", ret);
    }
}

int32_t AudioEncoder::PushInputData(CodecBufferInfo &info) {
    int32_t ret = OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(info.buffer), &info.attr);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Set av buffer attr failed");
    }
    ret = OH_AudioCodec_PushInputBuffer(encoder_, info.bufferIndex);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Push input data failed");
    }
    return ret;
}

int32_t AudioEncoder::FreeOutputData(uint32_t bufferIndex) {
    int32_t ret = OH_AudioCodec_FreeOutputBuffer(encoder_, bufferIndex);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Free output data failed");
    }
    return ret;
}

void AudioEncoder::Stop() {
    int ret = OH_AudioCodec_Flush(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Flush failed, ret: %{public}d", ret);
    }
    ret = OH_AudioCodec_Stop(encoder_);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Stop failed, ret: %{public}d", ret);
    }
}

void AudioEncoder::Release() {
    if (encoder_ != nullptr) {
        OH_AudioCodec_Flush(encoder_);
        OH_AudioCodec_Stop(encoder_);
        OH_AudioCodec_Destroy(encoder_);
        encoder_ = nullptr;
    }
}

void AudioEncoder::OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData) {
    (void)codec;
    (void)errorCode;
    (void)userData;
}

void AudioEncoder::OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
    (void)codec;
    (void)format;
    (void)userData;
}

void AudioEncoder::OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->inputMutex);
    codecUserData->inputBufferInfoQueue.emplace(index, buffer);
    codecUserData->inputCond.notify_all();
}

void AudioEncoder::OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    codecUserData->outputBufferInfoQueue.emplace(index, buffer);
    codecUserData->outputCond.notify_all();
}