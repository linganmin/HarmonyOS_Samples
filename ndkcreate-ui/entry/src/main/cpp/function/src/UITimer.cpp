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

#include <cstdint>
#include <hilog/log.h>
#include <js_native_api.h>
#include <node_api.h>
#include <node_api_types.h>
#include <string>
#include <thread>
#include <uv.h>
#include "UITimer.h"

namespace NativeModule {
static void ThreadSafeCallJs(napi_env env, napi_value js_callBack, void *context, void *data)
{
    auto uidata = reinterpret_cast<UIData *>(data);
    uidata->func(uidata->userData, uidata->count);
    delete uidata;
}

void SubThread(UIData *asyncContext)
{
    uv_loop_t *loop = uv_loop_new();
    uv_timer_t *timer = new uv_timer_t();
    uv_timer_init(loop, timer);
    timer->data =
        new UIData{asyncContext->userData, 0, asyncContext->totalCount, asyncContext->func, asyncContext->env};
    uv_timer_start(
        timer,
        [](uv_timer_t *handle) {
            OH_LOG_INFO(LOG_APP, "on timeout");
            napi_acquire_threadsafe_function(threadSafeFunction);
            auto *customData = reinterpret_cast<UIData *>(handle->data);
            // Create callback data
            auto *callbackData = new UIData{customData->userData, customData->count, customData->totalCount,
                                            customData->func, customData->env};
            napi_call_threadsafe_function(threadSafeFunction, callbackData, napi_tsfn_blocking);

            customData->count++;
            if (customData->count > customData->totalCount) {
                uv_timer_stop(handle);
                delete handle;
                delete customData;
                napi_release_threadsafe_function(threadSafeFunction, napi_tsfn_release);
            }
        },
        INITIAL_DELAY_MS, TIMER_INTERVAL_MS);
    uv_run(loop, UV_RUN_DEFAULT);
    uv_loop_delete(loop);
}

void CreateNativeTimer(napi_env env, void *userData, int32_t totalCount, void (*func)(void *userData, int32_t count))
{
    napi_value name;
    std::string str = "UICallback";
    napi_create_string_utf8(env, str.c_str(), str.size(), &name);
    // UI main thread callback function
    napi_create_threadsafe_function(env, nullptr, nullptr, name, 0, 1, nullptr, nullptr, nullptr, ThreadSafeCallJs,
                                    &threadSafeFunction);
    auto asyncContext = new UIData();
    asyncContext->userData = userData;
    asyncContext->env = env;
    asyncContext->func = func;
    asyncContext->totalCount = totalCount;

    // Start the timer to simulate data changes
    std::thread timerThread(SubThread, asyncContext);
    timerThread.detach();
}
} // namespace NativeModule