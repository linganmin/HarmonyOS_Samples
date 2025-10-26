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

#ifndef PLAYER_H
#define PLAYER_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "AudioDecoder.h"
#include "AudioRender.h"
#include "AudioBgmQueue.h"
#include "Demuxer.h"
#include "SampleInfo.h"

class Player {
public:
    Player(){};
    ~Player();

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();
    void WaitForStop();
    void StartRelease();
    void SetBgmQueue(AudioBgmQueue* bgmQueue);

private:
    void AudioDecInputThread();
    void AudioDecOutputThread();
    void Release();
    void ReleaseThread();
    int32_t CreateAudioDecoder();
    int32_t CreateAudioRender(CodecUserData* userData, const AudioInfo &audioInfo);

    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    std::unique_ptr<AudioRender> audioRender_ = nullptr;
    std::mutex mutex_;
    std::mutex doneMutex;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isAudioDone{true};
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    std::unique_ptr<CodecUserData> audioDecContext_;
    static constexpr int64_t MICROSECOND = 1000000;
};

#endif // PLAYER_H