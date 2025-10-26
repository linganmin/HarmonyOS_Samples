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
#ifndef AVSCREENCAPTURESCREENRECORD_CAVSCREENCAPTURETOSTREAM_H
#define AVSCREENCAPTURESCREENRECORD_CAVSCREENCAPTURETOSTREAM_H
#include "CAVScreenCaptureToStream/AudioCapturer.h"
#include "CAVScreenCaptureToStream/AudioEncoder.h"
#include "CAVScreenCaptureToStream/Muxer.h"
#include "CAVScreenCaptureToStream/SampleInfo.h"
#include "CAVScreenCaptureToStream/VideoEncoder.h"
#include <js_native_api.h>
#include <memory>
#include <multimedia/player_framework/native_avscreen_capture_base.h>
#include <thread>
class CAVScreenCaptureToStream {
private:
    static void StopScreenCaptureRecording(struct OH_AVScreenCapture *capture);
    static void SetConfigToStream(OH_AVScreenCaptureConfig &config, int32_t videoWidth, int32_t videoHeight);

    static void OnErrorToStream(OH_AVScreenCapture *capture, int32_t errorCode, void *userData);
    static void OnSurfaceStateChangeToStream(struct OH_AVScreenCapture *capture, OH_AVScreenCaptureStateCode stateCode,
                                             void *userData);
    static void ReleaseSCWorkerToStream(struct OH_AVScreenCapture *capture);

    void InitConfig(int32_t outputFd, int32_t videoWidth, int32_t videoHeight);
    void EncOutputThread();
    void CreateEncoder();
    void StartRelease();
    void Release();

    void AudioEncInputThread();
    void AudioEncOutputThread();

    std::unique_ptr<AudioCapturer> audioCapturer_ = nullptr;

    std::unique_ptr<std::thread> encOutputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncInputThread_ = nullptr;
    std::unique_ptr<std::thread> audioEncOutputThread_ = nullptr;
    std::unique_ptr<Muxer> muxer_ = nullptr;


    SampleInfo sampleInfo_;
    CodecUserData *videoEncContext_ = nullptr;
    CodecUserData *audioEncContext_ = nullptr;
    int32_t isFirstFrame_ = true;

    std::atomic<bool> isStarted_{false};

public:
    CAVScreenCaptureToStream(){};
    ~CAVScreenCaptureToStream();

    static CAVScreenCaptureToStream &GetInstance() {
        static CAVScreenCaptureToStream AVScreenCapture;
        return AVScreenCapture;
    }

    void StartScreenCapture(int32_t outputFd, int32_t videoWidth, int32_t videoHeight);
    void StopScreenCapture();
    static napi_value SetStopCallbackToStream(napi_env env, napi_callback_info info);
    static void SetStopFlagToStream(napi_env env, napi_value jsCb, void *context, void *data);
};
#endif
