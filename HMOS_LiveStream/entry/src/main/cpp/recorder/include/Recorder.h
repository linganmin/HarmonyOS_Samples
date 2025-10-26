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

#ifndef RECODER_H
#define RECODER_H

#include "AudioEncoder.h"
#include "Muxer.h"
#include "SampleInfo.h"

#include <mutex>
#include <memory>
#include <atomic>
#include <thread>

#include <unistd.h>
#include <bits/alltypes.h>

#include "../../capbilities/codec/include/AudioBgmQueue.h"
#include "../../capbilities/codec/include/VideoEncoder.h"
#include "../../capbilities/codec/include/AudioCapturer.h"
#include "../../capbilities/render/include/render_thread.h"

class Recorder {
public:
    Recorder(){};
    ~Recorder();

    int32_t Init(SampleInfo &sampleInfo);
    int32_t Start(std::string previewSurfaceId);
    int32_t Stop();
    AudioBgmQueue* GetBgmQueue();

    void UpdateInfoForCamera(bool isFront);
    void UpdateCameraRotation(int rotation);
    void UpdateFaceInfoFromCamera(FaceInfo faceInfo);
private:
    void VideoEncOutputThread();
    void AudioEncInputThread();
    void AudioEncOutputThread();
    void Release();
    void StartRelease();
    int32_t WaitForDone();

    int32_t CreateAudioEncoder();
    int32_t CreateVideoEncoder();
    void MixMicAndBgm(int16_t *mainPcm, AudioBgmQueue* bgmQueue, int32_t sampleCount);

    std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
    std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;

    std::mutex mutex_;
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isFirstCodecData_{true};
    std::atomic<bool> isFirstSyncFrame_{true};
    int32_t isFirstFrame_ = true;
    std::unique_ptr<std::thread> videoEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::unique_ptr<std::thread> releaseThread_ = nullptr;
    std::condition_variable doneCond_;
    SampleInfo sampleInfo_;
    CodecUserData *encContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;

    std::unique_ptr<AudioCapturer> audioCapturer_ = nullptr;
    std::unique_ptr<NativeXComponentSample::RenderThread> renderThread_ = nullptr;
};

#endif // RECODER_H