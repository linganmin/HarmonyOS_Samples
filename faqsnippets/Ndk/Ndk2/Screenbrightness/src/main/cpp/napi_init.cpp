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
 * FAQ: 如何在Native侧获取屏幕亮度
 */

// [Start screen_brightness_napi_cpp]
// Screenbrightness/src/main/cpp/napi_init.cpp
#include "hilog/log.h"
#include "napi/native_api.h"
#include <string>


#define LOG_TAG "Pure"


static napi_value Success(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_value obj = args[0];
    napi_value key;
    napi_value rv;
    std::string x = "value";
    napi_create_string_utf8(env, x.c_str(), 5, &key);
    napi_get_property(env, obj, key, &rv);
    uint32_t result;
    napi_get_value_uint32(env, rv, &result);
    OH_LOG_INFO(LOG_APP, "napi get brightness %{public}d", result);
    return nullptr;
};
static napi_value Fail(napi_env env, napi_callback_info info) { return nullptr; };
static napi_value Complete(napi_env env, napi_callback_info info) { return nullptr; };
static napi_value NapiLoadModule(napi_env env, napi_callback_info info) {
    napi_value result;
    size_t argc = 1;
    napi_value args[1] = {nullptr};
    napi_status get = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    char path[64] = {0};
    size_t typeLen = 0;
    napi_get_value_string_utf8(env, args[0], path, sizeof(path), &typeLen);
    napi_status status = napi_load_module(env, path, &result);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "napi_load_module failed");
        return nullptr;
    }
    napi_value outputObject;
    napi_get_named_property(env, result, "getValue", &outputObject);
    napi_value arg;
    napi_create_object(env, &arg);
    napi_property_descriptor desc[] = {
        {"success", nullptr, Success, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"fail", nullptr, Fail, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"complete", nullptr, Complete, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, arg, sizeof(desc) / sizeof(desc[0]), desc);
    napi_call_function(env, result, outputObject, 1, &arg, nullptr);
    return result;
};
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"napiLoadModule", nullptr, NapiLoadModule, nullptr, nullptr, nullptr, napi_default, nullptr},
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
    .nm_modname = "screenbrightness",
    .nm_priv = ((void *)0),
    .reserved = {0},
};
extern "C" __attribute__((constructor)) void RegisterScreenBrightnessModule(void) { napi_module_register(&demoModule); }
// [End screen_brightness_napi_cpp]