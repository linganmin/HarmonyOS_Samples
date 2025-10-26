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

#include "VideoDecoder.h"
#include "PluginManager.h"
#include <cstdint>
#include <multimedia/player_framework/native_avcapability.h>
#include <multimedia/player_framework/native_averrors.h>
#include "dfx/error/AVCodecSampleError.h"
#include "AVCodecSampleLog.h"

#undef LOG_TAG
#define LOG_TAG "VideoDecoder"

namespace {
constexpr int LIMIT_LOGD_FREQUENCY = 50;
constexpr int ROTATION_ANGLE = 90;
}

VideoDecoder::~VideoDecoder() { Release(); }

// [Start VideoDecoderCreate]
int32_t VideoDecoder::Create(SampleInfo &sampleInfo) {
    // [StartExclude VideoDecoderCreate]
    if (sampleInfo.processType == 2) {
    // [EndExclude VideoDecoderCreate]
        OH_AVCapability *capability =
            OH_AVCodec_GetCapabilityByCategory(OH_AVCODEC_MIMETYPE_VIDEO_HEVC, false, HARDWARE);
        CHECK_AND_RETURN_RET_LOG(capability != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                                 "OH_AVCodec_GetCapabilityByCategory failed");
        const char *name = OH_AVCapability_GetName(capability);
        decoder_ = OH_VideoDecoder_CreateByName(name);
    // [StartExclude VideoDecoderCreate]
    } else {
        decoder_ = OH_VideoDecoder_CreateByMime(sampleInfo.videoCodecMime.c_str());
    }
    // [EndExclude VideoDecoderCreate]
    CHECK_AND_RETURN_RET_LOG(decoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create VideoDecoder failed");
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End VideoDecoderCreate]

int32_t VideoDecoder::Config(SampleInfo &sampleInfo, CodecUserData *codecUserData) {
    int32_t ret = Configure(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Configure failed");
    if (sampleInfo.videoIndex == 0) {
        ret = OH_VideoDecoder_SetSurface(decoder_, NativeXComponentSample::PluginManager::GetInstance()->renderWindow);
        CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK && NativeXComponentSample::PluginManager::GetInstance()->renderWindow, 
                                AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder SetSurface failed");
    } else if (sampleInfo.videoIndex == 1) {
        if (sampleInfo.processType == 1) {
            NativeXComponentSample::PluginManager::GetInstance()->PrepareSurface(sampleInfo);
            if (NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_ != nullptr) {
                ret = OH_VideoDecoder_SetSurface(decoder_, NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_);
                CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK && NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_, 
                                    AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder SetSurface failed");
            }
        } else {
            ret = OH_VideoDecoder_SetSurface(decoder_, NativeXComponentSample::PluginManager::GetInstance()->windowOut);
            CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK && NativeXComponentSample::PluginManager::GetInstance()->windowOut, 
                                AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder SetSurface failed");
        }
    }
    ret = SetCallback(codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder SetCallback failed");
    {
        ret = OH_VideoDecoder_Prepare(decoder_);
        CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder Prepare failed");
    }
    if (sampleInfo.videoIndex == 1 && sampleInfo.processType == 1) {
        NativeXComponentSample::PluginManager::GetInstance()->InitProcessing(sampleInfo);
        int32_t rotation = sampleInfo.rotation == 0 ? 0 : (360 - sampleInfo.rotation) / 90;
        AVCODEC_SAMPLE_LOGI("Set Surface Rotation: %{public}d", rotation);
        OH_NativeWindow_NativeWindowHandleOpt(NativeXComponentSample::PluginManager::GetInstance()->windowOut, SET_TRANSFORM, rotation);
        OH_NativeWindow_NativeWindowHandleOpt(NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_, SET_USAGE, NATIVEBUFFER_USAGE_CPU_READ);
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoDecoder::PushInputBuffer(CodecBufferInfo &info) {
    int32_t ret = OH_VideoDecoder_PushInputBuffer(decoder_, info.bufferIndex);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder PushInputBuffer failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoDecoder::FreeOutputBuffer(uint32_t bufferIndex, bool render) {
    int32_t ret = AV_ERR_OK;
    if (render) {
        ret = OH_VideoDecoder_RenderOutputBuffer(decoder_, bufferIndex);
    } else {
        ret = OH_VideoDecoder_FreeOutputBuffer(decoder_, bufferIndex);
    }
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder FreeOutputBuffer failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoDecoder::Start() {
    CHECK_AND_RETURN_RET_LOG(decoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "decoder_ is null");
    int32_t ret = OH_VideoDecoder_Start(decoder_);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder Start failed, ret: %{public}d", ret);
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t VideoDecoder::Release() {
    if (decoder_ != nullptr) {
        OH_VideoDecoder_Flush(decoder_);
        OH_VideoDecoder_Stop(decoder_);
        OH_VideoDecoder_Destroy(decoder_);
        decoder_ = nullptr;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start VideoDecoderSetCallback]
int32_t VideoDecoder::SetCallback(CodecUserData *codecUserData){
    int32_t ret = OH_VideoDecoder_RegisterCallback(decoder_, 
                                                {SampleCallback::OnCodecError, SampleCallback::OnCodecFormatChange, 
                                                SampleCallback::OnNeedInputBuffer, SampleCallback::OnNewOutputBuffer}, 
                                                codecUserData);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "Create SetCallback failed");
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End VideoDecoderSetCallback]

// [Start VideoDecoderConfigure]
int32_t VideoDecoder::Configure(const SampleInfo &sampleInfo) {
    OH_AVFormat *format = OH_AVFormat_Create();
    CHECK_AND_RETURN_RET_LOG(format != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Create AVFormat failed");
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, sampleInfo.videoWidth);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, sampleInfo.videoHeight);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, sampleInfo.frameRate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, sampleInfo.pixelFormat);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_ROTATION, sampleInfo.rotation);
    if(sampleInfo.processType == 2){
        // Key configuration: HDR to SDR conversion
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_DECODER_OUTPUT_COLOR_SPACE, OH_COLORSPACE_BT709_LIMIT);
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_ENABLE_LOW_LATENCY, 1);
    }
    int ret = OH_VideoDecoder_Configure(decoder_, format);
    CHECK_AND_RETURN_RET_LOG(ret == AV_ERR_OK, AVCODEC_SAMPLE_ERR_ERROR, "VideoDecoder Configure failed");
    OH_AVFormat_Destroy(format);
    format = nullptr;
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End VideoDecoderConfigure]
