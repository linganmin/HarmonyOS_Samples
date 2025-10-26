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

#ifndef VIDEO_CODEC_PLAYER_H
#define VIDEO_CODEC_PLAYER_H

#include <bits/alltypes.h>
#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include <unistd.h>
#include <ohaudio/native_audiorenderer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include <fstream>
#include "VideoDecoder.h"
#include "multimedia/player_framework/native_avbuffer.h"
#include "Demuxer.h"
#include "SampleInfo.h"
#include "VideoEncoder.h"
#include "Muxer.h"

class Transcoding {
public:
    Transcoding(){};
    ~Transcoding();

    static Transcoding &GetInstance() {
        static Transcoding transcoding;
        return transcoding;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t InitDecoder();
    int32_t InitEncoder();
    int32_t Start();
    void Stop();

private:
    void VideoDecInputThread();
    void VideoDecOutputThread();
    void VideoEncOutputThread();
    void CopyStrideYUV420SP(CodecBufferInfo &encBufferInfo, CodecBufferInfo &bufferInfo);
    void Release();
    void StartRelease();
    int32_t CreateVideoDecoder();
    int32_t CreateVideoEncoder();

    std::unique_ptr<VideoDecoder> videoDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    
    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::mutex doneMutex;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isVideoDone{true};
    std::atomic<bool> isAudioDone{true};
    std::unique_ptr<std::thread> videoDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> videoDecOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    
    std::unique_ptr<std::thread> videoEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *videoDecContext_ = nullptr;
    CodecUserData *audioDecContext_ = nullptr;
    CodecUserData *videoEncContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;
    
    std::mutex yuvMutex;
    std::condition_variable yuvCond;
    std::queue<CodecBufferInfo> yuvBufferQueue;
    
    OH_AudioStreamBuilder *builder_ = nullptr;
    OH_AudioRenderer *audioRenderer_ = nullptr;
    static constexpr int64_t MICROSECOND = 1000000;
};

#endif