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

#ifndef AVSCREENCAPTURESCREENRECORD_AUDIOENCODER_H
#define AVSCREENCAPTURESCREENRECORD_AUDIOENCODER_H
#include "CAVScreenCaptureToStream/SampleInfo.h"
#include <multimedia/player_framework/native_avmuxer.h>
#include <string>

class AudioEncoder {
public:
    int32_t Create(const std::string &codecMime);
    int32_t Config(SampleInfo &sampleInfo, CodecUserData *codecUserData);
    void Stop();
    void Release();
    void Start();
    int32_t PushInputData(CodecBufferInfo &info);
    int32_t FreeOutputData(uint32_t bufferIndex);

private:
    static void OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData);
    static void OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData);
    static void OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData);
    static void OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData);


    OH_AVCodec *encoder_;
};
#endif
