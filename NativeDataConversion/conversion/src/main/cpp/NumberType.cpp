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

// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "NumberType.h"
#include <hilog/log.h>

napi_value NumberType::Add(napi_env env, napi_callback_info info) {
    size_t argc = 2;                // Number of parameters.
    napi_value args[2] = {nullptr}; // A napi array that stores parameters.

    // Obtain the parameters and store them in the NAPI parameter array.
    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "NumberType", "api_get_cb_info failed");
        return nullptr;
    }

    int64_t value1 = 0;
    int64_t value2 = 0;

    // Obtain the C-side int data from the NAPI parameter array.
    if (napi_ok != napi_get_value_int64(env, args[0], &value1) ||
        napi_ok != napi_get_value_int64(env, args[1], &value2)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "NumberType", "api_get_value_int64 failed");
        return nullptr;
    }
    
    napi_value sum;
    if (napi_ok != napi_create_int64(env, value1 + value2, &sum)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "NumberType", "napi_create_int64 failed");
        return nullptr;
    }
    return sum;
}