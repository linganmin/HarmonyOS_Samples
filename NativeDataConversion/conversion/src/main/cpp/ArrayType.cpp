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
#include "ArrayType.h"
#include <hilog/log.h>

napi_value ArrayType::ArrReverse(napi_env env, napi_callback_info info) {
    size_t argc = 1;                // Number of parameters.
    napi_value args[1] = {nullptr}; // A napi array that stores parameters.

    // Obtain the parameters and store them in the NAPI parameter array.
    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArrayType", "api_get_cb_info failed");
        return nullptr;
    }

    // Obtain the array length from the napi parameter array for subsequent traversals.
    uint32_t length;
    if (napi_ok != napi_get_array_length(env, args[0], &length)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArrayType", "napi_get_array_length failed");
        return nullptr;
    }

    // Create an array result with an initial length of length.
    napi_value result;
    if (napi_ok != napi_create_array_with_length(env, length, &result)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArrayType", "napi_create_array_with_length failed");
        return nullptr;
    }

    for (uint32_t i = 0; i < length; i++) {
        napi_value e;
        // Gets the element of the array subscripted i and stores it in the variable e.
        if (napi_ok != napi_get_element(env, args[0], i, &e)) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArrayType", "napi_get_element failed");
            return nullptr;
        }
        // Set the value of the element subscripted length-i-1 in the result array.
        if (napi_ok != napi_set_element(env, result, length - i - 1, e)) {
            OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArrayType", "napi_set_element failed");
            return nullptr;
        }
    }

    return result;
}