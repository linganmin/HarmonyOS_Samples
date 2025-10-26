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
 * FAQ:如何利用worker子线程调用napi实现loop改写变量
 */
#ifndef PROJECT5_WORKERCALLNAPILOOP_H
#define PROJECT5_WORKERCALLNAPILOOP_H
#include "napi/native_api.h"
class WorkerCallNapiLoop {
public:
    // [Start worker_call_napi_loop_h]
    struct CallbackContext {
        napi_env env = nullptr;
        napi_ref callbackRef = nullptr;
        int retData = 0;
    };
    // [End worker_call_napi_loop_h]

    static napi_value MainThread(napi_env env, napi_callback_info info);
    static void SubThread(CallbackContext *context);
};
#endif // PROJECT5_WORKERCALLNAPILOOP_H
