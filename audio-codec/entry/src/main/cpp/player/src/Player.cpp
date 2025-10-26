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

#include <ohaudio/native_audiocapturer.h>
#include <queue>
#include <iostream>
#include <iomanip>
#include <hilog/log.h>
#include "AVCodecSampleError.h"
#include "AudioCapturer.h"
#include "Player.h"
#undef LOG_TAG
#define LOG_TAG "player"
#define AV_NOPTS_VALUE (int64_t)UINT64_C(0x8000000000000000)

namespace {
constexpr int DEFAULT_BALANCE_FACTOR = 2;
constexpr int MAX_BALANCE_FACTOR = 4;
constexpr int ONE_THOUSANDONE = 1000;
using namespace std::chrono_literals;
} // namespace

Player::~Player() { Player::StartRelease(); }

int32_t Player::CreateAudioDecoder()
{
    OH_LOG_INFO(LOG_APP, "audio mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio decoder failed, mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    } else {
        audioDecContext_ = new CodecUserData;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Audio Decoder config failed, ret: %{public}d", ret);
            return ret;
        }
        OH_AudioStreamBuilder_Create(&builder_, AUDIOSTREAM_TYPE_RENDERER);
        OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
        OH_AudioStreamBuilder_SetSamplingRate(builder_, sampleInfo_.audioSampleRate);
        OH_AudioStreamBuilder_SetChannelCount(builder_, sampleInfo_.audioChannelCount);
        OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
        OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
        OH_AudioStreamBuilder_SetRendererInfo(builder_, AUDIOSTREAM_USAGE_MOVIE);
        OH_LOG_INFO(LOG_APP, "Init audioSampleRate: %{public}d, ChannelCount: %{public}d", sampleInfo_.audioSampleRate,
                    sampleInfo_.audioChannelCount);
        OH_AudioRenderer_Callbacks callbacks;
        // Configure the callback function
        callbacks.OH_AudioRenderer_OnWriteData = SampleCallback::OnRenderWriteData;
        callbacks.OH_AudioRenderer_OnStreamEvent = SampleCallback::OnRenderStreamEvent;
        callbacks.OH_AudioRenderer_OnInterruptEvent = SampleCallback::OnRenderInterruptEvent;
        callbacks.OH_AudioRenderer_OnError = SampleCallback::OnRenderError;
        OH_AudioStreamBuilder_SetRendererCallback(builder_, callbacks, audioDecContext_);
        OH_AudioStreamBuilder_GenerateRenderer(builder_, &audioRenderer_);
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::Init(SampleInfo &sampleInfo)
{
    std::unique_lock<std::mutex> lock(mutex_);
   
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (!(demuxer_ == nullptr && audioDecoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    sampleInfo_ = sampleInfo;
    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();
    isReleased_ = false;
    int32_t ret = demuxer_->Create(sampleInfo_);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        ret = CreateAudioDecoder();
    } else {
        OH_LOG_ERROR(LOG_APP, "Create demuxer failed");
    }
    
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create video decoder failed");
        doneCond_.notify_all();
        lock.unlock();
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::Start()
{
    std::unique_lock<std::mutex> lock(mutex_);
    int32_t ret;
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (demuxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (audioDecContext_) {
        ret = audioDecoder_->Start();
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Audio Decoder start failed");
            lock.unlock();
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        isStarted_ = true;
        audioDecInputThread_ = std::make_unique<std::thread>(&Player::AudioDecInputThread, this);
        audioDecOutputThread_ = std::make_unique<std::thread>(&Player::AudioDecOutputThread, this);
        if (audioDecInputThread_ == nullptr || audioDecOutputThread_ == nullptr) {
            OH_LOG_ERROR(LOG_APP, "Create thread failed");
            lock.unlock();
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    if (audioRenderer_) {
        OH_AudioRenderer_Start(audioRenderer_);
    }
    OH_LOG_INFO(LOG_APP, "Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}

void Player::StartRelease()
{
    OH_LOG_INFO(LOG_APP, "start release");
    {
        std::unique_lock<std::mutex> lock(mutex_);
        isStarted_ = false;
    }
    
    std::unique_lock<std::mutex> doneLock(doneMutex);
    doneCond_.wait(doneLock, [this]() { return isAudioDone.load(); });
    
    Release();
}

int32_t Player::Pause()
{
    std::unique_lock<std::mutex> lock(mutex_);
    if (!isStarted_ || isPaused_) {
        OH_LOG_ERROR(LOG_APP, "Not started or already paused.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (audioRenderer_) {
        OH_AudioStream_Result ret = OH_AudioRenderer_Pause(audioRenderer_);
        if (ret != AUDIOSTREAM_SUCCESS) {
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    isPaused_ = true;
    OH_LOG_INFO(LOG_APP, "Pause succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::CapturerStart()
{
    std::unique_lock<std::mutex> lock(mutex_);
    if (!isStarted_ || !isPaused_) {
        OH_LOG_ERROR(LOG_APP, "Not started or not paused.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    
    if (audioRenderer_) {
        OH_AudioRenderer_Start(audioRenderer_);
    }

    isPaused_ = false;
    pauseCond_.notify_all();
    OH_LOG_INFO(LOG_APP, "Resume succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

void Player::ReleaseThread()
{
    if (audioDecInputThread_ && audioDecInputThread_->joinable()) {
        audioDecInputThread_->detach();
        audioDecInputThread_.reset();
    }
    if (audioDecOutputThread_ && audioDecOutputThread_->joinable()) {
        audioDecOutputThread_->detach();
        audioDecOutputThread_.reset();
    }
}

int32_t Player::GetFramesWritten()
{
    if (demuxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    int32_t duration = demuxer_->GetSampleRate();
    return duration;
}

int64_t Player::GetPlayedSampleCount() const
{
    if (!audioRenderer_) return 0;
    
    int64_t framesWritten = 0;
    OH_AudioRenderer_GetFramesWritten(audioRenderer_, &framesWritten);
    return framesWritten;
}
int32_t Player::GetCurrentSampleRate() const
{
    if (!startTime_.time_since_epoch().count()) return 0;
    
    auto now = std::chrono::system_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::seconds>(now - startTime_).count();
    if (duration <= 0) return 0;
    return static_cast<int32_t>(GetPlayedSampleCount() / duration);
}

int64_t Player::GetCurrentPosition() const
{
    if (!audioRenderer_ || sampleInfo_.audioSampleRate == 0) {
        OH_LOG_ERROR(LOG_APP, "Audio renderer not initialized or sample rate is 0");
        return 0;
    }
    int64_t framesWritten = 0;
    OH_AudioStream_Result ret = OH_AudioRenderer_GetFramesWritten(audioRenderer_, &framesWritten);
    if (ret != AUDIOSTREAM_SUCCESS) {
        OH_LOG_ERROR(LOG_APP, "Get frames written failed: %{public}d", ret);
        return 0;
    }
    return (framesWritten * ONE_THOUSANDONE) / sampleInfo_.audioSampleRate;
}

void Player::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (isReleased_) {
        return;
    }
    
    OH_LOG_INFO(LOG_APP, "Releasing resources");
    isStarted_ = false;
    isPaused_ = false;
    
    pauseCond_.notify_all();
    if (audioDecContext_) {
        audioDecContext_->inputCond.notify_all();
        audioDecContext_->outputCond.notify_all();
        audioDecContext_->renderCond.notify_all();
    }
    
    ReleaseThread();
    
    if (audioRenderer_ != nullptr) {
        OH_AudioRenderer_Stop(audioRenderer_);
        OH_AudioRenderer_Release(audioRenderer_);
        audioRenderer_ = nullptr;
    }
    
    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    
    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    
    if (audioDecContext_ != nullptr) {
        delete audioDecContext_;
        audioDecContext_ = nullptr;
    }
    
    if (builder_ != nullptr) {
        OH_AudioStreamBuilder_Destroy(builder_);
        builder_ = nullptr;
    }
    
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    
    isReleased_ = true;
    OH_LOG_INFO(LOG_APP, "Release() completed");
    
    if (sampleInfo_.playDoneCallback) {
        auto callback = sampleInfo_.playDoneCallback;
        auto data = sampleInfo_.playDoneCallbackData;
        std::thread([callback, data]() {
            OH_LOG_INFO(LOG_APP, "Executing playDone callback");
            callback(data);
        }).detach();
    }
}

void Player::AudioDecInputThread()
{
    while (true) {
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Decoder input thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        pauseCond_.wait(lock, [this] { return !isPaused_ || isReleased_; });
        if (isReleased_) {
            break;
        }
        
        bool condRet = audioDecContext_->inputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->inputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Work done, thread out");
            break;
        }
        if (audioDecContext_->inputBufferInfoQueue.empty()) {
            OH_LOG_INFO(LOG_APP, "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        CodecBufferInfo bufferInfo = audioDecContext_->inputBufferInfoQueue.front();
        audioDecContext_->inputBufferInfoQueue.pop();
        audioDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = audioDecoder_->PushInputBuffer(bufferInfo);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_INFO(LOG_APP, "Push data failed, thread out, ret: %{public}d", ret);
            break;
        }
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            OH_LOG_INFO(LOG_APP, "Catch EOS, thread out");
            break;
        }
    }
}

void Player::AudioDecOutputThread()
{
    isAudioDone.store(false);
    startTime_ = std::chrono::system_clock::now();
    bool eosEncountered = false;
    while (true) {
        if (!isStarted_) { break; }
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        pauseCond_.wait(lock, [this] { return !isPaused_ || isReleased_; });
        if (isReleased_) { break; }
        audioDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) { break; }
        if (audioDecContext_->outputBufferInfoQueue.empty()) { continue; }
        CodecBufferInfo bufferInfo = audioDecContext_->outputBufferInfoQueue.front();
        audioDecContext_->outputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
            eosEncountered = true;
            break;
        }
        audioDecContext_->outputFrameCount++;
        uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        for (int i = 0; i < bufferInfo.attr.size; i++) { audioDecContext_->renderQueue.push(*(source + i)); }
        lock.unlock();
        audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
        std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
        audioDecContext_->renderCond.wait_for(lockRender, 25ms, [this, bufferInfo]() {
            int dynamicBalance = std::min(DEFAULT_BALANCE_FACTOR, MAX_BALANCE_FACTOR);
            return audioDecContext_->renderQueue.size() < dynamicBalance * bufferInfo.attr.size;
        });
    }
    if (eosEncountered) {
        size_t bytesPerSample = (sampleInfo_.audioSampleForamt == OH_BitsPerSample::SAMPLE_S16LE) ? 2 : 1;
        size_t samplesPerChannel = static_cast<size_t>(sampleInfo_.audioSampleRate * 0.2);
        size_t silentSize = samplesPerChannel * sampleInfo_.audioChannelCount * bytesPerSample;
        std::vector<uint8_t> silentData(silentSize, 0);
        std::lock_guard<std::mutex> renderLock(audioDecContext_->renderMutex);
        for (uint8_t byte : silentData) { audioDecContext_->renderQueue.push(byte); }
        audioDecContext_->renderCond.notify_all();
    }
    std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
    bool isQueueEmpty = audioDecContext_->renderCond.wait_for(lockRender, 3s,
    [this]() { return audioDecContext_->renderQueue.empty(); });
    if (!isQueueEmpty) {
        audioDecContext_->renderCond.wait(lockRender, [this]() { return audioDecContext_->renderQueue.empty(); });
    }
    std::this_thread::sleep_for(100ms);
    isAudioDone.store(true);
    doneCond_.notify_one();
}