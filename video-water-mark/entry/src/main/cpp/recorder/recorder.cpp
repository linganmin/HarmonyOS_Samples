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

#include "recorder.h"
#include "av_codec_sample_log.h"
#include "dfx/error/av_codec_sample_error.h"
#include <cstdint>
#include "config/config.h"
#include "file/file.h"

#undef LOG_TAG
#define LOG_TAG "recorder"

namespace {
using namespace std::chrono_literals;
constexpr int64_t MICROSECOND = 1000000;
}

Recorder::~Recorder()
{
    StartRelease();
}

int32_t Recorder::Init(SampleInfo &sampleInfo)
{
    std::lock_guard<std::mutex> lock(mutex_);

    sampleInfo_ = sampleInfo;

    videoEncoder_ = std::make_unique<VideoEncoder>();
    audioEncoder_ = std::make_unique<AudioEncoder>();
    muxer_ = std::make_unique<Muxer>();
    audioCapturer_ = std::make_unique<AudioCapturer>();

    int32_t ret = muxer_->Create(sampleInfo_.outputFd);
    ret = muxer_->Config(sampleInfo_);

    if (AppConfig::GetInstance().GetAudioValue()) {
        ret = CreateAudioEncoder();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio encoder failed");

        // Audio collection initialization
        audioCapturer_->AudioCapturerInit(sampleInfo_, audioEncContext_);
    }

    ret = CreateVideoEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");
    sampleInfo.window = sampleInfo_.window;

    releaseThread_ = nullptr;
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Start()
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncContext_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr && muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    int32_t ret = muxer_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Muxer start failed");

    if (videoEncContext_) {
        ret = videoEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder start failed");

        isStarted_ = true;
        videoEncOutputThread_ = std::make_unique<std::thread>(&Recorder::VideoEncOutputThread, this);
        if (videoEncOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }

    if (audioEncContext_) {
        // Start audio collection
        audioCapturer_->AudioCapturerStart();

        ret = audioEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Audio Encoder start failed");
        isStarted_ = true;
        audioEncInputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncInputThread, this);
        audioEncOutputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncOutputThread, this);
        if (audioEncInputThread_ == nullptr || audioEncOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }

        // Clear the playback cache queue
        if (audioEncContext_ != nullptr) {
            audioEncContext_->ClearCache();
        }
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

void Recorder::VideoEncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(videoEncContext_->outputMutex_);
        bool condRet = videoEncContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoEncContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoEncContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoEncContext_->outputBufferInfoQueue_.front();
        videoEncContext_->outputBufferInfoQueue_.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        lock.unlock();

        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            videoEncContext_->outputFrameCount_++;
            bufferInfo.attr.pts = videoEncContext_->outputFrameCount_ * MICROSECOND / sampleInfo_.frameRate;
        } else {
            bufferInfo.attr.pts = 0;
        }
        AVCODEC_SAMPLE_LOGD("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            videoEncContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", videoEncContext_->inputFrameCount_);
    StartRelease();
}

void Recorder::StartRelease()
{
    if (releaseThread_ == nullptr) {
        AVCODEC_SAMPLE_LOGI("Start release CodecTest");
        releaseThread_ = std::make_unique<std::thread>(&Recorder::Release, this);
    }
}

void Recorder::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (videoEncOutputThread_ && videoEncOutputThread_->joinable()) {
        videoEncContext_->outputCond_.notify_all();
        videoEncOutputThread_->join();
        videoEncOutputThread_.reset();
    }
    if (audioEncInputThread_ && audioEncInputThread_->joinable()) {
        audioEncContext_->inputCond_.notify_all();
        audioEncInputThread_->join();
        audioEncInputThread_.reset();
    }
    if (audioEncOutputThread_ && audioEncOutputThread_->joinable()) {
        audioEncContext_->outputCond_.notify_all();
        audioEncOutputThread_->join();
        audioEncOutputThread_.reset();
    }

    if (muxer_ != nullptr) {
        muxer_->Release();
        muxer_.reset();
        AVCODEC_SAMPLE_LOGI("Muxer release successful");
    }
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        videoEncoder_->Release();
        videoEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Video encoder release successful");
    }
    if (audioEncoder_ != nullptr) {
        audioEncoder_->Stop();
        audioEncoder_->Release();
        audioEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Audio encoder release successful");
    }
    if (audioCapturer_ != nullptr) {
        audioCapturer_->AudioCapturerRelease();
        audioCapturer_.reset();
        AVCODEC_SAMPLE_LOGI("Audio Capturer release successful");
    }
    if (audioEncContext_ != nullptr) {
        delete audioEncContext_;
        audioEncContext_ = nullptr;
    }
    if (videoEncContext_ != nullptr) {
        delete videoEncContext_;
        videoEncContext_ = nullptr;
    }
    doneCond_.notify_all();
    AVCODEC_SAMPLE_LOGI("Succeed");
}

int32_t Recorder::WaitForDone()
{
    AVCODEC_SAMPLE_LOGI("Wait called");
    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock);
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }
    AVCODEC_SAMPLE_LOGI("Done");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::Stop()
{
    if (!isStarted_) {
        return AVCODEC_SAMPLE_ERR_OK;
    }

    int32_t ret = videoEncoder_->NotifyEndOfStream();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder notifyEndOfStream failed");
    return WaitForDone();
}

int32_t Recorder::CreateAudioEncoder()
{
    int32_t ret = audioEncoder_->Create(sampleInfo_.audioCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio encoder(%{public}s) failed",
                             sampleInfo_.audioCodecMime.c_str());
    AVCODEC_SAMPLE_LOGI("Create audio encoder(%{public}s)", sampleInfo_.audioCodecMime.c_str());

    audioEncContext_ = new CodecUserData;
    ret = audioEncoder_->Config(sampleInfo_, audioEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Recorder::CreateVideoEncoder()
{
    int32_t ret = videoEncoder_->Create(sampleInfo_.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");

    videoEncContext_ = new CodecUserData;
    ret = videoEncoder_->Config(sampleInfo_, videoEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

void Recorder::AudioEncInputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Encoder input thread out");
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex_);
        bool condRet = audioEncContext_->inputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || (!audioEncContext_->inputBufferInfoQueue_.empty() && (audioEncContext_->remainlen_ >= sampleInfo_.audioMaxInputSize)); });

        CHECK_AND_CONTINUE_LOG(!audioEncContext_->inputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        if (isStarted_ && audioEncContext_->remainlen_ < sampleInfo_.audioMaxInputSize) {
            continue;
        }

        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue_.front();
        audioEncContext_->inputBufferInfoQueue_.pop();
        audioEncContext_->inputFrameCount_++;

        uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        audioEncContext_->ReadCache(inputBufferAddr, sampleInfo_.audioMaxInputSize);
        lock.unlock();

        bufferInfo.attr.size = sampleInfo_.audioMaxInputSize;
        bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_NONE;
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");
    }
}

void Recorder::AudioEncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex_);
        bool condRet = audioEncContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!audioEncContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue_.front();
        audioEncContext_->outputBufferInfoQueue_.pop();
        audioEncContext_->outputFrameCount_++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            audioEncContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();
        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", audioEncContext_->inputFrameCount_);
    StartRelease();
}