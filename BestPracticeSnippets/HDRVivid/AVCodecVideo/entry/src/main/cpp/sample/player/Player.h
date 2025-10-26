/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
#include "AudioDecoder.h"
#include "multimedia/player_framework/native_avbuffer.h"
#include "Demuxer.h"
#include "SampleInfo.h"
#include "PluginManager.h"

class Player {
public:
    Player(){};
    ~Player();

    static Player &GetInstance() {
        static Player player;
        return player;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();

private:
    void VideoDecInputThread();
    void VideoDecOutputThread();
    void AudioDecInputThread();
    void AudioDecOutputThread();
    void Release();
    void StartRelease();
    void ReleaseThread();
    int32_t CreateAudioDecoder();
    int32_t CreateVideoDecoder();

    std::unique_ptr<VideoDecoder> videoDecoder_ = nullptr;
    std::shared_ptr<AudioDecoder> audioDecoder_ = nullptr;
    std::unique_ptr<Demuxer> demuxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::unique_ptr<std::thread> videoDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> videoDecOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioDecOutputThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *videoDecContext_ = nullptr;
    CodecUserData *audioDecContext_ = nullptr;
    OH_AudioStreamBuilder *builder_ = nullptr;
    OH_AudioRenderer *audioRenderer_ = nullptr;
#ifdef DEBUG_DECODE
    std::ofstream audioOutputFile_; // for debug
#endif
    static constexpr int64_t MICROSECOND = 1000000;
};

#endif // VIDEO_CODEC_PLAYER_H