/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
/**
 * FAQ: 如何在ArkTS侧监听Native侧日志信息
 */
// [Start log_listener_one_cpp]
#include "napi/native_api.h"
#include <bits/alltypes.h>
#include <cstring>
#include <hilog/log.h>


napi_ref logListenerRef = nullptr;
napi_ref onLogsFuncRef = nullptr;
static napi_value RegisterLogListener(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value globalThisAdapter = nullptr;
    napi_get_cb_info(env, info, &argc, &globalThisAdapter, nullptr, nullptr);


    napi_value getLogListenerFunc = nullptr;
    napi_get_named_property(env, globalThisAdapter, "getLogsListener", &getLogListenerFunc);


    napi_value logListener = nullptr;
    napi_call_function(env, globalThisAdapter, getLogListenerFunc, 0, nullptr, &logListener);


    napi_value onLogsFunc = nullptr;
    napi_get_named_property(env, logListener, "onLogs", &onLogsFunc);


    napi_create_reference(env, logListener, 1, &logListenerRef);
    napi_create_reference(env, onLogsFunc, 1, &onLogsFuncRef);


    return nullptr;
}
// [End log_listener_one_cpp]

// [Start log_listener_three_cpp]
static void callOnLogs(napi_env env, LogLevel level, const char *message) {


    size_t argc = 2;
    napi_value argv[2] = {nullptr};


    int32_t tem = level;
    napi_create_int32(env, tem, &argv[0]);
    napi_create_string_utf8(env, message, strlen(message) + 1, &argv[1]);
    napi_value logListener = nullptr;
    napi_value onLogsFunc = nullptr;
    napi_get_reference_value(env, logListenerRef, &logListener);
    napi_get_reference_value(env, onLogsFuncRef, &onLogsFunc);


    napi_call_function(env, logListener, onLogsFunc, argc, argv, nullptr);
}
// [End log_listener_three_cpp]

// [Start log_listener_four_cpp]
static napi_value Add(napi_env env, napi_callback_info info) {
    callOnLogs(env, LogLevel::LOG_INFO, "execute native Add function success");
    return nullptr;
}
// [End log_listener_four_cpp]

// [Start log_listener_two_cpp]
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"registerLogListener", nullptr, RegisterLogListener, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END
// [End log_listener_two_cpp]

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "loglistener",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterLogListenerModule(void) { napi_module_register(&demoModule); }
