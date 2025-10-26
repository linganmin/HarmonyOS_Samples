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
// [Start set_error_callback]
void CAVScreenCaptureToFile::OnErrorSaveFile(OH_AVScreenCapture *capture, int32_t errorCode, void *userData) {
    (void)capture;
    OH_LOG_INFO(LOG_APP, "录屏发生错误，错误码为 %{public}d", errorCode);
    (void)userData;
}
// [End set_error_callback]

void CAVScreenCaptureToFile::ReleaseSCWorker(struct OH_AVScreenCapture *capture) {
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture ReleaseSCInstanceWorker S");
    OH_AVScreenCapture_Release(capture);
    m_IsRunning = false;
    g_avCapture_ = nullptr;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture ReleaseSCInstanceWorker E");
}

/*
 * 屏幕录制状态更改回调
 */
// [Start set_statechange_callback]
void CAVScreenCaptureToFile::OnStateChangeSaveFile(struct OH_AVScreenCapture *capture,
                                                   OH_AVScreenCaptureStateCode stateCode, void *userData) {
    (void)capture;
    switch (stateCode) {
    case OH_SCREEN_CAPTURE_STATE_STARTED: {
        OH_LOG_INFO(LOG_APP, "录屏开始状态变更");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_CANCELED: {
        OH_LOG_INFO(LOG_APP, "录屏取消状态变更 ");
        StopScreenCaptureRecording(capture);
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_CALL: {
        OH_LOG_INFO(LOG_APP,
                    "录屏被电话打断状态处理");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_MIC_UNAVAILABLE: {
        OH_LOG_INFO(LOG_APP,
                    "录屏中途麦克风无法获取状态");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_INTERRUPTED_BY_OTHER: {
        OH_LOG_INFO(LOG_APP,
                    "录屏状态被被打断");
        break;
    }
    case OH_SCREEN_CAPTURE_STATE_MIC_MUTED_BY_USER: {
        OH_LOG_INFO(LOG_APP,
                    "录屏中途用户将麦克风禁音");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_MIC_UNMUTED_BY_USER: {
        OH_LOG_INFO(LOG_APP,
                    "录屏中途用户将麦克风解除禁音");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_ENTER_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP,
                    "录屏进入隐私状态");
        std::thread releaseSCInstanceThread(ReleaseSCWorker, capture);
        releaseSCInstanceThread.detach();
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_EXIT_PRIVATE_SCENE: {
        OH_LOG_INFO(LOG_APP,
                    "录屏退出隐私模式状态");
        break;
    }

    case OH_SCREEN_CAPTURE_STATE_STOPPED_BY_USER: {
        napi_acquire_threadsafe_function(tsFn);
        napi_call_threadsafe_function(tsFn, nullptr, napi_tsfn_nonblocking);
        napi_release_threadsafe_function(tsFn, napi_tsfn_release);
        tsFn = nullptr;
        OH_LOG_INFO(LOG_APP,
                    "录屏被用户切换打断");
        std::thread releaseSCInstanceThread(ReleaseSCWorker, capture);
        releaseSCInstanceThread.detach();
        break;
    }

    default:
        break;
    }
    
    (void)userData;
}
// [End set_statechange_callback]

/*
 * Configuration parameters
 */
// [Start audio_config1]
void CAVScreenCaptureToFile::SetConfigAsFile(OH_AVScreenCaptureConfig &config, int32_t videoWidth,
                                             int32_t videoHeight) {
    // 音频配置
    OH_AudioCaptureInfo micCapInfo = {.audioSampleRate = 48000, .audioChannels = 2, .audioSource = OH_SOURCE_DEFAULT};
    OH_AudioCaptureInfo innerCapInfo = {.audioSampleRate = 48000, .audioChannels = 2, .audioSource = OH_ALL_PLAYBACK};
    OH_AudioEncInfo audioEncInfo = {.audioBitrate = 96000, .audioCodecformat = OH_AudioCodecFormat::OH_AAC_LC};
    OH_AudioInfo audioInfo = {.micCapInfo = micCapInfo, .innerCapInfo = innerCapInfo, .audioEncInfo = audioEncInfo};

    // 视频配置
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
// [End audio_config1]

// [Start stop_record1]
napi_value CAVScreenCaptureToFile::StopScreenCaptureToFile(napi_env env, napi_callback_info info) {
    // [StartExclude stop_record1]
    OH_AVSCREEN_CAPTURE_ErrCode result = AV_SCREEN_CAPTURE_ERR_OPERATE_NOT_PERMIT;
    napi_value res;

    if (m_IsRunning && g_avCapture_ != nullptr) {
    // [EndExclude stop_record1]

        OH_LOG_INFO(LOG_APP, "停止屏幕录制");
        result = OH_AVScreenCapture_StopScreenRecording(g_avCapture_);
        if (result != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(
                LOG_APP,
                "停止屏幕录制错误，结果为：%{public}d",
                result);
        } else {
            OH_LOG_INFO(LOG_APP, "停止屏幕录制成功");
        }
        result = OH_AVScreenCapture_Release(g_avCapture_);
        if (result != AV_SCREEN_CAPTURE_ERR_BASE) {
            OH_LOG_ERROR(LOG_APP, "释放实例化对象异常，错误为: %{public}d",
                         result);
        } else {
            OH_LOG_INFO(LOG_APP, "释放实例化对象成功");
        }
        // [StartExclude stop_record1]
        m_IsRunning = false;
        g_avCapture_ = nullptr;
    }
    napi_create_int32(env, result, &res);
    return res;
    // [EndExclude stop_record1]
}
// [End stop_record1]

// [Start create_record1]
napi_value CAVScreenCaptureToFile::StartScreenCaptureToFile(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t outputFd, videoWidth, videoHeight;
    // 获取参数：文件fd和宽高
    napi_get_value_int32(env, args[0], &outputFd);
    napi_get_value_int32(env, args[1], &videoWidth);
    napi_get_value_int32(env, args[2], &videoHeight);
    OH_LOG_INFO(LOG_APP, "文件FD为 %{public}d", outputFd);
    if (outputFd <= 0) {
        OH_LOG_ERROR(LOG_APP, "FD ERROR: %{public}d", outputFd);
        napi_value res;
        napi_create_int32(env, -1, &res);
        return res;
    }

    if (g_avCapture_ != nullptr) {
        StopScreenCaptureRecording(g_avCapture_);
        OH_AVScreenCapture_Release(g_avCapture_);
    }
    // 创建实例化对象
    g_avCapture_ = OH_AVScreenCapture_Create();
    if (g_avCapture_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "CAVScreenCaptureToFile create screen capture failed");
    }

    // [StartExclude create_record1]
    // [Start set_config1]
    OH_AVScreenCaptureConfig config_;
    OH_RecorderInfo recorderInfo;

    // 转文件fd为url
    std::string fileUrl = "fd://" + std::to_string(outputFd);
    recorderInfo.url = const_cast<char *>(fileUrl.c_str());
    // 文件格式MP4
    recorderInfo.fileFormat = OH_ContainerFormatType::CFT_MPEG_4;
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture fileUrl %{public}s", fileUrl.c_str());

    // 调用音视频录制参数配置函数
    SetConfigAsFile(config_, videoWidth, videoHeight);
    config_.captureMode = OH_CAPTURE_HOME_SCREEN;
    config_.dataType = OH_CAPTURE_FILE;
    config_.recorderInfo = recorderInfo;
    
    // 设置麦克风开关
    bool isMicrophone = true;
    OH_AVScreenCapture_SetMicrophoneEnabled(g_avCapture_, isMicrophone);

    OH_AVScreenCapture_SetCanvasRotation(g_avCapture_, true);
    // [End set_config1]

    // [Start init_record1]
    OH_AVSCREEN_CAPTURE_ErrCode result = OH_AVScreenCapture_Init(g_avCapture_, config_);
    // [End init_record1]

    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OH_AVScreenCapture_Init failed %{public}d", result);
    }
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture OH_AVScreenCapture_Init succ %{public}d", result);

    // [Start set_callback1]
    // 设置回调
    OH_AVScreenCapture_SetErrorCallback(g_avCapture_, OnErrorSaveFile, nullptr);
    OH_AVScreenCapture_SetStateCallback(g_avCapture_, OnStateChangeSaveFile, nullptr);
    // [End set_callback1]

    // [Start start_record1]
    result = OH_AVScreenCapture_StartScreenRecording(g_avCapture_);
    // [End start_record1]

    if (result != AV_SCREEN_CAPTURE_ERR_OK) {
        OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture Started failed %{public}d", result);
        OH_AVScreenCapture_Release(g_avCapture_);
    }
    OH_LOG_INFO(LOG_APP, "CAVScreenCaptureToFile ScreenCapture Started succ %{public}d", result);
    m_IsRunning = true;
    napi_value res;
    napi_create_int32(env, result, &res);
    return res;
    // [EndExclude create_record1]
}
// [End create_record1]

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
