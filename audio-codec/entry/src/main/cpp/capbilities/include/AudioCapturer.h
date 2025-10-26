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

#ifndef AVCODECVIDEO_AUDIOCAPTURER_H
#define AVCODECVIDEO_AUDIOCAPTURER_H

#include <ohaudio/native_audiocapturer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include <ohaudio/native_audiostream_base.h>
#include "SampleInfo.h"

enum class CaptureState {
    STOPPED,
    RUNNING,
    PAUSED
};

class AudioCapturer {
public:
    AudioCapturer() = default;
    ~AudioCapturer();

    void AudioCapturerInit(SampleInfo& sampleInfo, CodecUserData *audioEncContext);
    int32_t AudioCapturerStart();
    void AudioCapturerRelease();
    int32_t AudioCapturerPause();

private:
    OH_AudioCapturer *audioCapturer_ = nullptr;
    OH_AudioStreamBuilder *builder_ = nullptr;
    CaptureState state_ = CaptureState::STOPPED;
};


#endif // AVCODECVIDEO_AUDIOCAPTURER_H