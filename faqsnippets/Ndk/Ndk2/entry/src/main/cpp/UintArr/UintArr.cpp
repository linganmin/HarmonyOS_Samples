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
 * FAQ: Native侧如何获取ArkTS侧的Uint8Array实例
 */
// [Start uint_arr_cpp]
// Native side obtains Uint8Array parameter and returns it to ArkTS side 
#include "UintArr.h" 
napi_value Demo1::UintArr(napi_env env, napi_callback_info info) { 
    size_t requireArgc = 1; 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
 
    napi_value inputArray = args[0]; 
 
    // Get the ArrayBuffer type 
    napi_typedarray_type type; 
    napi_value inArrayBuffer; 
    size_t byteOffset; 
    size_t length; 
    napi_get_typedarray_info(env, inputArray, &type, &length, nullptr, &inArrayBuffer, &byteOffset); 
    if (type != napi_uint8_array) { 
        return nullptr; 
    } 
     
    // Retrieve information from the ArrayBuffer 
    void *data = nullptr; 
    size_t byte_length; 
    napi_get_arraybuffer_info(env, inArrayBuffer, &data, &byte_length); 
 
    // Construct an ArrayBuffer and assign a value 
    napi_value output_buffer; 
    void *output_ptr = nullptr; 
    napi_create_arraybuffer(env, byte_length, &output_ptr, &output_buffer); 
    napi_value outputArray; 
    napi_create_typedarray(env, type, length, output_buffer, byteOffset, &outputArray); 
    uint8_t *input_bytes = (uint8_t *)(data) + byteOffset; 
    uint8_t *array = (uint8_t *)(output_ptr); 
    for (size_t idx = 0; idx < length; idx++) { 
        array[idx] = 3; 
    } 
 
    return outputArray; 
}
// [End uint_arr_cpp]