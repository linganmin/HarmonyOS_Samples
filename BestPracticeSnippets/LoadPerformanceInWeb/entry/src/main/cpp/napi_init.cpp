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

#include "napi/native_api.h"

static napi_value registerCustomSchemes(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    int32_t outputFd, videoWidth, videoHeight;
    napi_get_value_int32(env, args[0], &outputFd);
    napi_get_value_int32(env, args[1], &videoWidth);
    napi_get_value_int32(env, args[2], &videoHeight);
    CAVScreenCaptureToStream::GetInstance().StartScreenCapture(outputFd, videoWidth, videoHeight);

    return nullptr;
}

static napi_value StopScreenCaptureToStream(napi_env env, napi_callback_info info) {
    CAVScreenCaptureToStream::GetInstance().StopScreenCapture();
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"startScreenCaptureToFile", nullptr, registerCustomSchemes, nullptr, nullptr,
         nullptr, napi_default, nullptr},
        {"stopScreenCaptureToFile", nullptr, CAVScreenCaptureToFile::StopScreenCaptureToFile, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"setStopCallbackToFile", nullptr, CAVScreenCaptureToFile::SetStopCallbackToFile, nullptr, nullptr, nullptr,
         napi_default, nullptr},
        {"startScreenCaptureToStream", nullptr, StartScreenCaptureToStream, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"stopScreenCaptureToStream", nullptr, StopScreenCaptureToStream, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"setStopCallbackToStream", nullptr, CAVScreenCaptureToStream::GetInstance().SetStopCallbackToStream, nullptr,
         nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
