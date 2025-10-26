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
 * FAQ: 如何判断当前线程是否为主线程
 */
#include <hilog/log.h>
// DocsCode 1
#include "IsMainThread.h"
#include <unistd.h>
#include <sys/syscall.h>

bool IsMainThread::isMainThread() {
    pid_t pid = getpid();
    pid_t tid = syscall(SYS_gettid);

    if (pid == tid) {
        return true;
    } else {
        return false;
    }
}
// DocsCode 1

napi_value IsMainThread::MainThread(napi_env env, napi_callback_info info) {
    size_t requireArgc = 2;
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);

    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);

    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);

    double value0;
    napi_get_value_double(env, args[0], &value0);

    double value1;
    napi_get_value_double(env, args[1], &value1);

    napi_value sum;
    napi_create_double(env, value0 + value1, &sum);

    bool flag = IsMainThread::isMainThread();

    OH_LOG_Print(LOG_APP, LOG_INFO, 0x0000, "Pure", "flag = %{public}d", flag);

    return sum;
}