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

#include "Transcoding.h"
#include "AVCodecSampleLog.h"
#include "dfx/error/AVCodecSampleError.h"
#include "multimedia/player_framework/native_avbuffer.h"
#include <queue>

#undef LOG_TAG
#define LOG_TAG "transcoding"

namespace {
constexpr int BALANCE_VALUE = 2;
using namespace std::chrono_literals;
constexpr int8_t YUV420_SAMPLE_RATIO = 2;
} // namespace

Transcoding::~Transcoding() { Transcoding::StartRelease(); }

// [Start create_decoder]
int32_t Transcoding::CreateVideoDecoder() {
    AVCODEC_SAMPLE_LOGW("video mime:%{public}s", sampleInfo_.videoCodecMime.c_str());
    int32_t ret = videoDecoder_->Create(sampleInfo_.videoCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        AVCODEC_SAMPLE_LOGW("Create video decoder failed, mime:%{public}s", sampleInfo_.videoCodecMime.c_str());
    } else {
        videoDecContext_ = new CodecUserData;
        ret = videoDecoder_->Config(sampleInfo_, videoDecContext_);
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Video Decoder config failed");
    }
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End create_decoder]

int32_t Transcoding::Init(SampleInfo &sampleInfo) {
    std::unique_lock<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr,
                             AVCODEC_SAMPLE_ERR_ERROR, "Already started.");

    sampleInfo_ = sampleInfo;

    int32_t ret = InitDecoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        AVCODEC_SAMPLE_LOGE("Create video decoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    ret = InitEncoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        AVCODEC_SAMPLE_LOGE("Create video encoder failed");
        doneCond_.notify_all();
        lock.unlock();
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start init_decoder]
int32_t Transcoding::InitDecoder() {
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ == nullptr && videoDecoder_ == nullptr,
                             AVCODEC_SAMPLE_ERR_ERROR, "Already started.");

    videoDecoder_ = std::make_unique<VideoDecoder>();
    demuxer_ = std::make_unique<Demuxer>();

    isReleased_ = false;
    int32_t ret = demuxer_->Create(sampleInfo_);

    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        ret = CreateVideoDecoder();
    } else {
        AVCODEC_SAMPLE_LOGE("Create audio decoder failed");
    }
    return ret;
}
// [End init_decoder]

int32_t Transcoding::CreateVideoEncoder() {
    int32_t ret = videoEncoder_->Create(sampleInfo_.outputVideoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");

    videoEncContext_ = new CodecUserData;
    ret = videoEncoder_->Config(sampleInfo_, videoEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder config failed");

    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start init_encoder]
int32_t Transcoding::InitEncoder() {
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(muxer_ == nullptr && videoEncoder_ == nullptr,
                             AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    
    videoEncoder_ = std::make_unique<VideoEncoder>();
    muxer_ = std::make_unique<Muxer>();
    
    int32_t ret = muxer_->Create(sampleInfo_.outputFd);
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create muxer with fd(%{public}d) failed",
                             sampleInfo_.outputFd);
    ret = muxer_->Config(sampleInfo_);
    
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create audio encoder failed");

    ret = CreateVideoEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Create video encoder failed");
    
    AVCODEC_SAMPLE_LOGI("Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End init_encoder]

// [Start start_transcoding]
int32_t Transcoding::Start() {
    std::unique_lock<std::mutex> lock(mutex_);
    int32_t ret;
    CHECK_AND_RETURN_RET_LOG(!isStarted_, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(demuxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR, "Already started.");
    if (videoDecContext_) {
        ret = videoDecoder_->Start();
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            AVCODEC_SAMPLE_LOGE("Video Decoder start failed");
            lock.unlock();
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
        isStarted_ = true;
        videoDecInputThread_ = std::make_unique<std::thread>(&Transcoding::VideoDecInputThread, this);
        videoDecOutputThread_ = std::make_unique<std::thread>(&Transcoding::VideoDecOutputThread, this);

        if (videoDecInputThread_ == nullptr || videoDecOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            lock.unlock();
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }

    if (videoEncContext_) {
        CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr && muxer_ != nullptr, AVCODEC_SAMPLE_ERR_ERROR,
                                 "Already started.");
        int32_t ret = muxer_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Muxer start failed");
        ret = videoEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == AVCODEC_SAMPLE_ERR_OK, ret, "Encoder start failed");
        videoEncOutputThread_ = std::make_unique<std::thread>(&Transcoding::VideoEncOutputThread, this);
        if (videoEncOutputThread_ == nullptr) {
            AVCODEC_SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return AVCODEC_SAMPLE_ERR_ERROR;
        }
    }
    
    AVCODEC_SAMPLE_LOGI("Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End start_transcoding]

void Transcoding::Stop() {
    StartRelease();
}

void Transcoding::StartRelease() {
    if (!isReleased_) {
        isReleased_ = true;
        Release();
    }
    AVCODEC_SAMPLE_LOGI("StartRelease Done");
}

void Transcoding::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (videoDecInputThread_ && videoDecInputThread_->joinable()) {
        videoDecInputThread_->detach();
        videoDecInputThread_.reset();
    }
    if (videoDecOutputThread_ && videoDecOutputThread_->joinable()) {
        videoDecOutputThread_->detach();
        videoDecOutputThread_.reset();
    }
    if (videoEncOutputThread_ && videoEncOutputThread_->joinable()) {
        videoEncOutputThread_->detach();
        videoEncOutputThread_.reset();
    }
    if (muxer_ != nullptr) {
        muxer_->Release();
        muxer_.reset();
        AVCODEC_SAMPLE_LOGI("Muxer release successful");
    }
    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    if (videoDecoder_ != nullptr) {
        videoDecoder_->Release();
        videoDecoder_.reset();
    }
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        videoEncoder_->Release();
        videoEncoder_.reset();
        AVCODEC_SAMPLE_LOGI("Video encoder release successful");
    }
    if (videoEncContext_ != nullptr) {
        delete videoEncContext_;
        videoEncContext_ = nullptr;
    }
    if (videoDecContext_ != nullptr) {
        delete videoDecContext_;
        videoDecContext_ = nullptr;
    }
    doneCond_.notify_all();
    sampleInfo_.playDoneCallback(sampleInfo_.playDoneCallbackData);
    AVCODEC_SAMPLE_LOGI("Release Succeed");
}

// [Start copy_yuv]
void Transcoding::CopyStrideYUV420SP(CodecBufferInfo &encBufferInfo, CodecBufferInfo &bufferInfo) {
    int32_t videoWidth = videoDecContext_->width;
    int32_t &stride = videoDecContext_->widthStride;
    int32_t size = 0;
    uint8_t *tempBufferAddr = encBufferInfo.bufferAddr;

    size += videoDecContext_->height * videoWidth * 3 / 2;
    if (videoWidth == videoDecContext_->widthStride && videoDecContext_->heightStride == videoDecContext_->height) {
        std::memcpy(tempBufferAddr, bufferInfo.bufferAddr, size);
    } else {
        // copy Y
        for (int32_t row = 0; row < videoDecContext_->height; row++) {
            std::memcpy(tempBufferAddr, bufferInfo.bufferAddr, videoWidth);
            tempBufferAddr += videoWidth;
            bufferInfo.bufferAddr += stride;
        }
        bufferInfo.bufferAddr += (videoDecContext_->heightStride - videoDecContext_->height) * stride;

        // copy U/V
        for (int32_t row = 0; row < (videoDecContext_->height / 2); row++) {
            std::memcpy(tempBufferAddr, bufferInfo.bufferAddr, videoWidth);
            tempBufferAddr += videoWidth;
            bufferInfo.bufferAddr += stride;
        }
    }
    
    encBufferInfo.attr.size = size;
    encBufferInfo.attr.flags = bufferInfo.attr.flags;
    encBufferInfo.attr.offset = bufferInfo.attr.offset;
    encBufferInfo.attr.pts = bufferInfo.attr.pts;

    tempBufferAddr = nullptr;
    delete tempBufferAddr;
}
// [End copy_yuv]

// [Start start_decoder_input_thread]
void Transcoding::VideoDecInputThread() {
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

        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS),
                            "VideoDecInputThread Catch EOS, thread out");
    }
}
// [End start_decoder_input_thread]

// [Start start_decoder_output_thread]
void Transcoding::VideoDecOutputThread() {
    sampleInfo_.frameInterval = MICROSECOND / sampleInfo_.frameRate;
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        std::unique_lock<std::mutex> lock(videoDecContext_->outputMutex);
        bool condRet = videoDecContext_->outputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ ||
                   !(videoDecContext_->outputBufferInfoQueue.empty() && videoEncContext_->inputBufferInfoQueue.empty());
        });
        CHECK_AND_BREAK_LOG(isStarted_, "Decoder output thread out");
        CHECK_AND_CONTINUE_LOG(!videoDecContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
        CHECK_AND_CONTINUE_LOG(!videoEncContext_->inputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoDecContext_->outputBufferInfoQueue.front();
        videoDecContext_->outputBufferInfoQueue.pop();
        videoDecContext_->outputFrameCount++;
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            videoDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);
        lock.unlock();

        // get Buffer from inputBufferInfoQueue
        CodecBufferInfo encBufferInfo = videoEncContext_->inputBufferInfoQueue.front();
        videoEncContext_->inputBufferInfoQueue.pop();
        videoEncContext_->inputFrameCount++;
        
        AVCODEC_SAMPLE_LOGW(
            "Out bufferInfo flags: %{public}u, offset: %{public}d, pts: %{public}u, size: %{public}" PRId64,
            bufferInfo.attr.flags, bufferInfo.attr.offset, bufferInfo.attr.pts, bufferInfo.attr.size);


        encBufferInfo.bufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(encBufferInfo.buffer));
        bufferInfo.bufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        CopyStrideYUV420SP(encBufferInfo, bufferInfo);

        AVCODEC_SAMPLE_LOGW(
            "Out encBufferInfo flags: %{public}u, offset: %{public}d, pts: %{public}u, size: %{public}d" PRId64,
            encBufferInfo.attr.flags, encBufferInfo.attr.offset, encBufferInfo.attr.pts, encBufferInfo.attr.size);

        OH_AVBuffer_SetBufferAttr(reinterpret_cast<OH_AVBuffer *>(encBufferInfo.buffer), &encBufferInfo.attr);

        // Free Decoder's output buffer
        int32_t ret = videoDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex, false);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Decoder output thread out");

        // Push input buffer to Encoder
        videoEncoder_->PushInputBuffer(encBufferInfo);

        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            AVCODEC_SAMPLE_LOGW("VideoDecOutputThread Catch EOS, thread out" PRId64);
            break;
        }
    }
}
// [End start_decoder_output_thread]

// [Start start_Encoder_output_thread]
void Transcoding::VideoEncOutputThread() {
    while (true) {
        std::unique_lock<std::mutex> lock(videoEncContext_->outputMutex);
        bool condRet = videoEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoEncContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!videoEncContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = videoEncContext_->outputBufferInfoQueue.front();
        videoEncContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS),
                            "VideoEncOutputThread  Catch EOS, thread out");
        lock.unlock();
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            videoEncContext_->outputFrameCount++;
            bufferInfo.attr.pts = videoEncContext_->outputFrameCount * MICROSECOND / sampleInfo_.frameRate;
        } else {
            bufferInfo.attr.pts = 0;
        }
        AVCODEC_SAMPLE_LOGW("Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            videoEncContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == AVCODEC_SAMPLE_ERR_OK, "Encoder output thread out");
    }
    AVCODEC_SAMPLE_LOGI("Exit, frame count: %{public}u", videoEncContext_->outputFrameCount);
    StartRelease();
}
// [End start_Encoder_output_thread]