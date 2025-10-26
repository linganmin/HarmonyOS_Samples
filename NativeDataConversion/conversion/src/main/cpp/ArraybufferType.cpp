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
#include "ArraybufferType.h"
#include <hilog/log.h>

napi_value ArraybufferType::ArrayBuf(napi_env env, napi_callback_info info) {
    size_t argc = 1;                // Number of parameters.
    napi_value args[1] = {nullptr}; // A napi array that stores parameters.

    // Obtain the parameters and store them in the NAPI parameter array.
    if (napi_ok != napi_get_cb_info(env, info, &argc, args, nullptr, nullptr)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArraybufferType", "api_get_cb_info failed");
        return nullptr;
    }

    void *data = nullptr; // The pointer to the underlying data buffer used to get the arraybuffer.
    size_t length;        // The length of the underlying data buffer used to obtain the arraybuffer.

    if (napi_ok != napi_get_arraybuffer_info(env, args[0], &data, &length)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArraybufferType", "napi_get_arraybuffer_info failed");
        return nullptr;
    }

    // The underlying pointer of the ArrayBuffer is strongly converted into a uint32_t pointer and squared.
    size_t len = length / sizeof(uint32_t);
    uint32_t *array = reinterpret_cast<uint32_t *>(data);
    for (size_t idx = 0; idx < len; idx++) {
        array[idx] *= array[idx];
    }

    // Turns the uint32_t type pointer after the operation back to the void pointer.
    napi_value ret;
    void *buffer_data = reinterpret_cast<void *>(array);
    napi_finalize finalize_cb; // An optional callback that is called when the ArrayBuffer is collected.
    // Construct an arraybuffer and pass it to the arkTs side.
    if (napi_ok != napi_create_external_arraybuffer(env, buffer_data, length, finalize_cb, nullptr, &ret)) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, 0xFF00, "ArraybufferType", "napi_create_external_arraybuffer failed");
        return nullptr;
    }
    return ret;
}