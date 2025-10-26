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
 * FAQ: Native侧使用napi_create_buffer接口构造的对象在ArkTS侧如何接收
 */
// DocsCode 1
#include "CreatBuffer.h"
napi_value CreatBuffer::TestBuffer(napi_env env, napi_callback_info) {
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
// DocsCode 1