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

#include "AudioRender.h"
#include "SampleLog.h"
#include "CodecCallback.h"
#include "dfx/error/SampleError.h"

// Customize the audio stream event function
static int32_t OnRenderStreamEvent([[maybe_unused]]OH_AudioRenderer *renderer, [[maybe_unused]]void *userData, 
    [[maybe_unused]]OH_AudioStream_Event event)
{
    // Update the player status and interface based on the audio stream event information represented by the event
    return 0;
}

// [Start AudioRender_Interrupt]
// Customize the audio interrupt event function
static int32_t OnRenderInterruptEvent(OH_AudioRenderer *renderer, [[maybe_unused]]void *userData, 
    OH_AudioInterrupt_ForceType type, OH_AudioInterrupt_Hint hint)
{
    if ((type == AUDIOSTREAM_INTERRUPT_SHARE) && (hint == AUDIOSTREAM_INTERRUPT_HINT_RESUME)) {
        OH_AudioRenderer_Start(renderer);
    }
    return 0;
}
// [End AudioRender_Interrupt]
// Custom exception callback functions
static int32_t OnRenderError([[maybe_unused]]OH_AudioRenderer *renderer, [[maybe_unused]]void *userData, 
    [[maybe_unused]]OH_AudioStream_Result error)
{
    SAMPLE_LOGE("OnRenderError");
    // Handle the audio exception information based on the error message
    return 0;
}

// Custom data write function.
OH_AudioData_Callback_Result AudioRendererOnWriteData(
    OH_AudioRenderer* renderer,
    void* userData,
    void* audioData,
    int32_t audioDataSize)
{
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);

    // Write the data to be played to the buffer by length
    uint8_t *dest = (uint8_t *)audioData;
    size_t index = 0;
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    // Retrieve the length of the data to be played from the queue
    while (!codecUserData->renderQueue.empty() && index < audioDataSize) {
        dest[index++] = codecUserData->renderQueue.front();
        codecUserData->renderQueue.pop();
    }
    SAMPLE_LOGD("render BufferLength:%{public}d Out buffer count: %{public}u, renderQueue.size: %{public}u "
                "renderReadSize: %{public}u",
                audioDataSize, codecUserData->outputFrameCount, (unsigned int)codecUserData->renderQueue.size(),
                (unsigned int)index);
    if (codecUserData->renderQueue.size() < audioDataSize) {
        codecUserData->renderCond.notify_all();
    }
    return AUDIO_DATA_CALLBACK_RESULT_VALID;
}

AudioRender::~AudioRender()
{
}

int32_t AudioRender::CreateAudioRender(CodecUserData* userData, const AudioInfo &audioInfo)
{
    OH_AudioStreamBuilder_Create(&builder_, AUDIOSTREAM_TYPE_RENDERER);
    OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
    // Set the audio sample rate
    OH_AudioStreamBuilder_SetSamplingRate(builder_, audioInfo.audioSampleRate);
    // Set the audio channel
    OH_AudioStreamBuilder_SetChannelCount(builder_, audioInfo.audioChannelCount);
    // Set the audio sample format
    OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
    // Sets the encoding type of the audio stream
    OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
    // Set the working scenario for the output audio stream
    OH_AudioStreamBuilder_SetRendererInfo(builder_, AUDIOSTREAM_USAGE_MOVIE);
    SAMPLE_LOGI("Init audioSampleRate: %{public}d, ChannelCount: %{public}d", audioInfo.audioSampleRate,
                audioInfo.audioChannelCount);
    OH_AudioRenderer_Callbacks callbacks;
    // Configure the callback function
    callbacks.OH_AudioRenderer_OnWriteData = nullptr;
    callbacks.OH_AudioRenderer_OnStreamEvent = OnRenderStreamEvent;
    callbacks.OH_AudioRenderer_OnInterruptEvent = OnRenderInterruptEvent;
    callbacks.OH_AudioRenderer_OnError = OnRenderError;
    // Set the callback for the output audio stream
    OH_AudioStreamBuilder_SetRendererCallback(builder_, callbacks, userData);
    // Configure the callback function for writing audio data.
    OH_AudioRenderer_OnWriteDataCallback writeDataCb = AudioRendererOnWriteData;
    OH_AudioStreamBuilder_SetRendererWriteDataCallback(builder_, writeDataCb, userData);
    OH_AudioStreamBuilder_GenerateRenderer(builder_, &audioRenderer_);
    return SAMPLE_ERR_OK;
}

int32_t AudioRender::StartAudioRender()
{
    if (audioRenderer_) {
        OH_AudioRenderer_Start(audioRenderer_);
    }
    return SAMPLE_ERR_OK;
}

int32_t AudioRender::StopAudioRender()
{
    if (audioRenderer_) {
        OH_AudioRenderer_Stop(audioRenderer_);
    }
    return SAMPLE_ERR_OK;
}

int32_t AudioRender::ReleaseAudioRender()
{
    OH_AudioStreamBuilder_Destroy(builder_);
    if (audioRenderer_) {
        OH_AudioRenderer_Release(audioRenderer_);
        audioRenderer_ = nullptr;
    }
    builder_ = nullptr;
    audioRenderer_ = nullptr;
    return SAMPLE_ERR_OK;
}
