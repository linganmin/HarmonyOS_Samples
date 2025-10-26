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

#ifndef VIDEO_CODEC_TRANSCODING_H
#define VIDEO_CODEC_TRANSCODING_H

#include <memory>
#include "AudioDecoder.h"
#include "Demuxer.h"
#include "SampleInfo.h"
#include "AudioEncoder.h"
#include "Muxer.h"

class Transcoding {
public:
    Transcoding(){};
    ~Transcoding();

    static Transcoding &GetInstance()
    {
        static Transcoding transcoding;
        return transcoding;
    }

    int32_t Init(SampleInfo &sampleInfo);
    void Stop();
    int32_t audioSampleRate();
    int32_t audioChannelCount();
private:
    int32_t CreateAudioDecoder();
    int32_t InitDecoder();
    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    CodecUserData *audioDecContext_ = nullptr;
    SampleInfo sampleInfo_;
};

#endif