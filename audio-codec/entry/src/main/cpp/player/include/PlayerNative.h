/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
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

#ifndef VIDEO_CODEC_SAMPLE_PLAYER_NATIVE_H
#define VIDEO_CODEC_SAMPLE_PLAYER_NATIVE_H
#include <fstream>
#include <fstream>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include "napi/native_api.h"
#include "AudioCapturer.h"
#include "Player.h"
#include "PlayerNative.h"
struct AsyncCallbackInfo {
    napi_env env;
    napi_async_work asyncWork;
    napi_deferred deferred;
    int32_t resultCode = 0;
    std::string surfaceId = "";
    std::string filePath = "";
    SampleInfo sampleInfo;
    std::string audioCodecMime;
    napi_value promise;
    std::ofstream outputFile;
    bool isPaused = false;
};

class PlayerNative {
public:
    static napi_value Play(napi_env env, napi_callback_info info);
    static napi_value GetFramesWritten(napi_env env, napi_callback_info info);
    static napi_value GetCurrentSampleRate(napi_env env, napi_callback_info info);
    static napi_value GetPosition(napi_env env, napi_callback_info info);
    static napi_value Pause(napi_env env, napi_callback_info info);
    static napi_value CapturerStart(napi_env env, napi_callback_info info);
    static napi_value Release(napi_env env, napi_callback_info info);
    static napi_value Init(napi_env env, napi_callback_info info);
    static napi_value Stop(napi_env env, napi_callback_info info);
    static napi_value TranscodingInit(napi_env env, napi_callback_info info);
    static napi_value TranscodingStop(napi_env env, napi_callback_info info);
};
#endif // VIDEO_CODEC_SAMPLE_PLAYER_NATIVE_H