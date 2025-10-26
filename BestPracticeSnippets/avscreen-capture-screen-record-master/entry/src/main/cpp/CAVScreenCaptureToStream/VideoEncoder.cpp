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
#include "VideoEncoder.h"
#include <hilog/log.h>
#include <multimedia/player_framework/native_avcapability.h>

// [Start create_video_encoder2]
void VideoEncoder::Create(const std::string &videoCodecMime) {
    encoder_ = OH_VideoEncoder_CreateByMime(videoCodecMime.c_str());
}
// [End create_video_encoder2]

// [Start config_video_encoder2]
int32_t VideoEncoder::Config(SampleInfo &sampleInfo, CodecUserData *codecUserData) {
    OH_AVFormat *format = OH_AVFormat_Create();
    
    // 配置相关参数
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_WIDTH, sampleInfo.videoWidth);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_HEIGHT, sampleInfo.videoHeight);
    OH_AVFormat_SetDoubleValue(format, OH_MD_KEY_FRAME_RATE, sampleInfo.frameRate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PIXEL_FORMAT, sampleInfo.pixelFormat);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_VIDEO_ENCODE_BITRATE_MODE, sampleInfo.bitrateMode);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.bitrate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_PROFILE, sampleInfo.hevcProfile);

    int ret = OH_VideoEncoder_Configure(encoder_, format);
    if (ret != AV_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Config failed, ret: %{public}d", ret);
    }
    OH_AVFormat_Destroy(format);
    format = nullptr;

    // 根据视频编码器获取Surface
    OH_VideoEncoder_GetSurface(encoder_, &sampleInfo.window);

    // 设置视频编码器处理回调
    OH_VideoEncoder_RegisterCallback(encoder_,
                                     {VideoEncoder::OnCodecError, VideoEncoder::OnCodecFormatChange,
                                      VideoEncoder::OnNeedInputBuffer, VideoEncoder::OnNewOutputBuffer},
                                     codecUserData);
    // 准备编码器内部资源，必须在调用此接口之前调用配置接口
    OH_VideoEncoder_Prepare(encoder_);

    return 0;
}
// [End config_video_encoder2]

int32_t VideoEncoder::NotifyEndOfStream() {
    int ret = OH_VideoEncoder_NotifyEndOfStream(encoder_);
    return ret;
}

int32_t VideoEncoder::Start() {

    int ret = OH_VideoEncoder_Start(encoder_);
    return ret;
}

int32_t VideoEncoder::FreeOutputBuffer(uint32_t bufferIndex) {

    int32_t ret = OH_VideoEncoder_FreeOutputBuffer(encoder_, bufferIndex);
    return ret;
}

int32_t VideoEncoder::Stop() {
    int ret = OH_VideoEncoder_Flush(encoder_);
    ret = OH_VideoEncoder_Stop(encoder_);
    return ret;
}

void VideoEncoder::Release() {
    if (encoder_ != nullptr) {
        OH_VideoEncoder_Destroy(encoder_);
        encoder_ = nullptr;
    }
}


void VideoEncoder::OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData) {
    (void)codec;
    (void)errorCode;
    (void)userData;
}

void VideoEncoder::OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData) {
    (void)codec;
    (void)format;
    (void)userData;
}

void VideoEncoder::OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->inputMutex);
    codecUserData->inputBufferInfoQueue.emplace(index, buffer);
    codecUserData->inputCond.notify_all();
}

void VideoEncoder::OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData) {
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    CodecUserData *codecUserData = static_cast<CodecUserData *>(userData);
    std::unique_lock<std::mutex> lock(codecUserData->outputMutex);
    codecUserData->outputBufferInfoQueue.emplace(index, buffer);
    codecUserData->outputCond.notify_all();
}