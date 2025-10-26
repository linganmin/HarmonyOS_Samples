/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

#include "SampleCallback.h"
#include "AVCodecSampleLog.h"

namespace {
constexpr int LIMIT_LOGD_FREQUENCY = 50;
}


int32_t SampleCallback::OnRenderWriteData(OH_AudioRenderer *render, void *userData, void *buffer, int32_t length) {
    (void)render;
    (void)length;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    uint8_t *dest = (uint8_t *) buffer;
    size_t index = 0;
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    while (!codecUserData->renderQueue.empty() && index < length) {
        dest[index++] = codecUserData->renderQueue.front();
        codecUserData->renderQueue.pop();
    }
    AVCODEC_SAMPLE_LOGD("render BufferLength:%{public}d Out buffer count: %{public}u, renderQueue size: %{public}u "
                        "renderReadSize: %{public}u", length, 
                        codecUserData->outputFrameCount, 
                        (unsigned int)codecUserData->renderQueue.size(),
                        (unsigned int)index);
    if (codecUserData->renderQueue.size() < length) {
        codecUserData->renderCond.notify_all();
    }
    return 0;
}

int32_t SampleCallback::OnRenderStreamEvent(OH_AudioRenderer *render, void *userData, OH_AudioStream_Event event) {
    (void)render;
    (void)userData;
    (void)event;
    return 0;
}

int32_t SampleCallback::OnRenderInterruptEvent(OH_AudioRenderer *render, void *userData, OH_AudioInterrupt_ForceType type,
                                          OH_AudioInterrupt_Hint hint) {
    (void)render;
    (void)userData;
    (void)type;
    (void)hint;
    return 0;
}

int32_t SampleCallback::onRenderError(OH_AudioRenderer *render, void *userData, OH_AudioStream_Result error) {
    (void)render;
    (void)userData;
    (void)error;
    AVCODEC_SAMPLE_LOGE("OnRenderError");
    return 0;
}

void SampleCallback::OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData) {
    (void)codec;
    (void)errorCode;
    (void)userData;
    AVCODEC_SAMPLE_LOGI("On Codec Error, error code: %{public}d", errorCode);
}

void SampleCallback::OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
    AVCODEC_SAMPLE_LOGI("On Stream Change");
}

void SampleCallback::OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    AVCODEC_SAMPLE_LOGI("OnNeedInputBuffer: %{public}d", index);
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->inputMutex);
    codecUserData->inputBufferInfoQueue.emplace(index, buffer);
    codecUserData->inputCond.notify_all();
}

void SampleCallback::OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    AVCODEC_SAMPLE_LOGI("OnNewOutputBuffer: %{public}d", index);
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    codecUserData->outputBufferInfoQueue.emplace(index, buffer);
    codecUserData->outputCond.notify_all();
}

