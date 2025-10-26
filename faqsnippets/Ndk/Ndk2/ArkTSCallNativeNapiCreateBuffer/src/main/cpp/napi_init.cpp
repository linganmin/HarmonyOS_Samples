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
 * FAQ: 在ArkTS侧如何引用Native侧使用napi_create_buffer接口构造的对象
 */

#include "napi/native_api.h"

// [Start ark_ts_call_native_napi_create_buffer_cpp]
#include "CreateBuffer.h"
napi_value CreateBuffer::TestBuffer(napi_env env, napi_callback_info) {
    size_t length = 100;
    char *data = nullptr;
    napi_value result = nullptr;
    napi_create_buffer(env, length, reinterpret_cast<void **>(&data), &result);


    char buf[50] = {0};
    for (int i = 0; i < 50; i++) {
        buf[i] = i + 2;
    }
    napi_create_buffer_copy(env, 50, buf, reinterpret_cast<void **>(&data), &result);
    return result;
}
// [End ark_ts_call_native_napi_create_buffer_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "testBuffer", nullptr, CreatBuffer::TestBuffer, nullptr, nullptr, nullptr, napi_default, nullptr }
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

extern "C" __attribute__((constructor)) void RegisterArkTSCallNativeNapiCreateBufferModule(void)
{
    napi_module_register(&demoModule);
}
