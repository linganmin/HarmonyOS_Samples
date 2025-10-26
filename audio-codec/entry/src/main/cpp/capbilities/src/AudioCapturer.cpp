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
#include "SampleCallback.h"
#include "AVCodecSampleError.h"
#include "AudioCapturer.h"

namespace {
constexpr int AUDIOSAMPLEOUTRATE = 48000;
constexpr int AUDIOCHANNELOUTCOUNT = 8;
}
AudioCapturer::~AudioCapturer()
{
    AudioCapturerRelease();
}

static int32_t AudioCapturerOnReadData(OH_AudioCapturer *capturer, void *userData, void *buffer, int32_t bufferLen)
{
    (void)capturer;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    if (codecUserData != nullptr) {
        std::unique_lock<std::mutex> lock(codecUserData->inputMutex);
        codecUserData->WriteCache(buffer, bufferLen);
        codecUserData->inputCond.notify_all();
    }
    return 0;
}

void AudioCapturer::AudioCapturerInit(SampleInfo &sampleInfo, CodecUserData *audioEncContext)
{
    AudioCapturerRelease();
    // Create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_CAPTURER;
    OH_AudioStreamBuilder_Create(&builder_, type);
    // set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(builder_, sampleInfo.audioSampleOutRate);
    OH_AudioStreamBuilder_SetChannelCount(builder_, sampleInfo.audioChannelOutCount);
    if ((sampleInfo.audioSampleOutRate >= AUDIOSAMPLEOUTRATE && sampleInfo.audioChannelOutCount == AUDIOCHANNELOUTCOUNT)
        && sampleInfo.audioCodecMime == "AAC") {
        OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S24LE);
    } else {
        OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
    }
    OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
    OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
    OH_AudioCapturer_Callbacks callbacks;
    callbacks.OH_AudioCapturer_OnReadData = AudioCapturerOnReadData;
    OH_AudioStreamBuilder_SetCapturerCallback(builder_, callbacks, audioEncContext);
    // create OH_AudioCapturer
    OH_AudioStream_Result result = OH_AudioStreamBuilder_GenerateCapturer(builder_, &audioCapturer_);
    if (result != AUDIOSTREAM_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "OH_AudioStreamBuilder_GenerateCapturer");
    }
}

int32_t AudioCapturer::AudioCapturerStart()
{
    if (audioCapturer_ != nullptr && (state_ == CaptureState::STOPPED || state_ == CaptureState::PAUSED)) {
        OH_AudioStream_Result result = OH_AudioCapturer_Start(audioCapturer_);
        if (result != AUDIOSTREAM_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "AudioCapturerStart");
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        return AVCODEC_SAMPLE_ERR_OK;
    }
    return AVCODEC_SAMPLE_ERR_ERROR;
}

int32_t AudioCapturer::AudioCapturerPause()
{
    if (audioCapturer_ != nullptr && state_ == CaptureState::STOPPED) {
        OH_AudioStream_Result result = OH_AudioCapturer_Pause(audioCapturer_);
        if (result != AUDIOSTREAM_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "AudioCapturerPause");
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        return AVCODEC_SAMPLE_ERR_OK;
    }
    return AVCODEC_SAMPLE_ERR_ERROR;
}

void AudioCapturer::AudioCapturerRelease()
{
    if (audioCapturer_ != nullptr) {
        OH_AudioStream_Result stopResult = OH_AudioCapturer_Stop(audioCapturer_);
        if (stopResult != AUDIOSTREAM_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "AudioCapturerRelease::OH_AudioCapturer_Stop");
        }
        stopResult = OH_AudioCapturer_Release(audioCapturer_);
        if (stopResult != AUDIOSTREAM_SUCCESS) {
            OH_LOG_ERROR(LOG_APP, "AudioCapturerRelease::OH_AudioCapturer_Release");
        }
        audioCapturer_ = nullptr;
        state_ = CaptureState::STOPPED;
    }
    if (builder_ != nullptr) {
        OH_AudioStreamBuilder_Destroy(builder_);
        builder_ = nullptr;
    }
}