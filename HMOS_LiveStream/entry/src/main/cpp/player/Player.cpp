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

#include "include/Player.h"
#include <queue>
#include "SampleLog.h"
#include "dfx/error/SampleError.h"

#undef LOG_TAG
#define LOG_TAG "player"

namespace {
constexpr int BALANCE_VALUE = 2;
using namespace std::chrono_literals;
} // namespace

Player::~Player() {}

void Player::SetBgmQueue(AudioBgmQueue *bgmQueue) {
    if (audioDecContext_ && bgmQueue) {
        audioDecContext_->decodedBgmQueue = bgmQueue;
        bgmQueue->Start();
    }
}

int32_t Player::CreateAudioRender(CodecUserData *userData, const AudioInfo &audioInfo) {
    audioRender_->CreateAudioRender(userData, audioInfo);
    return SAMPLE_ERR_OK;
}

int32_t Player::CreateAudioDecoder() {
    SAMPLE_LOGW("audio mime:%{public}s", sampleInfo_.audioInfo.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioInfo.audioCodecMime);
    if (ret != SAMPLE_ERR_OK) {
        SAMPLE_LOGE("Create audio decoder failed, mime:%{public}s", sampleInfo_.audioInfo.audioCodecMime.c_str());
    } else {
        audioDecContext_ = std::make_unique<CodecUserData>();
        audioDecContext_->decodedBgmQueue = nullptr;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_.get());
        CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Audio Decoder config failed");
    }
    return SAMPLE_ERR_OK;
}

int32_t Player::Init(SampleInfo &sampleInfo) {
    std::unique_lock<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && audioDecoder_ == nullptr, SAMPLE_ERR_ERROR, "Already started.");

    sampleInfo_ = sampleInfo;
    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();
    audioRender_ = std::make_unique<AudioRender>();
    isReleased_ = false;
    int32_t ret = demuxer_->Create(sampleInfo_);
    if (ret == SAMPLE_ERR_OK) {
        ret = CreateAudioDecoder();
    } else {
        SAMPLE_LOGE("Create demuxer failed");
    }
    if (ret == SAMPLE_ERR_OK) {
        ret = CreateAudioRender(audioDecContext_.get(), sampleInfo_.audioInfo);
    } else {
        SAMPLE_LOGE("Create audio decoder failed");
    }

    if (ret != SAMPLE_ERR_OK) {
        SAMPLE_LOGE("Create audio render failed");
        doneCond_.notify_all();
        lock.unlock();
        StartRelease();
        return SAMPLE_ERR_ERROR;
    }
    SAMPLE_LOGI("Succeed");
    return SAMPLE_ERR_OK;
}

int32_t Player::Start() {
    std::unique_lock<std::mutex> lock(mutex_);
    int32_t ret;
    CHECK_AND_RETURN_RET_LOG(!isStarted_, SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, SAMPLE_ERR_ERROR, "demuxer_ is nullptr.");
    if (audioDecContext_) {
        ret = audioDecoder_->Start();
        if (ret != SAMPLE_ERR_OK) {
            SAMPLE_LOGE("Audio Decoder start failed");
            lock.unlock();
            StartRelease();
            return SAMPLE_ERR_ERROR;
        }
        isStarted_ = true;
        audioDecInputThread_ = std::make_unique<std::thread>(&Player::AudioDecInputThread, this);
        audioDecOutputThread_ = std::make_unique<std::thread>(&Player::AudioDecOutputThread, this);
        if (audioDecInputThread_ == nullptr || audioDecOutputThread_ == nullptr) {
            SAMPLE_LOGE("Create thread failed");
            lock.unlock();
            StartRelease();
            return SAMPLE_ERR_ERROR;
        }
    }
    // Clear the queue
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    if (audioDecContext_ && audioDecContext_->decodedBgmQueue) {
        audioDecContext_->decodedBgmQueue->Stop();
        audioDecContext_->decodedBgmQueue->Clear();
    }
    if (audioRender_) {
        audioRender_->StartAudioRender();
    }
    SAMPLE_LOGI("Succeed");
    doneCond_.notify_all();
    return SAMPLE_ERR_OK;
}

void Player::StartRelease() {
    std::unique_lock<std::mutex> lock(doneMutex);
    if (audioRender_) {
        audioRender_->StopAudioRender();
    }
    if (!isReleased_) {
        isReleased_ = true;
        Release();
    }
}

void Player::ReleaseThread() {
    if (audioDecInputThread_ && audioDecInputThread_->joinable()) {
        audioDecInputThread_->join();
        audioDecInputThread_.reset();
    }
    if (audioDecOutputThread_ && audioDecOutputThread_->joinable()) {
        audioDecOutputThread_->join();
        audioDecOutputThread_.reset();
    }
}

void Player::WaitForStop() {
    isStarted_ = false;
    // Wake up waiting threads to check exit condition
    if (audioDecContext_) {
        audioDecContext_->inputCond.notify_all();
        audioDecContext_->outputCond.notify_all();
        audioDecContext_->renderCond.notify_all();
    }
    StartRelease();
}

void Player::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;

    audioRender_->ReleaseAudioRender();
    ReleaseThread();

    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    doneCond_.notify_all();
    // Clear the queue
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    SAMPLE_LOGI("Succeed");
}

void Player::AudioDecInputThread() {
    while (isStarted_) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        bool condRet = audioDecContext_->inputCond.wait_for(
            lock, 100ms, [this]() { return !isStarted_ || !audioDecContext_->inputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!audioDecContext_->inputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioDecContext_->inputBufferInfoQueue.front();
        audioDecContext_->inputBufferInfoQueue.pop();
        audioDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = audioDecoder_->PushInputBuffer(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == SAMPLE_ERR_OK, "Push data failed, thread out");

        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
    }
}

void Player::AudioDecOutputThread() {
    isAudioDone = false;
    while (isStarted_) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        bool condRet = audioDecContext_->outputCond.wait_for(
            lock, 100ms, [this]() { return !isStarted_ || !audioDecContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!audioDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioDecContext_->outputBufferInfoQueue.front();
        audioDecContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        audioDecContext_->outputFrameCount++;
        SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                    audioDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                    bufferInfo.attr.pts);
        uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        // Put the decoded PMC data into the queue
        for (int i = 0; i < bufferInfo.attr.size; i++) {
            audioDecContext_->renderQueue.push(*(source + i));
        }
        int16_t *pcmData = (int16_t *)source;
        if (audioDecContext_->decodedBgmQueue) {
            audioDecContext_->decodedBgmQueue->push(pcmData, bufferInfo.attr.size / 2);
        }
        lock.unlock();

        int32_t ret = audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
        CHECK_AND_BREAK_LOG(ret == SAMPLE_ERR_OK, "Decoder output thread out");

        std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
        audioDecContext_->renderCond.wait_for(lockRender, 20ms, [this, bufferInfo]() {
            return audioDecContext_->renderQueue.size() < BALANCE_VALUE * bufferInfo.attr.size || !isStarted_;
        });
    }
    std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
    audioDecContext_->renderCond.wait_for(lockRender, 500ms,
                                          [this]() { return audioDecContext_->renderQueue.size() < 1 || !isStarted_; });
    isAudioDone = true;
    SAMPLE_LOGI("Out buffer end");
}
