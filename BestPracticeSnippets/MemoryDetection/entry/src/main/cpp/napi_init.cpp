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

#include <string>

/**
 * 最佳实践：地址越界优化建议
 */
// [Start address_sanitizer_advise1_negative]
static std::string GetStringParam1(napi_env env, napi_value arg)
{
    size_t size;
    napi_get_value_string_utf8(env, arg, nullptr, 0, &size);
    size_t str_size = size + 1;
    char *buf = new char[str_size];
    napi_get_value_string_utf8(env, arg, buf, str_size, nullptr); // 未进行校验
    std::string str(buf);
    delete[] buf;
    return str;
}
// [End address_sanitizer_advise1_negative]

/**
 * 最佳实践：地址越界优化建议
 */

// [Start address_sanitizer_advise1_positive]
static std::string GetStringParam2(napi_env env, napi_value arg)
{
    size_t size;
    // 增加校验
    if (napi_get_value_string_utf8(env, arg, nullptr, 0, &size) != napi_ok || size == 0) {
        return "";
    }
    size_t str_size = size + 1;
    char *buf = new char[str_size];
    // 增加校验
    if (napi_get_value_string_utf8(env, arg, buf, str_size, nullptr) != napi_ok) {
        delete[] buf;
        return "";
    }
    std::string str(buf);
    delete[] buf;
    return str;
}
// [End address_sanitizer_advise1_positive]

static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    return sum;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr }
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
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
