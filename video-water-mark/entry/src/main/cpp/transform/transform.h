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

#ifndef VIDEO_CODEC_TRANSFORM_H
#define VIDEO_CODEC_TRANSFORM_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "video_decoder.h"
#include "audio_decoder.h"
#include "video_encoder.h"
#include "audio_encoder.h"
#include "demuxer.h"
#include "muxer.h"
#include "sample_info.h"

class Transform {
public:
    Transform(){};
    ~Transform();

    static Transform &GetInstance()
    {
        static Transform transform;
        return transform;
    }

    bool GetIsDecStarted();
    bool GetIsEncStarted();
    void NotifyEndOfStream();
    SampleInfo* GetSampleInfo();
    int32_t PreInit(const SampleInfo &sampleInfo);
    int32_t MuxerAndDemuxerInit(SampleInfo &sampleInfo);
    int32_t EncoderInit(SampleInfo &sampleInfo);
    int32_t AfterInit();
    int32_t Start();
    void SetNativeImageWindow(OHNativeWindow * nativeImageWindow);
    void StartDecRelease();
    void StartEncRelease();

private:
    void VideoDecInputThread();
    void VideoDecOutputThread();
    void VideoEncOutputThread();
    void DecRelease();
    void EncRelease();
    
    int32_t CreateVideoDecoder();
    
    std::unique_ptr<Muxer> muxer_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    std::unique_ptr<VideoDecoder> videoDecoder_ = nullptr;
    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::shared_ptr<AudioEncoder> audioEncoder_ = nullptr;
    
    std::mutex mutex_;
    std::atomic<bool> isStarted_{ false };
    std::atomic<bool> isDecStarted_{ false };
    std::atomic<bool> isEncStarted_{ false };
    std::atomic<bool> isEncReleased_{ false };
    std::atomic<bool> isDecReleased_{ false };
    std::unique_ptr<std::thread> videoDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> videoDecOutputThread_ = nullptr;
    std::unique_ptr<std::thread> videoEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *videoDecContext_ = nullptr;
    CodecUserData *videoEncContext_ = nullptr;
    CodecUserData *audioDecContext_ = nullptr;

    int64_t nowTimeStamp = 0;
    int64_t audioTimeStamp = 0;
    int64_t writtenSampleCnt = 0;
    int64_t audioBufferPts = 0;
    static constexpr int64_t MICROSECOND_TO_S = 1000000;
    static constexpr int64_t NANO_TO_S = 1000000000;
};

#endif  // VIDEO_CODEC_TRANSFORM_H