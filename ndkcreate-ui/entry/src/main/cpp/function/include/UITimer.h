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

#ifndef NDKCREATEUI_UITIMER_H
#define NDKCREATEUI_UITIMER_H

#include <cstdint>
#include <js_native_api.h>
#include <node_api_types.h>

namespace NativeModule {
struct UIData {
    void *userData = nullptr;
    int32_t count = 0;
    int32_t totalCount = 0;
    void (*func)(void *userData, int32_t count) = nullptr;
    napi_env env = nullptr;
};

constexpr int INITIAL_DELAY_MS = 200;
constexpr int TIMER_INTERVAL_MS = 200;

static napi_threadsafe_function threadSafeFunction = nullptr;

static void ThreadSafeCallJs(napi_env env, napi_value js_callBack, void *context, void *data);

void SubThread(UIData *asyncContext);

void CreateNativeTimer(napi_env env, void *userData, int32_t totalCount, void (*func)(void *userData, int32_t count));

} // namespace NativeModule

#endif // NDKCREATEUI_UITIMER_H
