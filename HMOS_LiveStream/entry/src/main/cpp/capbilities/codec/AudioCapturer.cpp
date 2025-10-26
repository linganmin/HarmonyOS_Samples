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

#include "include/AudioCapturer.h"

#include <ohaudio/native_audio_stream_manager.h>

#include "include/CodecCallback.h"
#include "ApiCompatibility.h"
#include "SampleLog.h"

#undef LOG_TAG
#define LOG_TAG "AudioCapturer"

// 1. First define a function pointer type consistent with the system (fully preserving parameter structure)
using GetAudioStreamManagerApiType = OH_AudioCommon_Result(*)(OH_AudioStreamManager **streamManager);
using IsAcousticEchoCancelerSupportedApiType = OH_AudioCommon_Result(*)(OH_AudioStreamManager *streamManager,
                                                                 OH_AudioStream_SourceType sourceType,
                                                                 bool *supported);

// 2. Declare API (directly associated with function pointer type)
DECLARE_API(OH_AudioManager_GetAudioStreamManager, GetAudioStreamManagerApiType, 19, "libohaudio.so");
DECLARE_API(OH_AudioStreamManager_IsAcousticEchoCancelerSupported, IsAcousticEchoCancelerSupportedApiType, 20,
            "libohaudio.so");

AudioCapturer::~AudioCapturer()
{
    AudioCapturerRelease();
}

// AudioCapturer Callback
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
// [Start AudioCapturer_Interrupt]
// Customize the audio interrupt event function
static int32_t AudioCapturerOnInterruptEvent(OH_AudioCapturer *capturer, [[maybe_unused]]void* userData,
    OH_AudioInterrupt_ForceType type, OH_AudioInterrupt_Hint hint)
{
    if ((type == AUDIOSTREAM_INTERRUPT_SHARE) && (hint == AUDIOSTREAM_INTERRUPT_HINT_RESUME)) {
        OH_AudioCapturer_Start(capturer);
    }
    return 0;
}
// [End AudioCapturer_Interrupt]

void AudioCapturer::AudioCapturerInit(SampleInfo &sampleInfo, CodecUserData *audioEncContext)
{
    AudioCapturerRelease();

    // Create builder
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_CAPTURER;
    OH_AudioStreamBuilder_Create(&builder_, type);
    // set params and callbacks
    OH_AudioStreamBuilder_SetSamplingRate(builder_, sampleInfo.audioInfo.audioSampleRate);
    OH_AudioStreamBuilder_SetChannelCount(builder_, sampleInfo.audioInfo.audioChannelCount);
    OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
    OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
    OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
    // [Start AUDIOSTREAM_SOURCE_TYPE_LIVE]
    if (sampleInfo.audioInfo.isOpenEchoCancel) {
        // Echo cancellation (audio pickup path): Setting the audio stream type to
        // AUDIOSTREAM_SOURCE_TYPE_VOICE_COMMUNICATION or AUDIOSTREAM_SOURCE_TYPE_LIVE (live streaming scenario) enables
        // built-in echo cancellation.
        OH_AudioStream_SourceType sourceType = AUDIOSTREAM_SOURCE_TYPE_VOICE_COMMUNICATION;
        OH_AudioStreamManager *streamManager = nullptr;
        if (ApiCompat_OH_AudioManager_GetAudioStreamManager.IsAvailable() &&
            ApiCompat_OH_AudioStreamManager_IsAcousticEchoCancelerSupported.IsAvailable()) {
            // Logic for handling higher API versions: Pass input parameters directly, fully consistent with native
            // calling method
            int result = ApiCompat_OH_AudioManager_GetAudioStreamManager(&streamManager);
            (void)result;
            bool isSupportAec = false;
            (void)ApiCompat_OH_AudioStreamManager_IsAcousticEchoCancelerSupported(
                streamManager, AUDIOSTREAM_SOURCE_TYPE_LIVE, &isSupportAec);
            if (isSupportAec) {
                sourceType = AUDIOSTREAM_SOURCE_TYPE_LIVE;
                SAMPLE_LOGI("high api:%{public}d version, audio stream source set to live type",
                            ohos::compatibility::GetSystemApiVersion());
            } else {
                sourceType = AUDIOSTREAM_SOURCE_TYPE_VOICE_COMMUNICATION;
                SAMPLE_LOGI("high api:%{public}d version, audio stream source set to voip type",
                            ohos::compatibility::GetSystemApiVersion());
            }
        } else {
            // Logic for handling lower API versions
            sourceType = AUDIOSTREAM_SOURCE_TYPE_VOICE_COMMUNICATION;
            SAMPLE_LOGI("low api:%{public}d version, audio stream source set to voip type",
                        ohos::compatibility::GetSystemApiVersion());
        }
        OH_AudioStreamBuilder_SetCapturerInfo(builder_, sourceType);
    }
    // [End AUDIOSTREAM_SOURCE_TYPE_LIVE]
    OH_AudioCapturer_Callbacks callbacks;
    callbacks.OH_AudioCapturer_OnReadData = AudioCapturerOnReadData;
    callbacks.OH_AudioCapturer_OnStreamEvent = nullptr;
    callbacks.OH_AudioCapturer_OnInterruptEvent = AudioCapturerOnInterruptEvent;
    callbacks.OH_AudioCapturer_OnError = nullptr;
    OH_AudioStreamBuilder_SetCapturerCallback(builder_, callbacks, audioEncContext);
    // create OH_AudioCapturer
    OH_AudioStreamBuilder_GenerateCapturer(builder_, &audioCapturer_);
}

void AudioCapturer::AudioCapturerStart()
{
    if (audioCapturer_ != nullptr) {
        OH_AudioCapturer_Start(audioCapturer_);
    }
}

void AudioCapturer::AudioCapturerRelease()
{
    if (audioCapturer_ != nullptr) {
        OH_AudioCapturer_Stop(audioCapturer_);
        OH_AudioCapturer_Release(audioCapturer_);
        audioCapturer_ = nullptr;
    }
    if (builder_ != nullptr) {
        OH_AudioStreamBuilder_Destroy(builder_);
        builder_ = nullptr;
    }
}