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

#include "napi/native_api.h"
#include "uv.h"
#define LOG_DOMAIN 0X0202
#define LOG_TAG "MyTag"
#include <hilog/log.h>

struct CallbackContext{
    napi_env env;
    int retData;
    napi_ref callbackRef;
};

// [Start call_back_test]
void callbackTest(CallbackContext* context)
{
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(context->env, &loop);


    uv_work_t* work = new uv_work_t;
    context->retData = 1;
    work->data = (void*)context;


    uv_queue_work(
        loop, work, [](uv_work_t* work) {},
        // using callback function back to JS thread
        [](uv_work_t* work, int status) {
            CallbackContext* context = (CallbackContext*)work->data;
            napi_handle_scope scope = nullptr;
            napi_open_handle_scope(context->env, &scope); // open handle scope，The lifecycle of the JS object created below is managed by this scope
            if (scope == nullptr) {
                return;
            }
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            napi_value retArg;
            napi_create_int32(context->env, context->retData, &retArg);
            napi_value ret;
            napi_call_function(context->env, nullptr, callback, 1, &retArg, &ret);
            napi_delete_reference(context->env, context->callbackRef);
            napi_close_handle_scope(context->env, scope); // close handle scope，If the objects under this scope are not referenced by other objects, they will be released after GC
            if (work != nullptr) {
                delete work;
            }
            delete context;
        }
    );
}
// [End call_back_test]

// [Start napi_test]
static napi_value Test2(napi_env env, napi_callback_info info) {
    napi_escapable_handle_scope scope = nullptr;
    napi_value value1 = nullptr;
    napi_value value2 = nullptr;
    napi_value value3 = nullptr;
    napi_value value4 = nullptr;


    napi_open_escapable_handle_scope(env, &scope);
    napi_create_object(env, &value1);
    napi_escape_handle(env, scope, value1, &value4);
    napi_close_escapable_handle_scope(env, scope);
    napi_create_string_utf8(env, "const char *str", NAPI_AUTO_LENGTH, &value2);
    napi_create_string_utf8(env, "const char *str", NAPI_AUTO_LENGTH, &value3);
    napi_valuetype type = napi_null;
    napi_typeof(env, value4, &type);
    OH_LOG_INFO(LOG_APP, "xxx, %{public}d", type);


    return value1;
}
// [End napi_test]

// [Start napi_test_fn]
napi_ref g_ref = nullptr;
static napi_value Test3(napi_env env, napi_callback_info info) {
    napi_value value;
    napi_create_object(env, &value);
    napi_create_reference(env, value, 1, &g_ref);
    return nullptr;
}

static napi_value Test4(napi_env env, napi_callback_info info) {
    napi_value result;
    napi_get_reference_value(env, g_ref, &result);
    napi_delete_reference(env, g_ref);
    return result;
}
// [End napi_test_fn]