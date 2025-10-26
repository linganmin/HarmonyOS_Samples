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

#ifndef HMOS_LIVESTREAM_AUDIORENDER_H
#define HMOS_LIVESTREAM_AUDIORENDER_H

#include <ohaudio/native_audiorenderer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include "CodecCallback.h"
#include "CodecInfo.h"
#include "SampleInfo.h"

class AudioRender {
public:
    AudioRender() = default;
    ~AudioRender();

    int32_t CreateAudioRender(CodecUserData* userData, const AudioInfo &audioInfo);
    int32_t StartAudioRender();
    int32_t StopAudioRender();
    int32_t ReleaseAudioRender();

private:
    OH_AudioStreamBuilder *builder_ = nullptr;
    OH_AudioRenderer *audioRenderer_ = nullptr;
};

#endif // HMOS_LIVESTREAM_AUDIORENDER_H
