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
#include <dlfcn.h>
#include "global_handlers.h"
#include <hilog/log.h>

// Hilog parameters.
const int GLOBAL_RESMGR = 0xFF00;
const char *TAG = "[Preload]";

static napi_value Preload(napi_env env, napi_callback_info info) {
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload init");
    size_t argc = 1;
    napi_value args[1] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_value result;
    napi_create_array(env, &result); // Create an array to hold the results.

    // Args[0] is the SO library path array.
    napi_valuetype valuetype;
    napi_typeof(env, args[0], &valuetype);

    if (valuetype != napi_object) {
        return nullptr;
    }
    // Obtains the length of the input SO library path array.
    uint32_t arrayLength;
    napi_get_array_length(env, args[0], &arrayLength);

    napi_value pathString;
    // Path for storing the SO library.
    char path[256];
    size_t pathLength;
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload start");
    for (uint32_t i = 0; i < arrayLength; i++) {
        napi_get_element(env, args[0], i, &pathString);
        napi_status status = napi_get_value_string_utf8(env, pathString, path, sizeof(path), &pathLength);
        if (status != napi_ok) {
            // Processing the Failure of Obtaining the Path.
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, " Preload failed");
            continue;
        }
        // Use dlopen to dynamically load the SO library and return the handle of the SO library.
        void *handler = dlopen(path, RTLD_LAZY);
        if (handler == nullptr) {
            // Dlerror throws failure to load library.
            OH_LOG_Print(LOG_APP, LOG_ERROR, GLOBAL_RESMGR, TAG, " Preload failed");
            dlerror();
            continue;
        }
        // Save the handles to the global object global_handlers.
        global_handlers[std::string(path)] = handler;
        // Add the path of the successfully loaded library to the result array.
        napi_set_element(env, result, i, pathString);
    }
    OH_LOG_Print(LOG_APP, LOG_INFO, GLOBAL_RESMGR, TAG, "Preload finish");
    // Return the result array that is loaded successfully.
    return result;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {{"preload", nullptr, Preload, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "preloadso",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterPreloadsoModule(void) { napi_module_register(&demoModule); }