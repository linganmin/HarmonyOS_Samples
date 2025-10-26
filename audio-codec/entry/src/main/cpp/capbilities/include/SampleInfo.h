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

#ifndef AVCODEC_SAMPLE_INFO_H
#define AVCODEC_SAMPLE_INFO_H

#include <cstdint>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <string>
#include <condition_variable>
#include <queue>
#include <stdint.h>
#include <native_buffer/native_buffer.h>
#include "multimedia/player_framework/native_avcodec_base.h"
#include "multimedia/player_framework/native_avbuffer.h"

constexpr int g_sampleInfoZero = 0;
constexpr int g_sampleInfoOne = 1;
constexpr int g_sampleInfoBurdenOne = -1;
constexpr int g_sampleInfoTen = 10;
constexpr int g_sampleInfoHunderd = 100;
constexpr int g_sampleInfoConfig = 1024;
struct CodecUserData;
struct SampleInfo {
    int32_t inputFd = g_sampleInfoBurdenOne;
    int32_t outputFd = g_sampleInfoBurdenOne;
    int64_t inputFileOffset = g_sampleInfoZero;
    int64_t inputFileSize = g_sampleInfoZero;
    std::string inputFilePath;
    std::string audioCodecMime_ = "";
    std::string audioCodecMime = "";
    std::string audioMime = "";
    std::string audioEncapsulationFormat = "";
    double frameRate = 0.0;
    int64_t bitrate = g_sampleInfoTen * g_sampleInfoConfig * g_sampleInfoConfig;
    int64_t frameInterval = g_sampleInfoZero;
    OH_AVPixelFormat pixelFormat = AV_PIXEL_FORMAT_NV12;
    uint32_t bitrateMode = CBR;
    int32_t iFrameInterval = g_sampleInfoHunderd;
    int32_t rangFlag = g_sampleInfoOne;
    int32_t audioSampleForamt = g_sampleInfoZero;
    int32_t audioSampleRate = g_sampleInfoZero;
    int32_t audioChannelCount = g_sampleInfoZero;
    int64_t audioChannelLayout = g_sampleInfoZero;
    int64_t samplingPoints = g_sampleInfoZero;
    
    int32_t audioSampleOutForamt = g_sampleInfoZero;
    int32_t audioSampleOutRate = g_sampleInfoZero;
    int32_t audioChannelOutCount = g_sampleInfoZero;
    int64_t audioChannelOutLayout = g_sampleInfoZero;
    int32_t audioMaxInputOutSize = g_sampleInfoZero;
    int32_t audioBitRate = g_sampleInfoZero;
    uint8_t audioCodecConfig[g_sampleInfoHunderd] = { 0 };
    size_t audioCodecSize = g_sampleInfoZero;
    int32_t audioMaxInputSize = g_sampleInfoZero;
    OH_AVFormat *audioFormat;
    int32_t isHDRVivid = g_sampleInfoZero;
    int32_t hevcProfile = HEVC_PROFILE_MAIN;
    OH_ColorPrimary primary = COLOR_PRIMARY_BT2020;
    OH_TransferCharacteristic transfer = TRANSFER_CHARACTERISTIC_PQ;
    OH_MatrixCoefficient matrix = MATRIX_COEFFICIENT_BT2020_CL;
    int32_t rotation = g_sampleInfoZero;
    OHNativeWindow *window = nullptr;
    void (*playDoneCallback)(CodecUserData *context) = nullptr;
    CodecUserData  *playDoneCallbackData = nullptr;
    uint8_t codecConfig[g_sampleInfoConfig];
    size_t codecConfigLen = g_sampleInfoZero;
    int32_t aacAdts = g_sampleInfoBurdenOne;
};

struct CodecBufferInfo {
    uint32_t bufferIndex = g_sampleInfoZero;
    uintptr_t *buffer = 0;
    uint8_t *bufferAddr = nullptr;
    OH_AVCodecBufferAttr attr = {0, 0, 0, AVCODEC_BUFFER_FLAGS_NONE};

    explicit CodecBufferInfo(uint8_t *addr) : bufferAddr(addr){};
    CodecBufferInfo(uint8_t *addr, int32_t bufferSize)
        : bufferAddr(addr), attr({0, bufferSize, 0, AVCODEC_BUFFER_FLAGS_NONE}){};
    CodecBufferInfo(uint32_t argBufferIndex, OH_AVBuffer *argBuffer)
        : bufferIndex(argBufferIndex), buffer(reinterpret_cast<uintptr_t *>(argBuffer))
    {
        OH_AVBuffer_GetBufferAttr(argBuffer, &attr);
    };
};

struct CodecUserData {
public:
    SampleInfo *sampleInfo = nullptr;

    uint32_t inputFrameCount = g_sampleInfoZero;
    std::mutex inputMutex;
    std::condition_variable inputCond;
    std::queue<CodecBufferInfo> inputBufferInfoQueue;

    uint32_t outputFrameCount = g_sampleInfoZero;
    std::mutex outputMutex;
    std::condition_variable outputCond;
    std::mutex renderMutex;
    std::condition_variable renderCond;
    std::queue<CodecBufferInfo> outputBufferInfoQueue;

    std::queue<unsigned char> renderQueue;

    // Create cache
    std::vector<char> cache;
    int32_t remainlen = g_sampleInfoZero;

    void ClearCache()
    {
        cache.clear();
        remainlen = g_sampleInfoZero;
    }

    void WriteCache(void *buffer, int32_t bufferLen)
    {
        if (bufferLen + remainlen > cache.size()) {
            cache.resize(remainlen + bufferLen);
        }
        std::copy_n(static_cast<char*>(buffer), static_cast<size_t>(bufferLen), (cache.data() + remainlen));

        remainlen += bufferLen;
    }

    bool ReadCache(void *buffer, int32_t bufferLen)
    {
        if (remainlen < bufferLen) {
            return false;
        }
        std::copy_n(static_cast<char*>(cache.data()), static_cast<size_t>(bufferLen), static_cast<char*>(buffer));
        remainlen = remainlen - bufferLen;
        if (remainlen > g_sampleInfoZero) {
            std::copy_backward(
                cache.data() + bufferLen,
                cache.data() + bufferLen + remainlen,
                cache.data() + remainlen);
        }
        return true;
    }
};

#endif // AVCODEC_SAMPLE_INFO_H