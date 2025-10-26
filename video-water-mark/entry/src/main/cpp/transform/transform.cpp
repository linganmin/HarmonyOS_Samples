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

#include "transform.h"
#include "av_codec_sample_log.h"
#include "dfx/error/av_codec_sample_error.h"
#include <cstdint>
#include "plugin_render.h"

#undef LOG_TAG
#define LOG_TAG "Transform"

namespace {
constexpr int BALANCE_VALUE = 5;
using namespace std::chrono_literals;
static const int MS_TO_S = 1000;
constexpr int64_t WAIT_TIME_US_THRESHOLD_WARNING = -1 * 40 * 1000; // warning threshold 40ms
constexpr int64_t WAIT_TIME_US_THRESHOLD = 1 * 1000 * 1000;        // max sleep time 1s
constexpr int64_t SINK_TIME_US_THRESHOLD = 100000;                 // max sink time 100ms
constexpr int32_t BYTES_PER_SAMPLE_2 = 2;                          // 2 bytes per sample
constexpr double VSYNC_TIME = 1000 / 60;                           // frame time
constexpr double LIP_SYNC_BALANCE_VALUE = 2;                       // the balance value of sync sound and picture
} // namespace

Transform::~Transform() {
    Transform::StartDecRelease();
    Transform::StartEncRelease();
}

bool Transform::GetIsDecStarted() {
    return isDecStarted_;
}

bool Transform::GetIsEncStarted() {
    return isEncStarted_;
}

SampleInfo* Transform::GetSampleInfo() {
    return &sampleInfo_;
}

void Transform::SetNativeImageWindow(OHNativeWindow * nativeImageWindow) {
    sampleInfo_.nativeImageWindow = nativeImageWindow;
}

void Transform::NotifyEndOfStream() {
    videoEncoder_->NotifyEndOfStream();
}

int32_t Transform::PreInit(const SampleInfo &sampleInfo) {
    std::unique_lock<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");

    sampleInfo_ = sampleInfo;
    int32_t ret = MuxerAndDemuxerInit(sampleInfo_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create MuxerAndDemuxerInit failed");
    ret = EncoderInit(sampleInfo_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create EncoderInit failed");

    isEncReleased_ = false;
    isDecReleased_ = false;
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Transform::EncoderInit(SampleInfo &sampleInfo) {
    videoEncoder_ = std::make_unique<VideoEncoder>();
    int32_t ret = videoEncoder_->Create(sampleInfo.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create videoEncoder_ failed");
    videoEncContext_ = new CodecUserData();
    ret = videoEncoder_->Config(sampleInfo, videoEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create videoEncContext_ failed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Transform::MuxerAndDemuxerInit(SampleInfo &sampleInfo) {
    muxer_ = std::make_unique<Muxer>();
    int32_t ret = muxer_->Create(sampleInfo.outputFd);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create muxer failed");
    
    demuxer_ = std::make_unique<Demuxer>();
    ret = demuxer_->Create(sampleInfo);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create demuxer failed");
    muxer_->Config(sampleInfo);
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

int32_t Transform::AfterInit() {
    int32_t ret = CreateVideoDecoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Decoder config failed");
    
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}


int32_t Transform::Start() {
    std::unique_lock<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr && videoDecoder_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                             "Already started.");
    int32_t ret;
    if (videoDecContext_) {
        ret = videoDecoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Decoder start failed");
        isDecStarted_ = true;
        videoDecInputThread_ = std::make_unique<std::thread>(&Transform::VideoDecInputThread, this);
        videoDecOutputThread_ = std::make_unique<std::thread>(&Transform::VideoDecOutputThread, this);
        if (videoDecInputThread_ == nullptr || videoDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartDecRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    
    if (videoEncContext_) {
        ret = muxer_->Start();
        ret = videoEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder start failed");
        isEncStarted_ = true;
        videoEncOutputThread_ = std::make_unique<std::thread>(&Transform::VideoEncOutputThread, this);
        if (videoEncOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartEncRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}

void Transform::StartDecRelease() {
    if (!isDecReleased_) {
        isDecReleased_ = true;
        DecRelease();
    }
}

void Transform::DecRelease() {
    isDecStarted_ = false;
    AVCODEC_SAMPLE_LOGI("DecRelease Succeed： %{public}d, %{public}d", isDecStarted_.load(), isEncStarted_.load());
    if (videoDecInputThread_ && videoDecInputThread_->joinable()) {
        videoDecContext_->inputCond_.notify_all();
        videoDecInputThread_->join();
        videoDecInputThread_.reset();
    }
    if (videoDecOutputThread_ && videoDecOutputThread_->joinable()) {
        videoDecContext_->outputCond_.notify_all();
        videoDecOutputThread_->detach();
        videoDecOutputThread_.reset();
    }
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

    AVCODEC_SAMPLE_LOGI("DecRelease Succeed");
}

void Transform::StartEncRelease() {
    if (!isEncReleased_) {
        isEncReleased_ = true;
        EncRelease();
    }
}

void Transform::EncRelease() {
    isEncStarted_ = false;
    if (videoEncOutputThread_ && videoEncOutputThread_->joinable()) {
        videoEncOutputThread_->detach();
        videoEncOutputThread_.reset();
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
    }
    if (videoEncContext_ != nullptr) {
        delete videoEncContext_;
        videoEncContext_ = nullptr;
    }
    std::string id("Transform");
    NativeXComponentSample::PluginRender::TransformRelease(id);
    AVCODEC_SAMPLE_LOGI("EncRelease Succeed");
    sampleInfo_.playDoneCallback(sampleInfo_.playDoneCallbackData);
}

void Transform::VideoDecInputThread() {
    while (true) {
        CHECK_AND_BREAK_LOG(isDecStarted_, "Decoder input thread out");
        std::unique_lock<std::mutex> lock(videoDecContext_->inputMutex_);
        bool condRet = videoDecContext_->inputCond_.wait_for(
            lock, 5s, [this]() { return !isDecStarted_ || !videoDecContext_->inputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isDecStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->inputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->inputBufferInfoQueue_.front();
        videoDecContext_->inputBufferInfoQueue_.pop();
        videoDecContext_->inputFrameCount_++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = videoDecoder_->PushInputBuffer(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Push data failed, thread out");
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS),
                            "VideoDecInputThread Catch EOS, thread out");
    }
}

void Transform::VideoDecOutputThread() {
    sampleInfo_.frameInterval = MICROSECOND_TO_S / sampleInfo_.frameRate;
    while (true) {
        CHECK_AND_BREAK_LOG(isDecStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(videoDecContext_->outputMutex_);
        bool condRet = videoDecContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isDecStarted_ || !videoDecContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isDecStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->outputBufferInfoQueue_.front();
        videoDecContext_->outputBufferInfoQueue_.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        videoDecContext_->outputFrameCount_++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            videoDecContext_->outputFrameCount_, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();
        
        
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            AVCODEC_SAMPLE_LOGW("VideoDecOutputThread Catch EOS, thread out" PRId64);
            videoDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, false);
            break;
        } else {
            int32_t ret = videoDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, true);
            CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Decoder output thread");
        }
    }
    StartDecRelease();
}


void Transform::VideoEncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isEncStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(videoEncContext_->outputMutex_);
        bool condRet = videoEncContext_->outputCond_.wait_for(
            lock, 5s, [this]() { return !isEncStarted_ || !videoEncContext_->outputBufferInfoQueue_.empty(); });
        CHECK_AND_BREAK_LOG(isEncStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoEncContext_->outputBufferInfoQueue_.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoEncContext_->outputBufferInfoQueue_.front();
        videoEncContext_->outputBufferInfoQueue_.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        lock.unlock();

        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            videoEncContext_->outputFrameCount_++;
            bufferInfo.attr.pts = videoEncContext_->outputFrameCount_ * 1000000 / sampleInfo_.frameRate;
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
    StartEncRelease();
}

int32_t Transform::CreateVideoDecoder() {
    videoDecoder_ = std::make_unique<VideoDecoder>();
    int ret = videoDecoder_->Create(sampleInfo_.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video decoder failed");

    videoDecContext_ = new CodecUserData;
    ret = videoDecoder_->Config(sampleInfo_, videoDecContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Decoder config failed");
    return AVCODEC_SAMPLE_ERR_OK;
}
