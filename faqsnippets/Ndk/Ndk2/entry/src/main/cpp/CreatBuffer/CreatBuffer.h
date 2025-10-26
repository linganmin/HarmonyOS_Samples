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
#ifndef PROJECT5_CREATBUFFER_H
#define PROJECT5_CREATBUFFER_H
#include "napi/native_api.h"
class CreatBuffer {
public:
    static napi_value TestBuffer(napi_env env, napi_callback_info);
};
#endif // PROJECT5_CREATBUFFER_H
// DocsCode 1