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

#include "napi/native_api.h"
#include "add/add.h"
#include "dlfcn.h"
#include <cstring>

/**
 * Integrate the third-party SO library directly on the Native side
 * @param
 * @param
 * @return
 */

// [Start NAPI_Global_nativeAdd]
static napi_value NAPI_Global_nativeAdd(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value ret;
    napi_create_double(env, add(value0, value1), &ret);

    return ret;
}

// [StartExclude NAPI_Global_nativeAdd]
/**
 * Integrate the third-party SO library on the Native side through dlopen
 * @param
 * @param
 * @return
 */
// [Start NAPI_Global_nativeSub]
typedef double (*Sub)(double, double);
static napi_value NAPI_Global_nativeSub(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    double value0;
    napi_get_value_double(env, args[0], &value0);
    double value1;
    napi_get_value_double(env, args[1], &value1);
    size_t length = 0;
    napi_status status = napi_get_value_string_utf8(env, args[2], nullptr, 0, &length);
    if (status != napi_ok) {
        return nullptr;
    }
    char *path = new char[length + 1];
    std::memset(path, 0, length + 1);
    napi_get_value_string_utf8(env, args[2], path, length + 1, &length); // Get the SO library path information
    void *handle = dlopen(path, RTLD_LAZY);                              // Open a SO library and get the path
    napi_value result = nullptr;
    Sub sub_func = (Sub)dlsym(handle, "sub"); // Get the function named sub
    status = napi_create_double(env, sub_func(value0, value1), &result);
    delete[] path;
    dlclose(handle); // Remember to close the SO library
    if (status != napi_ok) {
        return nullptr;
    }
    return result;
}
// [EndExclude NAPI_Global_nativeAdd]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        // [StartExclude NAPI_Global_nativeSub]
        {"nativeAdd", nullptr, NAPI_Global_nativeAdd, nullptr, nullptr, nullptr, napi_default, nullptr},
        // [StartExclude NAPI_Global_nativeSub]
        // [StartExclude NAPI_Global_nativeAdd]
        {"nativeSub", nullptr, NAPI_Global_nativeSub, nullptr, nullptr, nullptr, napi_default, nullptr}};
        // [EndExclude NAPI_Global_nativeAdd]
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END
// [End NAPI_Global_nativeAdd]
// [End NAPI_Global_nativeSub]

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