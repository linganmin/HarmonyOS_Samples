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

#include "include/Recorder.h"
#include "SampleLog.h"
#include "dfx/error/SampleError.h"

#undef LOG_TAG
#define LOG_TAG "recorder"

namespace {
using namespace std::chrono_literals;
constexpr int64_t MICROSECOND = 1000000;
constexpr int32_t INPUT_FRAME_BYTES = 2 * 1024;
AudioBgmQueue g_bgmQueue;
} // namespace

Recorder::~Recorder() {}

AudioBgmQueue* Recorder::GetBgmQueue()
{
    return &g_bgmQueue;
}

int32_t Recorder::Init(SampleInfo &sampleInfo)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ == nullptr && muxer_ == nullptr, SAMPLE_ERR_ERROR,
                             "Already started.");
    sampleInfo_ = sampleInfo;
    sampleInfo_.videoInfo.videoWidth = sampleInfo.videoInfo.videoHeight;
    sampleInfo_.videoInfo.videoHeight = sampleInfo.videoInfo.videoWidth;
    if (!sampleInfo_.videoInfo.isHDRVivid) {
        // Create Render Thread
        renderThread_ = std::make_unique<NativeXComponentSample::RenderThread>();
        CHECK_AND_RETURN_RET_LOG(renderThread_ != nullptr, SAMPLE_ERR_ERROR, "renderThread_ is nullptr.");
    }
    // Audio Capturer Init
    audioEncoder_ = std::make_unique<AudioEncoder>();
    audioCapturer_ = std::make_unique<AudioCapturer>();

    videoEncoder_ = std::make_unique<VideoEncoder>();
    muxer_ = std::make_unique<Muxer>();

    int32_t ret = muxer_->Create(sampleInfo_.fileInfo.outputFd);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Create muxer with fd(%{public}d) failed",
                             sampleInfo_.fileInfo.outputFd);
    ret = muxer_->Config(sampleInfo_);

    ret = CreateAudioEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Create audio encoder failed");

    // Init AudioCapturer
    audioCapturer_->AudioCapturerInit(sampleInfo_, audioEncContext_);

    ret = CreateVideoEncoder();
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Create video encoder failed");
    if (!sampleInfo_.videoInfo.isHDRVivid) {
        CHECK_AND_RETURN_RET_LOG(renderThread_ != nullptr, SAMPLE_ERR_ERROR, "renderThread_ is nullptr.");
        renderThread_->CreateEncoderSurface(sampleInfo_.videoInfo.window, sampleInfo_.videoInfo.videoWidth,
                                            sampleInfo_.videoInfo.videoHeight);
        sampleInfo.videoInfo.window = renderThread_->GetNativeImageWindow(); // sampleInfo_.videoInfo.window;
        SAMPLE_LOGI("nativeImageWindow_:%{public}p.", sampleInfo.videoInfo.window);
    } else {
        sampleInfo.videoInfo.window = sampleInfo_.videoInfo.window;
    }
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
    }
    releaseThread_ = nullptr;
    SAMPLE_LOGI("Succeed");
    return SAMPLE_ERR_OK;
}

void Recorder::UpdateInfoForCamera(bool isFront)
{
    if (renderThread_) {
        renderThread_->SetCameraFront(isFront);
    }
}

void Recorder::UpdateFaceInfoFromCamera(FaceInfo faceInfo)
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, 0xFF00,
        "UpdateFaceInfoFromCamera", "face %{public}f.", faceInfo.topLeftX);
    if (videoEncoder_) {
        videoEncoder_->UpdateFaceInfoFromCamera(faceInfo);
    }
}

void Recorder::UpdateCameraRotation(int rotation)
{
    if (renderThread_) {
        renderThread_->UpdateCameraRotation(rotation);
    }
}

int32_t Recorder::Start(std::string previewSurfaceId)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CHECK_AND_RETURN_RET_LOG(!isStarted_, SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(encContext_ != nullptr, SAMPLE_ERR_ERROR, "Already started.");
    CHECK_AND_RETURN_RET_LOG(videoEncoder_ != nullptr && muxer_ != nullptr, SAMPLE_ERR_ERROR,
                             "Already started.");
    if (!sampleInfo_.videoInfo.isHDRVivid) {
        OHNativeWindow *OHWindow = nullptr;
        uint64_t surfaceId = std::stoull(previewSurfaceId);
        int32_t ret1  = OH_NativeWindow_CreateNativeWindowFromSurfaceId(surfaceId, &OHWindow);
        CHECK_AND_RETURN_RET_LOG(ret1 == SAMPLE_ERR_OK, ret1, "OH_NativeWindow_CreateNativeWindowFromSurfaceId failed");
        CHECK_AND_RETURN_RET_LOG(renderThread_ != nullptr, SAMPLE_ERR_ERROR, "renderThread_ is nullptr.");
        if (OHWindow != nullptr) {
            renderThread_->UpdateNativeWindow(OHWindow, sampleInfo_.videoInfo.videoWidth,
                                              sampleInfo_.videoInfo.videoHeight);
        }
    }

    int32_t ret = muxer_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Muxer start failed");
    ret = videoEncoder_->Start();
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Encoder start failed");

    isStarted_ = true;
    videoEncOutputThread_ = std::make_unique<std::thread>(&Recorder::VideoEncOutputThread, this);
    if (videoEncOutputThread_ == nullptr) {
        SAMPLE_LOGE("Create thread failed");
        StartRelease();
        return SAMPLE_ERR_ERROR;
    }

    if (audioEncContext_) {
        // Start AudioCapturer
        audioCapturer_->AudioCapturerStart();

        ret = audioEncoder_->Start();
        CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Audio Encoder start failed");
        isStarted_ = true;
        audioEncInputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncInputThread, this);
        audioEncOutputThread_ = std::make_unique<std::thread>(&Recorder::AudioEncOutputThread, this);
        if (audioEncInputThread_ == nullptr || audioEncOutputThread_ == nullptr) {
            SAMPLE_LOGE("Create thread failed");
            StartRelease();
            return SAMPLE_ERR_ERROR;
        }

        // Clear the playback buffer queue
        if (audioEncContext_ != nullptr) {
            audioEncContext_->ClearCache();
        }
    }

    SAMPLE_LOGI("Succeed");
    return SAMPLE_ERR_OK;
}

void Recorder::VideoEncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(encContext_->outputMutex);
        bool condRet = encContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !encContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!encContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = encContext_->outputBufferInfoQueue.front();
        encContext_->outputBufferInfoQueue.pop();
        CHECK_AND_BREAK_LOG(!(bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS), "Catch EOS, thread out");
        lock.unlock();
        //  codec_data is not considered a frame.
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_CODEC_DATA) && isFirstCodecData_) {
            bufferInfo.attr.pts = 0;
            isFirstCodecData_.store(false);
        }
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            if (!isFirstSyncFrame_) {
                bufferInfo.attr.pts = encContext_->outputFrameCount * MICROSECOND / sampleInfo_.videoInfo.frameRate;
            }
            encContext_->outputFrameCount++;
            isFirstSyncFrame_.store(false);
        }
        SAMPLE_LOGW("Video encoder buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
                            encContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                            bufferInfo.attr.pts);

        muxer_->WriteSample(muxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == SAMPLE_ERR_OK, "Encoder output thread out");
    }
    SAMPLE_LOGI("Exit, frame count: %{public}u", encContext_->outputFrameCount);
    StartRelease();
}

void Recorder::StartRelease()
{
    if (releaseThread_ == nullptr) {
        SAMPLE_LOGI("Start release CodecTest");
        releaseThread_ = std::make_unique<std::thread>(&Recorder::Release, this);
    }
}

void Recorder::Release()
{
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
    if (renderThread_) {
        renderThread_.reset();
        renderThread_ = nullptr;
    }
    if (videoEncOutputThread_ && videoEncOutputThread_->joinable()) {
        videoEncOutputThread_->join();
        videoEncOutputThread_.reset();
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
        SAMPLE_LOGI("Muxer release successful");
    }
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        if (sampleInfo_.videoInfo.window != nullptr) {
            OH_NativeWindow_DestroyNativeWindow(sampleInfo_.videoInfo.window);
            sampleInfo_.videoInfo.window = nullptr;
        }
        videoEncoder_->Release();
        videoEncoder_.reset();
        SAMPLE_LOGI("Video encoder release successful");
    }
    if (audioEncoder_ != nullptr) {
        audioEncoder_->Stop();
        audioEncoder_->Release();
        audioEncoder_.reset();
        SAMPLE_LOGI("Audio encoder release successful");
    }
    if (audioCapturer_ != nullptr) {
        audioCapturer_->AudioCapturerRelease();
        audioCapturer_.reset();
        SAMPLE_LOGI("Audio Capturer release successful");
    }
    if (audioEncContext_ != nullptr && audioEncContext_->decodedBgmQueue != nullptr) {
        audioEncContext_->decodedBgmQueue->Stop();
        audioEncContext_->decodedBgmQueue->Clear();
        SAMPLE_LOGI("decodedBgmQueue clear successful");
    }
    if (audioEncContext_ != nullptr) {
        delete audioEncContext_;
        audioEncContext_ = nullptr;
    }
    if (encContext_ != nullptr) {
        delete encContext_;
        encContext_ = nullptr;
    }
    doneCond_.notify_all();
    SAMPLE_LOGI("Succeed");
}

int32_t Recorder::WaitForDone()
{
    SAMPLE_LOGI("Wait called");
    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock);
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }
    SAMPLE_LOGI("Done");
    return SAMPLE_ERR_OK;
}

int32_t Recorder::Stop()
{
    int32_t ret = videoEncoder_->NotifyEndOfStream();
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Encoder notifyEndOfStream failed");
    return WaitForDone();
}

int32_t Recorder::CreateVideoEncoder()
{
    int32_t ret = videoEncoder_->Create(sampleInfo_.videoInfo.videoCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Create video encoder failed");

    encContext_ = new CodecUserData;
    ret = videoEncoder_->Config(sampleInfo_, encContext_);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Encoder config failed");

    return SAMPLE_ERR_OK;
}

int32_t Recorder::CreateAudioEncoder()
{
    int32_t ret = audioEncoder_->Create(sampleInfo_.audioInfo.audioCodecMime);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Create audio encoder(%{public}s) failed",
                             sampleInfo_.audioInfo.audioCodecMime.c_str());
    SAMPLE_LOGI("Create audio encoder(%{public}s)", sampleInfo_.audioInfo.audioCodecMime.c_str());

    audioEncContext_ = new CodecUserData;
    if (audioEncContext_) {
        audioEncContext_->decodedBgmQueue = &g_bgmQueue;
    }
    ret = audioEncoder_->Config(sampleInfo_, audioEncContext_);
    CHECK_AND_RETURN_RET_LOG(ret == SAMPLE_ERR_OK, ret, "Encoder config failed");

    return SAMPLE_ERR_OK;
}

void Recorder::AudioEncInputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Encoder input thread out");
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex);
        bool condRet = audioEncContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || (!audioEncContext_->inputBufferInfoQueue.empty() &&
                                   (audioEncContext_->remainlen >= sampleInfo_.audioInfo.audioMaxInputSize));
        });

        CHECK_AND_CONTINUE_LOG(!audioEncContext_->inputBufferInfoQueue.empty(),
                               "Audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        if (isStarted_ && audioEncContext_->remainlen < sampleInfo_.audioInfo.audioMaxInputSize) {
            continue;
        }

        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue.front();
        
        uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        bool readRet = audioEncContext_->ReadCache(inputBufferAddr, sampleInfo_.audioInfo.audioMaxInputSize);
        if (!readRet) {
            continue;
        }
        audioEncContext_->inputBufferInfoQueue.pop();
        audioEncContext_->inputFrameCount++;
        // Get the encoder's Surface to receive input data
        MixMicAndBgm((int16_t *)inputBufferAddr, audioEncContext_->decodedBgmQueue,
                     sampleInfo_.audioInfo.audioMaxInputSize / 2);
        lock.unlock();

        bufferInfo.attr.size = sampleInfo_.audioInfo.audioMaxInputSize;
        if (isFirstFrame_) {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_CODEC_DATA;
            isFirstFrame_ = false;
        } else {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_NONE;
        }
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        CHECK_AND_BREAK_LOG(ret == SAMPLE_ERR_OK, "Push data failed, thread out");
    }
}

void Recorder::AudioEncOutputThread()
{
    while (true) {
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
        bool condRet = audioEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue.empty(); });
        CHECK_AND_BREAK_LOG(isStarted_, "Work done, thread out");
        CHECK_AND_CONTINUE_LOG(!audioEncContext_->outputBufferInfoQueue.empty(),
                               "Buffer queue is empty, continue, cond ret: %{public}d", condRet);

        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        SAMPLE_LOGW(
            "Audio Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}" PRId64,
            audioEncContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);
        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        CHECK_AND_BREAK_LOG(ret == SAMPLE_ERR_OK, "Encoder output thread out");
    }
    SAMPLE_LOGI("Exit, frame count: %{public}u", audioEncContext_->inputFrameCount);
    StartRelease();
}

void Recorder::MixMicAndBgm(int16_t *mainPcm, AudioBgmQueue* bgmQueue, int32_t sampleCount)
{
    constexpr float bgmValue = 0.2f;
    if (bgmQueue && bgmQueue->IsStart()) {
        std::vector<int16_t> bgmPcm(sampleCount); // S16LE
        size_t samplesReceived = bgmQueue->pop(bgmPcm.data(), sampleCount);
        if (samplesReceived == sampleCount) {
            // Audio capture and background sound mixing
            for (int i = 0; i < sampleCount; i++) {
                // Main audio uses original sample values directly
                int32_t micSample = static_cast<int32_t>(mainPcm[i]);
                // Background music is first scaled and then converted to int32_t
                int32_t bgmSample = static_cast<int32_t>(bgmPcm[i] * bgmValue);
                // Add samples together, using int32_t to avoid intermediate overflow
                int32_t mixed = micSample + bgmSample;
                // Clamp to int16_t range (-32768 to 32767)
                mainPcm[i] = static_cast<int16_t>(std::clamp(mixed, -32768, 32767));
            }
        } else {
            SAMPLE_LOGE("bgmQueue no enough bgm data");
        }
    }
}