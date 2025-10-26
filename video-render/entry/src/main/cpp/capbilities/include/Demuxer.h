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

#ifndef VULKAN_DEMUXER_H
#define VULKAN_DEMUXER_H

#include "multimedia/player_framework/native_avdemuxer.h"
#include "SampleInfo.h"

class Demuxer {
public:
    Demuxer() = default;
    ~Demuxer();
    int32_t Create(SampleInfo &sampleInfo);
    int32_t ReadSample(int32_t trackId, OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t Release();
    int32_t GetVideoTrackId();
    
private:
    int32_t GetTrackInfo(std::shared_ptr<OH_AVFormat> sourceFormat, SampleInfo &info);
    
    OH_AVSource *source_;
    OH_AVDemuxer *demuxer_;
    int32_t videoTrackId_;
};
#endif //VULKAN_DEMUXER_H
