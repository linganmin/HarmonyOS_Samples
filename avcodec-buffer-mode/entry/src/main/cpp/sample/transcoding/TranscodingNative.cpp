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

#include "TranscodingNative.h"
#include <uv.h>
#include "dfx/error/AVCodecSampleError.h"
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0xFF00
#define LOG_TAG "transcoding"

struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
};

void Callback(void *asyncContext) {
    uv_loop_s *loop = nullptr;
    CallbackContext *context = (CallbackContext *)asyncContext;
    napi_get_uv_event_loop(context->env, &loop);
    uv_work_t *work = new uv_work_t;
    work->data = context;
    uv_queue_work(
        loop, work, [](uv_work_t *work) {},
        [](uv_work_t *work, int status) {
            CallbackContext *context = (CallbackContext *)work->data;
            napi_handle_scope scope = nullptr;
            // Manage the lifecycle of napi_value to prevent memory leaks.
            napi_open_handle_scope(context->env, &scope);
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            // Callback to UI side.
            napi_call_function(context->env, nullptr, callback, 0, nullptr, nullptr);
            napi_close_handle_scope(context->env, scope);
            delete context;
            delete work;
        });
}

napi_value TranscodingNative::Start(napi_env env, napi_callback_info info) {
    SampleInfo sampleInfo;
    size_t argc = 8;
    napi_value args[8] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    
    napi_get_value_int32(env, args[0], &sampleInfo.inputFd);
    napi_get_value_int32(env, args[1], &sampleInfo.outputFd);
    napi_get_value_int64(env, args[2], &sampleInfo.inputFileOffset);
    napi_get_value_int64(env, args[3], &sampleInfo.inputFileSize);
    char videoCodecMime[20] = {0};
    size_t videoCodecMimeStrlen = 0;
    size_t len = 20;
    napi_get_value_string_utf8(env, args[4], videoCodecMime, len, &videoCodecMimeStrlen);
    sampleInfo.outputVideoCodecMime = videoCodecMime;
    napi_get_value_double(env, args[5], &sampleInfo.outputFrameRate);
    napi_get_value_int64(env, args[6], &sampleInfo.outputBitrate);

    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, args[7], 1, &asyncContext->callbackRef);

    sampleInfo.playDoneCallback = &Callback;
    sampleInfo.playDoneCallbackData = asyncContext;
    int32_t ret = Transcoding::GetInstance().Init(sampleInfo);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        Transcoding::GetInstance().Start();
    }
    return nullptr;
}

napi_value TranscodingNative::Stop(napi_env env, napi_callback_info info) {
    Transcoding::GetInstance().Stop();
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor classProp[] = {
        {"startNative", nullptr, TranscodingNative::Start, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"stopNative", nullptr, TranscodingNative::Stop, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    
    napi_define_properties(env, exports, sizeof(classProp) / sizeof(classProp[0]), classProp);
    return exports;
}
EXTERN_C_END

static napi_module TranscodingModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "transcoding",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterPlayerModule(void) { napi_module_register(&TranscodingModule); }