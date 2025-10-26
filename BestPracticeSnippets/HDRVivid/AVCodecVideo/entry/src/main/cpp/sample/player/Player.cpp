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

#include "Player.h"
#include <queue>
#include "AVCodecSampleLog.h"
#include "dfx/error/AVCodecSampleError.h"

#undef LOG_TAG
#define LOG_TAG "player"

namespace {
constexpr int BALANCE_VALUE = 5;
using namespace std::chrono_literals;
} // namespace

Player::~Player() { Player::StartRelease(); }

int32_t Player::CreateAudioDecoder() {
    AVCODEC_SAMPLE_LOGW("audio mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        AVCODEC_SAMPLE_LOGE("Create audio decoder failed, mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    } else {
        audioDecContext_ = new CodecUserData;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_);
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Audio Decoder config failed");
        OH_AudioStreamBuilder_Create(&builder_, AUDIOSTREAM_TYPE_RENDERER);
        OH_AudioStreamBuilder_SetLatencyMode(builder_, AUDIOSTREAM_LATENCY_MODE_NORMAL);
        // Set the audio sample rate
        OH_AudioStreamBuilder_SetSamplingRate(builder_, sampleInfo_.audioSampleRate);
        // Set the audio channel
        OH_AudioStreamBuilder_SetChannelCount(builder_, sampleInfo_.audioChannelCount);
        // Set the audio sample format
        OH_AudioStreamBuilder_SetSampleFormat(builder_, AUDIOSTREAM_SAMPLE_S16LE);
        // Sets the encoding type of the audio stream
        OH_AudioStreamBuilder_SetEncodingType(builder_, AUDIOSTREAM_ENCODING_TYPE_RAW);
        // Set the working scenario for the output audio stream
        OH_AudioStreamBuilder_SetRendererInfo(builder_, AUDIOSTREAM_USAGE_MUSIC);
        AVCODEC_SAMPLE_LOGW("Init audioSampleRate: %{public}d, ChannelCount: %{public}d", sampleInfo_.audioSampleRate,
                            sampleInfo_.audioChannelCount);
        OH_AudioRenderer_Callbacks callbacks;
        // Configure the callback function
#ifndef DEBUG_DECODE
        callbacks.OH_AudioRenderer_OnWriteData = SampleCallback::OnRenderWriteData;
#else
        callbacks.OH_AudioRenderer_OnWriteData = nullptr;
#endif
        callbacks.OH_AudioRenderer_OnStreamEvent = SampleCallback::OnRenderStreamEvent;
        callbacks.OH_AudioRenderer_OnInterruptEvent = SampleCallback::OnRenderInterruptEvent;
        callbacks.OH_AudioRenderer_OnError = SampleCallback::OnRenderError;
        // Set the callback for the output audio stream
        OH_AudioStreamBuilder_SetRendererCallback(builder_, callbacks, audioDecContext_);
        OH_AudioStreamBuilder_GenerateRenderer(builder_, &audioRenderer_);
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::CreateVideoDecoder() {
    AVCODEC_SAMPLE_LOGW("video mime:%{public}s", sampleInfo_.videoCodecMime.c_str());
    int32_t ret = videoDecoder_->Create(sampleInfo_.videoCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        AVCODEC_SAMPLE_LOGW("Create video decoder failed, mime:%{public}s", sampleInfo_.videoCodecMime.c_str());
    } else {
        videoDecContext_ = new CodecUserData;
        sampleInfo_.window = NativeXComponentSample::PluginManager::GetInstance()->pluginWindow_;
        ret = videoDecoder_->Config(sampleInfo_, videoDecContext_);
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Video Decoder config failed");
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::Init(SampleInfo &sampleInfo) {
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr && audioDecoder_ == nullptr,
                             AVCODEC_SAMPLE_ERR_ERROR, "Already started.");

    sampleInfo_ = sampleInfo;

    videoDecoder_ = std::make_unique<VideoDecoder>();
    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();

    int32_t ret = demuxer_->Create(sampleInfo_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create demuxer failed");

    ret = CreateAudioDecoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio decoder failed");

    ret = CreateVideoDecoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video decoder failed");

    isReleased_ = false;
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Player::Start() {
    std::lock_guard<std::mutex> lock(mutex_);
    int32_t ret;
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    if (videoDecContext_) {
        ret = videoDecoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Video Decoder start failed");
        isStarted_ = true;
        videoDecInputThread_ = std::make_unique<std::thread>(&Player::VideoDecInputThread, this);
        videoDecOutputThread_ = std::make_unique<std::thread>(&Player::VideoDecOutputThread, this);

        if (videoDecInputThread_ == nullptr || videoDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    if (audioDecContext_) {
        ret = audioDecoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Audio Decoder start failed");
        isStarted_ = true;
        audioDecInputThread_ = std::make_unique<std::thread>(&Player::AudioDecInputThread, this);
        audioDecOutputThread_ = std::make_unique<std::thread>(&Player::AudioDecOutputThread, this);
#ifdef DEBUG_DECODE
        // for debug The decoded data is written to the sandbox address, and the physical address is
        // /data/app/el2/100/base/com.example.avcodecsample/haps/entry/files/
        audioOutputFile_.open("/data/storage/el2/base/haps/entry/files/audio_decode_out.pcm",
                              std::ios::out | std::ios::binary);
#endif
        if (audioDecInputThread_ == nullptr || audioDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    // Clear the queue
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    if (audioRenderer_) {
        OH_AudioRenderer_Start(audioRenderer_);
    }
    AVCODEC_SAMPLE_LOGI("Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}

void Player::StartRelease() {
    if (audioRenderer_) {
        OH_AudioRenderer_Stop(audioRenderer_);
    }
    if (!isReleased_) {
        isReleased_ = true;
        Release();
    }
}

void Player::ReleaseThread() {
    if (videoDecInputThread_ && videoDecInputThread_->joinable()) {
        videoDecInputThread_->detach();
        videoDecInputThread_.reset();
    }
    if (videoDecOutputThread_ && videoDecOutputThread_->joinable()) {
        videoDecOutputThread_->detach();
        videoDecOutputThread_.reset();
    }
    if (audioDecInputThread_ && audioDecInputThread_->joinable()) {
        audioDecInputThread_->detach();
        audioDecInputThread_.reset();
    }
    if (audioDecOutputThread_ && audioDecOutputThread_->joinable()) {
        audioDecOutputThread_->detach();
        audioDecOutputThread_.reset();
    }
}

void Player::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;

    // Clear the queue
    while (audioDecContext_ && !audioDecContext_->renderQueue.empty()) {
        audioDecContext_->renderQueue.pop();
    }
    if (audioRenderer_ != nullptr) {
        OH_AudioRenderer_Release(audioRenderer_);
        audioRenderer_ = nullptr;
    }
#ifdef DEBUG_DECODE
    if (audioOutputFile_.is_open()) {
        audioOutputFile_.close();
    }
#endif
    ReleaseThread();

    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (videoDecoder_ != nullptr) {
        videoDecoder_->Release();
        videoDecoder_.reset();
    }
    if (videoDecContext_ != nullptr) {
        delete videoDecContext_;
        videoDecContext_ = nullptr;
    }
    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    if (audioDecContext_ != nullptr) {
        delete audioDecContext_;
        audioDecContext_ = nullptr;
    }
    OH_AudioStreamBuilder_Destroy(builder_);
    builder_ = nullptr;
    doneCond_.notify_all();
    // Trigger the callback
    sampleInfo_.playDoneCallback(sampleInfo_.playDoneCallbackData);
    AVCODEC_SAMPLE_LOGI("Succeed");
}

void Player::VideoDecInputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        std::unique_lock<std::mutex> lock(videoDecContext_->inputMutex);
        bool condRet = videoDecContext_->inputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoDecContext_->inputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->inputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->inputBufferInfoQueue.front();
        videoDecContext_->inputBufferInfoQueue.pop();
        videoDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = videoDecoder_->PushInputBuffer(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");

        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
    }
}

void Player::VideoDecOutputThread() {
    sampleInfo_.frameInterval = MICROSECOND / sampleInfo_.frameRate;
    while (true) {
        thread_local auto lastPushTime = std::chrono::system_clock::now();
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(videoDecContext_->outputMutex);
        bool condRet = videoDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoDecContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->outputBufferInfoQueue.front();
        videoDecContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        videoDecContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            videoDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();

        int32_t ret = videoDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Decoder output thread out");

        std::this_thread::sleep_until(lastPushTime + std::chrono::microseconds(sampleInfo_.frameInterval));
        lastPushTime = std::chrono::system_clock::now();
    }
    StartRelease();
}

void Player::AudioDecInputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder input thread out");
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        bool condRet = audioDecContext_->inputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->inputBufferInfoQueue.empty(); });
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
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");

        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
    }
}

void Player::AudioDecOutputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        bool condRet = audioDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!audioDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioDecContext_->outputBufferInfoQueue.front();
        audioDecContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        audioDecContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            audioDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        // Put the decoded PMC data into the queue
        for (int i = 0; i < bufferInfo.attr.size; i++) {
            audioDecContext_->renderQueue.push(*(source + i));
        }
#ifdef DEBUG_DECODE
        if (audioOutputFile_.is_open()) {
            audioOutputFile_.write(
                (const char *)OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer)),
                bufferInfo.attr.size);
        }
#endif
        lock.unlock();

        int32_t ret = audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Decoder output thread out");

        std::unique_lock<std::mutex> lockRender(audioDecContext_->renderMutex);
        audioDecContext_->renderCond.wait_for(lockRender, 20ms, [this, bufferInfo]() {
            return audioDecContext_->renderQueue.size() < BALANCE_VALUE * bufferInfo.attr.size;
        });
    }
    AVCODEC_SAMPLE_LOGI("Out buffer end");
    StartRelease();
}