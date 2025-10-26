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
#ifndef AVSCREENCAPTURESCREENRECORD_CAVSCREENCAPTURETOFILE_H
#define AVSCREENCAPTURESCREENRECORD_CAVSCREENCAPTURETOFILE_H
#include <js_native_api.h>
#include <multimedia/player_framework/native_avscreen_capture_base.h>
#include <node_api_types.h>
class CAVScreenCaptureToFile {
private:
    static void SetConfigAsFile(OH_AVScreenCaptureConfig &config, int32_t videoWidth, int32_t videoHeight);
    static void StopScreenCaptureRecording(struct OH_AVScreenCapture *capture);
    static void OnErrorSaveFile(OH_AVScreenCapture *capture, int32_t errorCode, void *userData);
    static void ReleaseSCWorker(struct OH_AVScreenCapture *capture);
    static void OnStateChangeSaveFile(struct OH_AVScreenCapture *capture, OH_AVScreenCaptureStateCode stateCode,
                                      void *userData);
    static void SetStopFlag(napi_env env, napi_value jsCb, void *context, void *data);

public:
    static napi_value StartScreenCaptureToFile(napi_env env, napi_callback_info info);
    static napi_value StopScreenCaptureToFile(napi_env env, napi_callback_info info);
    static napi_value SetStopCallbackToFile(napi_env env, napi_callback_info info);
};
#endif
