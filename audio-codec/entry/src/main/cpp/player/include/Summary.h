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

#ifndef VIDEO_CODEC_SUMMARY_H
#define VIDEO_CODEC_SUMMARY_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include <ohaudio/native_audiorenderer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include "AudioDecoder.h"
#include "Demuxer.h"
#include "SampleInfo.h"
#include "AudioEncoder.h"
#include "Muxer.h"

class Summary {
public:
    Summary(){};
    ~Summary();

    static Summary &GetInstance()
    {
        static Summary summary;
        return summary;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t InitDecoder();
    int32_t InitEncoder();
    int32_t Start();
    void Stop();

private:
    void AudioDecInputThread();
    void AudioDecOutputThread();
    void AudioEncInputThread();
    void AudioEncOutputThread();
    void Release();
    void Context();
    void JoinThreads();
    void DeleteContext();
    void CodeSampleInfo();
    void SetAudioBitRate();
    void ReleaseCallback();
    void CodeAacSampleInfo();
    void StartRelease();
    int32_t CreateAudioDecoder();
    int32_t CreateAudioEncoder();
    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    
    std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::mutex doneMutex;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isVideoDone{true};
    std::atomic<bool> isAudioDone{true};
    std::atomic<bool> isFirstFrame_{true};
    std::atomic<bool> isStopped_{false};
    std::atomic<bool> isInputEOS_{false};
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *audioDecContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;
    
    std::mutex yuvMutex;
    std::condition_variable yuvCond;
    std::queue<CodecBufferInfo> yuvBufferQueue;
    
    OH_AudioStreamBuilder *builder_ = nullptr;
    OH_AudioRenderer *audioRenderer_ = nullptr;
    static constexpr int64_t MICROSECOND = 1000000;
    std::queue<uint8_t> pcmQueue_;
    std::mutex pcmMutex_;
    std::condition_variable pcmCond_;
    
    std::atomic<bool> audioDecInputExit_{false};
    std::atomic<bool> audioDecOutputExit_{false};
    std::atomic<bool> audioEncOutputExit_{false};
};

#endif