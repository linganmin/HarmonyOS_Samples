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

#include <hilog/log.h>
#include <iostream>
#include <memory>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <thread>
#include <multimedia/player_framework/native_avbuffer.h>
#include "AVCodecSampleError.h"
#include "Recorder.h"

#undef LOG_TAG
#define LOG_TAG "AudioRecorder"

namespace {
using namespace std::chrono_literals;
constexpr int64_t MICROSECOND = 1000000;
constexpr int32_t INPUT_FRAME_BYTES = 2 * 1024;
constexpr int RECORDER_ZERO = 0;
constexpr int RECORDER_ONE = 1;
constexpr int RECORDER_TWO = 2;
constexpr int RECORDER_THREE = 3;
constexpr int RECORDER_FOUR = 4;
constexpr int RECORDER_FIVE = 5;
constexpr int RECORDER_SIX = 6;
constexpr int RECORDER_SEVEN = 7;
constexpr int RECORDER_EIGHT = 8;
constexpr int RECORDER_NINE = 9;
constexpr int RECORDER_TEN = 10;
constexpr int RECORDER_ELEVEN = 11;
constexpr int RECORDER_AAC_SAMPLING_1 = 8000;
constexpr int RECORDER_AAC_SAMPLING_2 = 12000;
constexpr int RECORDER_AAC_SAMPLING_3 = 16000;
constexpr int RECORDER_AAC_SAMPLING_4 = 22050;
constexpr int RECORDER_AAC_SAMPLING_5 = 24000;
constexpr int RECORDER_AAC_SAMPLING_6 = 32000;
constexpr int RECORDER_AAC_SAMPLING_7 = 44100;
constexpr int RECORDER_AAC_SAMPLING_8 = 48000;
constexpr int RECORDER_AAC_SAMPLING_9 = 64000;
constexpr int RECORDER_AAC_SAMPLING_10 = 88200;
constexpr int RECORDER_AAC_SAMPLING_11 = 96000;
constexpr int RECORDER_AAC_SAMPLING_12 = 11025;
constexpr int RECORDER_BURDEN_ONE = -1;
} // namespace

Recorder::~Recorder() { StartRelease(); }

int32_t Recorder::Init(SampleInfo &sampleInfo)
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (muxer_ != nullptr) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    sampleInfo_ = sampleInfo;
    // Audio Capturer Init
    audioEncoder_ = std::make_unique<AudioEncoder>();
    audioCapturer_ = std::make_unique<AudioCapturer>();
    muxer_ = std::make_unique<Muxer>();

    int32_t ret = muxer_->Create(sampleInfo_.outputFd, sampleInfo_.audioEncapsulationFormat);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create muxer with fd(%{public}d) failed", sampleInfo_.outputFd);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = muxer_->Config(sampleInfo_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio encoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = CreateAudioEncoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio encoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    // Init AudioCapturer
    audioCapturer_->AudioCapturerInit(sampleInfo_, audioEncContext_);
    sampleInfo.window = sampleInfo_.window;
    releaseThread_ = nullptr;
    OH_LOG_INFO(LOG_APP, "Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Start()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (muxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t ret = muxer_->Start();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Muxer start failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isStarted_ = true;
    if (audioEncContext_) {
        audioCapturer_->AudioCapturerStart();
        ret = audioEncoder_->Start();
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Audio Encoder start failed");
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        isStarted_ = true;
        audioEncInputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncInputThread, this);
        audioEncOutputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncOutputThread, this);
        if (audioEncInputThread_ == nullptr || audioEncOutputThread_ == nullptr) {
            OH_LOG_ERROR(LOG_APP, "Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        if (audioEncContext_ != nullptr) {
            audioEncContext_->ClearCache();
        }
    }
    OH_LOG_INFO(LOG_APP, "Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Pause()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (!isStarted_ || isPaused_) {
        OH_LOG_ERROR(LOG_APP, "Pause failed: not started or already paused");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isPaused_ = true;
    if (audioCapturer_) {
        audioCapturer_->AudioCapturerPause();
    }
    OH_LOG_INFO(LOG_APP, "Recording paused");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Resume()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (!isStarted_ || !isPaused_) {
        OH_LOG_ERROR(LOG_APP, "Resume failed: not started or not paused");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isPaused_ = false;
    pauseCond_.notify_all();
    if (audioCapturer_) {
        audioCapturer_->AudioCapturerStart();
    }
    OH_LOG_INFO(LOG_APP, "Recording resumed");
    return AVCODEC_SAMPLE_ERR_OK;
}

void Recorder::StartRelease()
{
    if (releaseThread_ == nullptr) {
        OH_LOG_INFO(LOG_APP, "Start release CodecTest");
        releaseThread_ = std::make_unique<std::thread>(&Recorder::Release, this);
    }
}

void Recorder::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    isPaused_ = false;
    pauseCond_.notify_all();
    if (encOutputThread_ && encOutputThread_->joinable()) {
        encOutputThread_->join();
        encOutputThread_.reset();
    }
    if (audioEncInputThread_ && audioEncInputThread_->joinable()) {
        audioEncContext_->inputCond.notify_all();
        audioEncInputThread_->join();
        audioEncInputThread_.reset();
    }
    if (audioEncOutputThread_ && audioEncOutputThread_->joinable()) {
        audioEncContext_->outputCond.notify_all();
        audioEncOutputThread_->join();
        audioEncOutputThread_.reset();
    }
    if (muxer_ != nullptr) {
        muxer_->Release();
        muxer_.reset();
        OH_LOG_INFO(LOG_APP, "Muxer release successful");
    }
    if (audioEncoder_ != nullptr) {
        audioEncoder_->Stop();
        audioEncoder_->Release();
        audioEncoder_.reset();
        OH_LOG_INFO(LOG_APP, "Audio encoder release successful");
    }
    if (audioCapturer_ != nullptr) {
        audioCapturer_->AudioCapturerRelease();
        audioCapturer_.reset();
        OH_LOG_INFO(LOG_APP, "Audio Capturer release successful");
    }
    if (audioEncContext_ != nullptr) {
        delete audioEncContext_;
        audioEncContext_ = nullptr;
    }
    doneCond_.notify_all();
    OH_LOG_INFO(LOG_APP, "Succeed");
}

int32_t Recorder::WaitForDone()
{
    OH_LOG_INFO(LOG_APP, "Wait called");
    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock);
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }
    OH_LOG_INFO(LOG_APP, "Done");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Stop()
{
    isStarted_ = false;
    isPaused_ = false;
    OH_LOG_INFO(LOG_APP, "Encoder notifyEndOfStream failed");
    return WaitForDone();
}

int32_t Recorder::CreateAudioEncoder()
{
    int32_t ret = audioEncoder_->Create(sampleInfo_.audioCodecMime_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio encoder(%{public}s) failed", sampleInfo_.audioCodecMime_.c_str());
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "Create audio encoder(%{public}s)", sampleInfo_.audioCodecMime_.c_str());

    audioEncContext_ = new CodecUserData;
    ret = audioEncoder_->Config(sampleInfo_, audioEncContext_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Encoder config failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

void Recorder::AudioEncInputThread()
{
    while (true) {
        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Encoder input thread out");
            break;
        }
        {
            std::unique_lock<std::mutex> lock(pauseMutex_);
            pauseCond_.wait(lock, [this] {
                return !isPaused_ || !isStarted_;
            });
            if (!isStarted_) break;
        }
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex);
        bool condRet = audioEncContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || (!audioEncContext_->inputBufferInfoQueue.empty() &&
                                   (audioEncContext_->remainlen >= sampleInfo_.audioMaxInputOutSize));
        });
        if (!isStarted_) break;
        if (audioEncContext_->inputBufferInfoQueue.empty()) {
            OH_LOG_ERROR(LOG_APP, "Audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }
        if (isStarted_ && audioEncContext_->remainlen < sampleInfo_.audioMaxInputOutSize) {
            continue;
        }
        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue.front();
        audioEncContext_->inputBufferInfoQueue.pop();
        audioEncContext_->inputFrameCount++;
        
        uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        audioEncContext_->ReadCache(inputBufferAddr, sampleInfo_.audioMaxInputOutSize);
        lock.unlock();

        bufferInfo.attr.size = sampleInfo_.audioMaxInputOutSize;
        if (isFirstFrame_) {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_CODEC_DATA;
            isFirstFrame_ = false;
        } else {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_NONE;
        }
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Push data failed, thread out");
            break;
        }
    }
}

void Recorder::AudioEncOutputThread()
{
    while (true) {
        if (!isStarted_) break;
        {
            std::unique_lock<std::mutex> lock(pauseMutex_);
            pauseCond_.wait(lock, [this] {
                return !isPaused_ || !isStarted_;
            });
            if (!isStarted_) break;
        }
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
        audioEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) break;
        if (audioEncContext_->outputBufferInfoQueue.empty()) continue;
        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        OH_LOG_INFO(LOG_APP,
            "Audio Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}ld",
            audioEncContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer*>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        if (ret != AVCODEC_SAMPLE_ERR_OK) break;
    }
    OH_LOG_INFO(LOG_APP, "Exit, frame count: %{public}u", audioEncContext_->inputFrameCount);
    StartRelease();
}