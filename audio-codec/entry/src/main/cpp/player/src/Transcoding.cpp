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

#include <queue>
#include <hilog/log.h>
#include <algorithm>
#include <fstream>
#include "AVCodecSampleError.h"
#include "Transcoding.h"

#undef LOG_TAG
#define LOG_TAG "transcoding"

namespace {
constexpr int BALANCE_VALUE = 2;
using namespace std::chrono_literals;
constexpr int8_t YUV420_SAMPLE_RATIO = 2;
} // namespace

Transcoding::~Transcoding() { Transcoding::Stop(); }

int32_t Transcoding::CreateAudioDecoder()
{
    OH_LOG_INFO(LOG_APP, "audio mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio decoder failed, mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    } else {
        audioDecContext_ = new CodecUserData;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Audio Decoder config failed, ret: %{public}d", ret);
            return ret;
        }
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Transcoding::Init(SampleInfo &sampleInfo)
{
    if (!(demuxer_ == nullptr && audioDecoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    sampleInfo_ = sampleInfo;
    int32_t ret = InitDecoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create video decoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Transcoding::InitDecoder()
{
    if (!(demuxer_ == nullptr && audioDecoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();
    
    int32_t ret = demuxer_->Create(sampleInfo_);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        ret = CreateAudioDecoder();
    } else {
        OH_LOG_ERROR(LOG_APP, "Create audio decoder failed");
    }
    return ret;
}

int32_t Transcoding::audioSampleRate()
{
    return sampleInfo_.audioSampleRate;
}

int32_t Transcoding::audioChannelCount()
{
    return sampleInfo_.audioChannelCount;
}

void Transcoding::Stop()
{
    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    if (audioDecContext_ != nullptr) {
        delete audioDecContext_;
        audioDecContext_ = nullptr;
    }
}