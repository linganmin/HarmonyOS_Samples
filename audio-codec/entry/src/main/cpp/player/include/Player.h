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

#ifndef VIDEO_CODEC_PLAYER_H
#define VIDEO_CODEC_PLAYER_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include <ohaudio/native_audiorenderer.h>
#include <ohaudio/native_audiostreambuilder.h>
#include "AudioDecoder.h"
#include "Demuxer.h"
#include "SampleInfo.h"
#include "Muxer.h"
#include "AudioEncoder.h"

class Player {
public:
    Player()
    {
        startTime_ = std::chrono::time_point<std::chrono::system_clock>();
    };
    ~Player();

    static Player &GetInstance()
    {
        static Player player;
        return player;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();
    int32_t Pause();
    int32_t CapturerStart();
    int32_t GetFramesWritten();
    int64_t GetPlayedSampleCount() const;
    int32_t GetCurrentSampleRate() const;
    int64_t GetCurrentPosition() const;
    void Release();
private:

    void AudioDecInputThread();
    void AudioDecOutputThread();
    void StartRelease();
    void ReleaseThread();
    int32_t CreateAudioDecoder();

    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;

    std::mutex mutex_;
    std::mutex doneMutex;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isAudioDone{true};
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *audioDecContext_ = nullptr;
    OH_AudioStreamBuilder *builder_ = nullptr;
    OH_AudioRenderer *audioRenderer_ = nullptr;
    static constexpr int64_t MICROSECOND = 1000000;
    
    int64_t totalDuration_;
    int64_t currentTime_;
    
    std::atomic<bool> isPaused_{false};
    std::condition_variable pauseCond_;

    int32_t isFirstFrame_ = true;
    std::unique_ptr<std::thread> encOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;
    std::unique_ptr<std::thread> releaseThread_ = nullptr;
    CodecUserData *encContext_ = nullptr;
    std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;
    
    std::chrono::time_point<std::chrono::system_clock> startTime_;
};

#endif // VIDEO_CODEC_PLAYER_H