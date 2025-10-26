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
#include "CAVScreenCaptureToStream.h"
#include "CAVScreenCaptureToStream/Muxer.h"
#include "SampleInfo.h"
#include "VideoEncoder.h"
#include "hilog/log.h"
#include <js_native_api.h>
#include <multimedia/player_framework/native_avcapability.h>
#include <multimedia/player_framework/native_avcodec_base.h>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <multimedia/player_framework/native_avscreen_capture.h>
#include <multimedia/player_framework/native_avscreen_capture_errors.h>
#include <node_api.h>
#include <node_api_types.h>
#include <thread>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "CAVSCREENCAPTURETOSTREAM"

using namespace std;

namespace {
// microsecond
constexpr int64_t MICROSECOND = 1000000;
} // namespace

extern bool m_IsRunning;
napi_threadsafe_function tsFnToStream;

OH_AVScreenCapture *g_avCapture = nullptr;
std::unique_ptr<VideoEncoder> videoEncoder_ = nullptr;
std::unique_ptr<AudioEncoder> audioEncoder_ = nullptr;
std::unique_ptr<std::thread> releaseThread_ = nullptr;
std::mutex mutex_;
std::condition_variable doneCond_;

CAVScreenCaptureToStream::~CAVScreenCaptureToStream() { StartRelease(); }

/*
 * Screen recording Error callback
 */
void CAVScreenCaptureToStream::OnErrorToStream(OH_AVScreenCapture *capture, int32_t errorCode, void *userData) {
    OH_LOG_ERROR(LOG_APP, "ScreenCapture OnError errorCode is %{public}d", errorCode);
}

/*
 * Screen recording state change callback
 */
void CAVScreenCaptureToStream::OnSurfaceStateChangeToStream(struct OH_AVScreenCapture *capture,
                                                            OH_AVScreenCaptureStateCode stateCode, void *userData) {
    switch (stateCode) {
    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_USER: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_STOPPED_BY_USER");
        if (m_IsRunning) {
            int32_t ret = videoEncoder_->NotifyEndOfStream();
            std::unique_lock<std::mutex> lock(mutex_);
            doneCond_.wait(lock);
            if (releaseThread_ && releaseThread_->joinable()) {
                releaseThread_->join();
                releaseThread_.reset();
            }
        }

        OH_AVScreenCapture_StopScreenCapture(g_avCapture);
        std::thread releaseSCInstanceThread(ReleaseSCWorkerToStream, capture);
        releaseSCInstanceThread.detach();

        napi_acquire_threadsafe_function(tsFnToStream);
        napi_call_threadsafe_function(tsFnToStream, nullptr, napi_tsfn_nonblocking);
        napi_release_threadsafe_function(tsFnToStream, napi_tsfn_release);
        tsFnToStream = nullptr;
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_CANCELED: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_CANCELED ");
        StopScreenCaptureRecording(capture);
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_STARTED: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OnStateChange started OH_SCREEN_CAPTURE_STATE_STARTED");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_CALL: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OH_SCREEN_CAPTURE_STATE_STOPPED_BY_CALL");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_INTERRUPTED_BY_OTHER: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OH_SCREEN_CAPTURE_STATE_INTERRUPTED_BY_OTHER");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_MIC_UNMUTED_BY_USER: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OH_SCREEN_CAPTURE_STATE_MIC_MUTED_BY_USER");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_ENTER_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_ENTER_PRIVATE_SCENE");
        std::thread releaseSCInstanceThread(ReleaseSCWorkerToStream, capture);
        releaseSCInstanceThread.detach();
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_EXIT_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OH_SCREEN_CAPTURE_STATE_EXIT_PRIVATE_SCENE");
        break;
    }
    default:
        break;
    }
}

/*
 * Configure screen recording parameters
 */
// [Start InitAVScreenCapture]
void CAVScreenCaptureToStream::InitAVScreenCapture(int32_t videoWidth,
                                                 int32_t videoHeight) {
    if (g_avCapture != nullptr) {
        StopScreenCaptureRecording(g_avCapture);
    }

    g_avCapture = OH_AVScreenCapture_Create();
    if (g_avCapture == nullptr) {
        OH_LOG_ERROR(LOG_APP, "create screen capture failed");
    }
    OH_LOG_INFO(LOG_APP, "ScreenCapture after create sc");

    // Set callback
    OH_AVScreenCapture_SetErrorCallback(g_avCapture, OnErrorToStream, nullptr);
    OH_AVScreenCapture_SetStateCallback(g_avCapture, OnSurfaceStateChangeToStream, nullptr);

    OH_AVScreenCapture_SetMicrophoneEnabled(g_avCapture, true);
    OH_AVScreenCapture_SetCanvasRotation(g_avCapture, true);

    // Initialize configuration information
    OH_AVScreenCaptureConfig config;
    OH_AudioCaptureInfo micCapInfo = {.audioSampleRate = 48000, .audioChannels = 2, .audioSource = OH_SOURCE_DEFAULT};
    OH_AudioCaptureInfo innerCapInfo = {.audioSampleRate = 48000, .audioChannels = 2, .audioSource = OH_ALL_PLAYBACK};
    OH_AudioEncInfo audioEncInfo = {.audioBitrate = 96000, .audioCodecformat = OH_AudioCodecFormat::OH_AAC_LC};
    OH_AudioInfo audioInfo = {.micCapInfo = micCapInfo, .innerCapInfo = innerCapInfo, .audioEncInfo = audioEncInfo};

    OH_VideoCaptureInfo videoCapInfo = {
        .videoFrameWidth = videoWidth, .videoFrameHeight = videoHeight, .videoSource = OH_VIDEO_SOURCE_SURFACE_RGBA};

    OH_VideoEncInfo videoEncInfo = {
        .videoCodec = OH_VideoCodecFormat::OH_H264, .videoBitrate = 10000000, .videoFrameRate = 30};

    OH_VideoInfo videoInfo = {.videoCapInfo = videoCapInfo, .videoEncInfo = videoEncInfo};

    config = {
        .captureMode = OH_CAPTURE_HOME_SCREEN,
        .dataType = OH_ORIGINAL_STREAM,
        .audioInfo = audioInfo,
        .videoInfo = videoInfo,
    };

    int result = OH_AVScreenCapture_Init(g_avCapture, config);
    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "ScreenCapture OH_AVScreenCapture_Init failed %{public}d", result);
    }
    OH_LOG_INFO(LOG_APP, "ScreenCapture OH_AVScreenCapture_Init %{public}d", result);
}
// [End InitAVScreenCapture]

void CAVScreenCaptureToStream::StopScreenCaptureRecording(struct OH_AVScreenCapture *capture) {
    if (m_IsRunning && capture != nullptr) {
        OH_AVScreenCapture_StopScreenCapture(capture);
        m_IsRunning = false;
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToStream ScreenCapture StopScreenCapture");
    }
}

void CAVScreenCaptureToStream::ReleaseSCWorkerToStream(struct OH_AVScreenCapture *capture) {
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToStream ScreenCapture ReleaseSCInstanceWorker S");
    OH_AVScreenCapture_Release(capture);
    m_IsRunning = false;
    g_avCapture = nullptr;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToStream ScreenCapture ReleaseSCInstanceWorker E");
}

/*
 * Create audio and video encoder
 */
void CAVScreenCaptureToStream::CreateEncoder() {
    audioEncoder_->Create(sampleInfo_.audioCodecMime);
    audioEncContext_ = new CodecUserData;
    audioEncoder_->Config(sampleInfo_, audioEncContext_);
    videoEncoder_->Create(sampleInfo_.videoCodecMime);
    videoEncContext_ = new CodecUserData;
    videoEncoder_->Config(sampleInfo_, videoEncContext_);
}

/*
 * Video encoder output thread
 */
// [Start EncOutputThread]
void CAVScreenCaptureToStream::EncOutputThread() {
    while (true) {
        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Work done, thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(videoEncContext_->outputMutex);
        bool condRet = videoEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !videoEncContext_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Work done, thread out");
            break;
        }
        if (videoEncContext_->outputBufferInfoQueue.empty()) {
            OH_LOG_ERROR(LOG_APP, "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        CodecBufferInfo bufferInfo = videoEncContext_->outputBufferInfoQueue.front();
        videoEncContext_->outputBufferInfoQueue.pop();

        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            OH_LOG_ERROR(LOG_APP, "Catch EOS, thread out");
            break;
        }
        lock.unlock();
        if ((bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_SYNC_FRAME) ||
            (bufferInfo.attr.flags == AVCODEC_BUFFER_FLAGS_NONE)) {
            videoEncContext_->outputFrameCount++;
            bufferInfo.attr.pts = videoEncContext_->outputFrameCount * MICROSECOND / sampleInfo_.frameRate;
        } else {
            bufferInfo.attr.pts = 0;
        }

        muxer_->WriteSample(muxer_->GetVideoTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = videoEncoder_->FreeOutputBuffer(bufferInfo.bufferIndex);

        if (ret) {
            OH_LOG_ERROR(LOG_APP, "Encoder output thread out");
            break;
        }
    }
    StartRelease();
    OH_LOG_INFO(LOG_APP, "Exit, frame count: %{public}u", videoEncContext_->outputFrameCount);
}
// [End EncOutputThread]

/*
 * Initialize configuration information
 */
void CAVScreenCaptureToStream::InitMuxerAndEncoder(int32_t outputFd, int32_t videoWidth, int32_t videoHeight) {
    sampleInfo_.outputFd = outputFd;

    // Video encoding configuration
    sampleInfo_.videoWidth = videoWidth;
    sampleInfo_.videoHeight = videoHeight;
    sampleInfo_.frameRate = 30;
    sampleInfo_.bitrate = 10000000;
    sampleInfo_.videoCodecMime = "video/avc";

    // Audio encoding configuration
    sampleInfo_.audioCodecMime = OH_AVCODEC_MIMETYPE_AUDIO_AAC;
    sampleInfo_.audioSampleFormat = OH_BitsPerSample::SAMPLE_S16LE;
    sampleInfo_.audioSampleRate = 48000;
    sampleInfo_.audioChannelCount = 2;
    sampleInfo_.audioBitRate = 96000;
    sampleInfo_.audioChannelLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    sampleInfo_.audioMaxInputSize = sampleInfo_.audioSampleRate * 0.02 * sampleInfo_.audioChannelCount * sizeof(short);

    std::lock_guard<std::mutex> lock(mutex_);

    audioEncoder_ = std::make_unique<AudioEncoder>();
    audioCapturer_ = std::make_unique<AudioCapturer>();
    videoEncoder_ = std::make_unique<VideoEncoder>();
    muxer_ = std::make_unique<Muxer>();

    muxer_->Create(sampleInfo_.outputFd);
    muxer_->Config(sampleInfo_);

    CreateEncoder();

    // Init AudioCapturer
    audioCapturer_->AudioCapturerInit(sampleInfo_, audioEncContext_);

    releaseThread_ = nullptr;
}

void CAVScreenCaptureToStream::StartMuxerAndEncoder() {
    // Start muxer
    int32_t ret = muxer_->Start();
    // Start video Encoder
    ret = videoEncoder_->Start();

    isStarted_ = true;
    // Start the video output threads
    encOutputThread_ = std::make_unique<std::thread>(&CAVScreenCaptureToStream::EncOutputThread, this);
    if (encOutputThread_ == nullptr) {
        StartRelease();
        return;
    }

    if (audioEncContext_) {
        // Start AudioCapturer
        audioCapturer_->AudioCapturerStart();

        // Start audio Encoder
        audioEncoder_->Start();
        isStarted_ = true;
        // Start the audio input and output threads
        audioEncInputThread_ = std::make_unique<std::thread>(&CAVScreenCaptureToStream::AudioEncInputThread, this);
        audioEncOutputThread_ = std::make_unique<std::thread>(&CAVScreenCaptureToStream::AudioEncOutputThread, this);
        if (audioEncInputThread_ == nullptr || audioEncOutputThread_ == nullptr) {
            StartRelease();
            return;
        }

        // Empty the playback cache queue
        if (audioEncContext_ != nullptr) {
            audioEncContext_->ClearCache();
        }
    }
}

// [Start StartScreenCapture]
void CAVScreenCaptureToStream::StartScreenCapture(int32_t outputFd, int32_t videoWidth, int32_t videoHeight) {
    InitMuxerAndEncoder(outputFd, videoWidth, videoHeight);

    InitAVScreenCapture(videoWidth, videoHeight);
    
    m_IsRunning = true;

    StartMuxerAndEncoder();

    int result = OH_AVScreenCapture_StartScreenCaptureWithSurface(g_avCapture, sampleInfo_.window);
    OH_LOG_INFO(LOG_APP, "OH_VideoEncoder_Start Started 2 %{public}d", result);
    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "ScreenCapture Started failed %{public}d", result);
        OH_AVScreenCapture_Release(g_avCapture);
    }
}
// [End StartScreenCapture]

/*
 * Stop screen recording
 */
void CAVScreenCaptureToStream::StopScreenCapture() {
    int32_t ret = videoEncoder_->NotifyEndOfStream();

    std::unique_lock<std::mutex> lock(mutex_);
    doneCond_.wait(lock);
    if (releaseThread_ && releaseThread_->joinable()) {
        releaseThread_->join();
        releaseThread_.reset();
    }

    if (m_IsRunning) {
        ret = OH_AVScreenCapture_StopScreenCapture(g_avCapture);
        if (ret != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(LOG_APP, "StopScreenCapture OH_AVScreenCapture_StopScreenCapture Result: %{public}d", ret);
        } else {
            OH_LOG_INFO(LOG_APP, "StopScreenCapture OH_AVScreenCapture_StopScreenCapture");
        }
        ret = OH_AVScreenCapture_Release(g_avCapture);
        if (ret != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(LOG_APP, "StopScreenCapture OH_AVScreenCapture_Release: %{public}d", ret);
        } else {
            OH_LOG_INFO(LOG_APP, "OH_AVScreenCapture_Release success");
        }
        m_IsRunning = false;
        g_avCapture = nullptr;
    }
}

void CAVScreenCaptureToStream::SetStopFlagToStream(napi_env env, napi_value jsCb, void *context, void *data) {
    if (env == nullptr) {
        return;
    }
    napi_value res;
    napi_call_function(env, nullptr, jsCb, 0, nullptr, &res);
    OH_LOG_INFO(LOG_APP, "Callback result");
}

/*
 * Set the callback function after stopping
 */
napi_value CAVScreenCaptureToStream::SetStopCallbackToStream(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "ThreadSafeSetStopFlag", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_threadsafe_function(env, args[0], nullptr, resourceName, 0, 1, nullptr, nullptr, nullptr,
                                    SetStopFlagToStream, &tsFnToStream);
    return nullptr;
}


void CAVScreenCaptureToStream::StartRelease() {
    if (releaseThread_ == nullptr) {
        releaseThread_ = std::make_unique<std::thread>(&CAVScreenCaptureToStream::Release, this);
    }
}

/*
 * Release thread
 */
void CAVScreenCaptureToStream::Release() {
    std::lock_guard<std::mutex> lock(mutex_);
    isStarted_ = false;
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
    if (videoEncoder_ != nullptr) {
        videoEncoder_->Stop();
        if (sampleInfo_.window != nullptr) {
            OH_NativeWindow_DestroyNativeWindow(sampleInfo_.window);
            sampleInfo_.window = nullptr;
        }
        videoEncoder_->Release();
        videoEncoder_.reset();
        OH_LOG_INFO(LOG_APP, "Video encoder release successful");
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
    if (videoEncContext_ != nullptr) {
        delete videoEncContext_;
        videoEncContext_ = nullptr;
    }
    doneCond_.notify_all();
    OH_LOG_INFO(LOG_APP, "Release successful");
}

/*
 * Audio encoder input thread
 */
void CAVScreenCaptureToStream::AudioEncInputThread() {
    while (true) {
        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Encoder input thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex);
        bool condRet = audioEncContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || (!audioEncContext_->inputBufferInfoQueue.empty() &&
                                   (audioEncContext_->remainlen >= sampleInfo_.audioMaxInputSize));
        });
        if (audioEncContext_->inputBufferInfoQueue.empty()) {
            OH_LOG_ERROR(LOG_APP, "Audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        if (isStarted_ && audioEncContext_->remainlen < sampleInfo_.audioMaxInputSize) {
            continue;
        }

        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue.front();
        audioEncContext_->inputBufferInfoQueue.pop();
        audioEncContext_->inputFrameCount++;

        uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        audioEncContext_->ReadCache(inputBufferAddr, sampleInfo_.audioMaxInputSize);
        lock.unlock();

        bufferInfo.attr.size = sampleInfo_.audioMaxInputSize;
        if (isFirstFrame_) {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_CODEC_DATA;
            isFirstFrame_ = false;
        } else {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_NONE;
        }
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        if (ret) {
            OH_LOG_ERROR(LOG_APP, "Push data failed, thread out");
            break;
        }
    }
}

/*
 * Audio encoder output thread
 */
void CAVScreenCaptureToStream::AudioEncOutputThread() {
    while (true) {
        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Work done, thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
        bool condRet = audioEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue.empty(); });

        if (!isStarted_) {
            OH_LOG_ERROR(LOG_APP, "Work done, thread out");
            break;
        }

        if (audioEncContext_->outputBufferInfoQueue.empty()) {
            OH_LOG_ERROR(LOG_APP, "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        lock.unlock();
        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                            bufferInfo.attr);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        if (ret) {
            OH_LOG_ERROR(LOG_APP, "Encoder output thread out");
            break;
        }
    }
    OH_LOG_INFO(LOG_APP, "Exit, frame count: %{public}u", audioEncContext_->inputFrameCount);
    StartRelease();
}