/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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
#include "napi/native_api.h"
#include "hitrace/trace.h"
/**
 * The total number of terms in the Fibonacci sequence. value is 20.
 */
const int FIB_VALUE = 20;
/**
 * taskId of Native performance Tagging is 2.
 */
const int NATIVE_TASK_ID = 2;
/**
 * task name of Native performance Tagging is NativePerfTag.
 */
const char *NATIVE_TASK_NAME = "NativePerfTag";

long long DoFib(int n) 
{
    if (n <= 0) {
        return 0;
    } else if (n == 1) {
        return 1;
    } else {
        return DoFib(n - 1) + DoFib(n - 2);
    }
}

static napi_value HiTraceMeterTest(napi_env env, napi_callback_info info) 
{
    // HiTraceMeter Start tagging.
    OH_HiTrace_StartAsyncTrace(NATIVE_TASK_NAME, NATIVE_TASK_ID);
    DoFib(FIB_VALUE);
    // HiTraceMeter finish tagging.
    OH_HiTrace_FinishAsyncTrace(NATIVE_TASK_NAME, NATIVE_TASK_ID);
    return nullptr;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) 
{
    napi_property_descriptor desc[] = {
        {"hiTraceMeterTest", nullptr, HiTraceMeterTest, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
