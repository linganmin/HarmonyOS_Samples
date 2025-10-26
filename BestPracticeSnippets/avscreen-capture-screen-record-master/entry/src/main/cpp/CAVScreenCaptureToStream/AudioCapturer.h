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
#ifndef AVSCREENCAPTURESCREENRECORD_AUDIOCAPTURER_H
#define AVSCREENCAPTURESCREENRECORD_AUDIOCAPTURER_H

#include <ohaudio/native_audiocapturer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include <ohaudio/native_audiostream_base.h>

#include "SampleInfo.h"

class AudioCapturer {
public:
    AudioCapturer() = default;
    ~AudioCapturer();

    void AudioCapturerInit(SampleInfo& sampleInfo, CodecUserData *audioEncContext);
    void AudioCapturerStart();
    void AudioCapturerRelease();

private:
    static int32_t AudioCapturerOnReadData(OH_AudioCapturer *capturer, void *userData, void *buffer, int32_t bufferLen);
    OH_AudioCapturer *audioCapturer_ = nullptr;
    OH_AudioStreamBuilder *builder_ = nullptr;
};

#endif
