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

#ifndef VIDEO_CODEC_SAMPLE_RECODER_H
#define VIDEO_CODEC_SAMPLE_RECODER_H

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include "video_encoder.h"
#include "audio_encoder.h"
#include "muxer.h"
#include "sample_info.h"
#include "audio_capturer.h"

class Recorder {
public:
    Recorder(){};
    ~Recorder();

    static Recorder &GetInstance()
    {
        static Recorder recorder;
        return recorder;
    }

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start();
    int32_t Stop();

private:
    void VideoEncOutputThread();
    void AudioEncInputThread();
    void AudioEncOutputThread();
    void Release();
    void StartRelease();
    int32_t WaitForDone();

    int32_t CreateAudioEncoder();
    int32_t CreateVideoEncoder();

    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{ false };
    std::unique_ptr<std::thread> videoEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> releaseThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *videoEncContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;

    std::unique_ptr<AudioCapturer> audioCapturer_ = nullptr;
};

#endif  // VIDEO_CODEC_SAMPLE_RECODER_H
