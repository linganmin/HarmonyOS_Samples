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
#include "CAVScreenCaptureToFile.h"
#include "hilog/log.h"
#include <js_native_api.h>
#include <multimedia/player_framework/native_avscreen_capture.h>
#include <multimedia/player_framework/native_avscreen_capture_errors.h>
#include <node_api.h>
#include <thread>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "MY_CAVSCREENCAPTURE"

bool m_IsRunning = false;
OH_AVScreenCapture *g_avCapture_;
napi_threadsafe_function tsFn;


void CAVScreenCaptureToFile::StopScreenCaptureRecording(struct OH_AVScreenCapture *capture) {
    if (m_IsRunning && capture != nullptr) {
        OH_AVScreenCapture_StopScreenRecording(capture);
        m_IsRunning = false;
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture StopScreenCapture");
    }
}

/*
 * Screen recording Error callback
 */
void CAVScreenCaptureToFile::OnErrorSaveFile(OH_AVScreenCapture *capture, int32_t errorCode, void *userData) {
    (void)capture;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OnError errorCode is %{public}d", errorCode);
    (void)userData;
}

void CAVScreenCaptureToFile::ReleaseSCWorker(struct OH_AVScreenCapture *capture) {
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture ReleaseSCInstanceWorker S");
    OH_AVScreenCapture_Release(capture);
    m_IsRunning = false;
    g_avCapture_ = nullptr;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture ReleaseSCInstanceWorker E");
}

/*
 * Screen recording state change callback
 */
void CAVScreenCaptureToFile::OnStateChangeSaveFile(struct OH_AVScreenCapture *capture,
                                                   OH_AVScreenCaptureStateCode stateCode, void *userData) {
    (void)capture;
    switch (stateCode) {
    case OH_SCREEN_CAPTURE_STATE_STARTED: {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_STARTED");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_CANCELED: {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_CANCELED ");
        StopScreenCaptureRecording(capture);
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_CALL: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_STOPPED_BY_CALL");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_MIC_UNAVAILABLE: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_MIC_UNAVAILABLE");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_INTERRUPTED_BY_OTHER: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_INTERRUPTED_BY_OTHER");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_MIC_MUTED_BY_USER: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_MIC_MUTED_BY_USER");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_MIC_UNMUTED_BY_USER: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_MIC_MUTED_BY_USER");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_ENTER_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_ENTER_PRIVATE_SCENE");
        std::thread releaseSCInstanceThread(ReleaseSCWorker, capture);
        releaseSCInstanceThread.detach();
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_EXIT_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_EXIT_PRIVATE_SCENE");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_USER: {
        napi_acquire_threadsafe_function(tsFn);
        napi_call_threadsafe_function(tsFn, nullptr, napi_tsfn_nonblocking);
        napi_release_threadsafe_function(tsFn, napi_tsfn_release);
        tsFn = nullptr;
        OH_LOG_INFO(LOG_APP,
                    "CAVScreenCaptureToFile ScreenCapture OnStateChange OH_SCREEN_CAPTURE_STATE_STOPPED_BY_USER");
        std::thread releaseSCInstanceThread(ReleaseSCWorker, capture);
        releaseSCInstanceThread.detach();
        break;
    }

    default:
        break;
    }
    
    (void)userData;
}

/*
 * Configuration parameters
 */
void CAVScreenCaptureToFile::SetConfigAsFile(OH_AVScreenCaptureConfig &config, int32_t videoWidth,
                                             int32_t videoHeight) {
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
        .recorderInfo = {},
    };
}

napi_value CAVScreenCaptureToFile::StopScreenCaptureToFile(napi_env env, napi_callback_info info) {
    (void)info;
    OH_AVSCREEN_CAPTURE_ErrCode result = AV_SCREEN_CAPTURE_ERR_OPERATE_NOT_PERMIT;
    napi_value res;

    if (m_IsRunning && g_avCapture_ != nullptr) {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture File Stop");
        result = OH_AVScreenCapture_StopScreenRecording(g_avCapture_);
        if (result != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(
                LOG_APP,
                "CAVScreenCaptureToFile StopScreenCapture OH_AVScreenCapture_StopScreenRecording Result: %{public}d",
                result);
        } else {
            OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile StopScreenCapture OH_AVScreenCapture_StopScreenRecording");
        }
        result = OH_AVScreenCapture_Release(g_avCapture_);
        if (result != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(LOG_APP, "CAVScreenCaptureToFile StopScreenCapture OH_AVScreenCapture_Release: %{public}d",
                         result);
        } else {
            OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile OH_AVScreenCapture_Release success");
        }
        m_IsRunning = false;
        g_avCapture_ = nullptr;
    }
    napi_create_int32(env, result, &res);
    return res;
}

napi_value CAVScreenCaptureToFile::StartScreenCaptureToFile(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t outputFd, videoWidth, videoHeight;
    napi_get_value_int32(env, args[0], &outputFd);
    napi_get_value_int32(env, args[1], &videoWidth);
    napi_get_value_int32(env, args[2], &videoHeight);
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile FD %{public}d", outputFd);
    if (outputFd <= 0) {
        OH_LOG_ERROR(LOG_APP, "CAVScreenCaptureToFile FD ERROR  %{public}d", outputFd);
        napi_value res;
        napi_create_int32(env, -1, &res);
        return res;
    }

    if (g_avCapture_ != nullptr) {
        StopScreenCaptureRecording(g_avCapture_);
        OH_AVScreenCapture_Release(g_avCapture_);
    }
    g_avCapture_ = OH_AVScreenCapture_Create();
    if (g_avCapture_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "CAVScreenCaptureToFile create screen capture failed");
    }
    OH_AVScreenCaptureConfig config_;
    OH_RecorderInfo recorderInfo;

    std::string fileUrl = "fd://" + std::to_string(outputFd);
    recorderInfo.url = const_cast<char *>(fileUrl.c_str());
    recorderInfo.fileFormat = OH_ContainerFormatType::CFT_MPEG_4;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture fileUrl %{public}s", fileUrl.c_str());

    SetConfigAsFile(config_, videoWidth, videoHeight);
    config_.captureMode = OH_CAPTURE_HOME_SCREEN;
    config_.dataType = OH_CAPTURE_FILE;
    config_.recorderInfo = recorderInfo;

    bool isMicrophone = true;
    OH_AVScreenCapture_SetMicrophoneEnabled(g_avCapture_, isMicrophone);
    OH_AVScreenCapture_SetErrorCallback(g_avCapture_, OnErrorSaveFile, nullptr);
    OH_AVScreenCapture_SetStateCallback(g_avCapture_, OnStateChangeSaveFile, nullptr);
    OH_AVScreenCapture_SetCanvasRotation(g_avCapture_, true);

    OH_AVSCREEN_CAPTURE_ErrCode result = OH_AVScreenCapture_Init(g_avCapture_, config_);
    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OH_AVScreenCapture_Init failed %{public}d", result);
    }
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OH_AVScreenCapture_Init succ %{public}d", result);

    result = OH_AVScreenCapture_StartScreenRecording(g_avCapture_);
    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture Started failed %{public}d", result);
        OH_AVScreenCapture_Release(g_avCapture_);
    }
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture Started succ %{public}d", result);
    m_IsRunning = true;
    napi_value res;
    napi_create_int32(env, result, &res);
    return res;
}

void CAVScreenCaptureToFile::SetStopFlag(napi_env env, napi_value jsCb, void *context, void *data) {
    if (env == nullptr) {
        return;
    }
    napi_value res;
    napi_call_function(env, nullptr, jsCb, 0, nullptr, &res);
}

/*
 * Set the callback function after stopping
 */
napi_value CAVScreenCaptureToFile::SetStopCallbackToFile(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "ThreadSafeSetStopFlag", NAPI_AUTO_LENGTH, &resourceName);
    napi_create_threadsafe_function(env, args[0], nullptr, resourceName, 0, 1, nullptr, nullptr, nullptr, SetStopFlag,
                                    &tsFn);
    return nullptr;
}
