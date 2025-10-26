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
#include "napi/native_api.h"
#include <uv.h>
#include <thread>
#include <hilog/log.h>
#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "MY_TAG"

// [Start callback_context]
napi_threadsafe_function tsFn;
static int g_value = 0;

struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
};
// [End callback_context]

// [Start sub_thread]
void SubThread(CallbackContext *asyncContext) {
    if (asyncContext == nullptr) {
        return;
    }
    napi_acquire_threadsafe_function(tsFn);
    OH_LOG_INFO(LOG_APP, "ThreadSafe ChildThread, value:[%{public}d]", g_value);
    napi_call_threadsafe_function(tsFn, asyncContext, napi_tsfn_nonblocking);
    napi_release_threadsafe_function(tsFn, napi_tsfn_release);
}
// [End sub_thread]

// [Start thread_safe_call_js]
static void ThreadSafeCallJs(napi_env env, napi_value js_callBack, void *context, void *data) {
    CallbackContext *argContext = reinterpret_cast<CallbackContext *>(data);
    if (argContext != nullptr) {
        napi_get_reference_value(env, argContext->callbackRef, &js_callBack);
    } else {
        return;
    }

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, js_callBack, &valueType);
    if (valueType != napi_valuetype::napi_function) {
        napi_delete_reference(env, argContext->callbackRef);
        delete argContext;
        argContext = nullptr;
        return;
    }

    napi_value argv;
    napi_create_int32(env, g_value, &argv);
    napi_value result = nullptr;
    napi_call_function(env, nullptr, js_callBack, 1, &argv, &result);
    napi_get_value_int32(env, result, &g_value);
    OH_LOG_INFO(LOG_APP, "ThreadSafe CallArkTS end, value:[%{public}d]", g_value);
    napi_delete_reference(env, argContext->callbackRef);
    delete argContext;
    argContext = nullptr;
}
// [End thread_safe_call_js]

// [Start thread_safe_case]
static napi_value ThreadSafeCase(napi_env env, napi_callback_info info) {
    size_t argc = 1;
    napi_value js_callback;
    napi_value workName;
    napi_get_cb_info(env, info, &argc, &js_callback, nullptr, nullptr);

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, js_callback, &valueType);
    if (valueType != napi_valuetype::napi_function) {
        return nullptr;
    }

    napi_create_string_utf8(env, "ThreadSafeCase", NAPI_AUTO_LENGTH, &workName);
    napi_create_threadsafe_function(env, nullptr, nullptr, workName, 0, 1, nullptr, nullptr, nullptr, ThreadSafeCallJs, &tsFn);
    auto asyncContext = new CallbackContext();
    asyncContext->env = env;
    napi_create_reference(env, js_callback, 1, &asyncContext->callbackRef);
    std::thread t(SubThread, asyncContext);
    t.detach();
    return nullptr;
}
// [End thread_safe_case]

// [Start uv_loop_async]
//Global variable, used to store loop information and async handle.
uv_loop_t *loop = nullptr;
uv_async_t *async = nullptr;
// [End uv_loop_async]

// [Start async_handler]
void async_handler(uv_async_t *handle) {
    CallbackContext *context = reinterpret_cast<CallbackContext *>(handle->data);
    napi_handle_scope scope = nullptr;
    napi_open_handle_scope(context->env, &scope);
    if (scope == nullptr) {
        napi_delete_reference(context->env, context->callbackRef);
        delete context;
        context = nullptr;
        if (handle != nullptr) {
            delete handle;
            handle = nullptr;
        }
        return;
    }
    napi_value callback = nullptr;
    napi_get_reference_value(context->env, context->callbackRef, &callback);
    napi_value retArg;
    napi_create_int32(context->env, g_value, &retArg);
    napi_value result;
    napi_call_function(context->env, nullptr, callback, 1, &retArg, &result);
    napi_get_value_int32(context->env, result, &g_value);
    OH_LOG_INFO(LOG_APP, "LibUV CallArkTS end, value:[%{public}d]", g_value);
    napi_close_handle_scope(context->env, scope);
    napi_delete_reference(context->env, context->callbackRef);
    delete context;
    context = nullptr;
    uv_close((uv_handle_t *)async, [](uv_handle_t *handle) { delete (uv_async_t *)handle; });
}
// [End async_handler]

// [Start callback_uv_work_test]
void CallbackUvWorkTest(CallbackContext *context) {
    if (context == nullptr) {
        return;
    }
    OH_LOG_INFO(LOG_APP, "LibUV ChildThread, value:[%{public}d]", g_value);

    async->data = reinterpret_cast<void *>(context);
    uv_async_send(async);
}
// [End callback_uv_work_test]

static napi_value LibUvCase(napi_env env, napi_callback_info info) {
    // [Start lib_uv_case]
    size_t argc = 1;
    napi_value callback_function;
    napi_get_cb_info(env, info, &argc, &callback_function, nullptr, nullptr);

    napi_valuetype valueType = napi_undefined;
    napi_typeof(env, callback_function, &valueType);
    if (valueType != napi_valuetype::napi_function) {
        return nullptr;
    }
    // [End lib_uv_case]

    // [Start uv_default_loop]
    loop = uv_default_loop();
    async = new uv_async_t;
    uv_async_init(loop, async, async_handler);
    // [End uv_default_loop]
    
    // [Start lib_uv_case]
    auto asyncContext = new CallbackContext();
    if (asyncContext == nullptr) {
        return nullptr;
    }
    asyncContext->env = env;
    napi_create_reference(env, callback_function, 1, &asyncContext->callbackRef);
    // [End lib_uv_case]
    // [Start uv_default_loop]
    std::thread caseThread(CallbackUvWorkTest, asyncContext);
    caseThread.detach();
    uv_run(loop, UV_RUN_DEFAULT);
    return nullptr;
    // [End uv_default_loop]
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"threadSafeCase", nullptr, ThreadSafeCase, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"libUvCase", nullptr, LibUvCase, nullptr, nullptr, nullptr, napi_default, nullptr}};
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
