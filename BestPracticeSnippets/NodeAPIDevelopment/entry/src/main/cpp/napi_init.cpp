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

/**
 * Node-API开发规范
 */

#include "napi/native_api.h"
#include <uv.h>

typedef struct CallbackContext {
    napi_env env = nullptr;
    int retData = 0;
    napi_ref callbackRef;
} CallbackContext;

static napi_value Add(napi_env env, napi_callback_info info) {
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

    return sum;
}

// [Start get_argv]
static napi_value GetArgvDemo1(napi_env env, napi_callback_info info) {
    size_t argc = 0;
    // Argv passes null ptr to obtain the true number of parameters passed in
    napi_get_cb_info(env, info, &argc, nullptr, nullptr, nullptr);
    // JS input parameter is 0, do not execute subsequent logic
    if (argc == 0) {
        return nullptr;
    }
    // Create an array to retrieve the parameters passed in JS
    napi_value *argv = new napi_value[argc];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    // Business code
    // ... ...
    // The object created by argv for new is manually released after use
    delete[] argv;
    return nullptr;
}


static napi_value GetArgvDemo2(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value argv[2] = {nullptr};
    // Napi_get_cf_info will write argc JS parameters or undefined to argv
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    // Business code
    // ... ...
    return nullptr;
}
// [End get_argv]

// [Start open_handle_scope]
static void OpenHandleScope(napi_env env, napi_callback_info info) {
    // When frequently calling the Napi interface to create JS objects in a for loop, handle_stope should be added to promptly release resources that are no longer in use.
    // In the following example, at the end of each loop, the lifecycle of the local variable res has ended. Therefore, adding scope to release its held JS objects in a timely manner to prevent memory leakage
    for (int i = 0; i < 100000; i++) {
        napi_handle_scope scope = nullptr;
        napi_open_handle_scope(env, &scope);
        if (scope == nullptr) {
            return;
        }
        napi_value res;
        napi_create_object(env, &res);
        napi_close_handle_scope(env, scope);
    }
}
// [End open_handle_scope]


// [Start erro_handle]
static void ErroHandle(napi_env env, napi_callback_info info) {
    napi_value object, string;

    // 1.create object
    napi_status status = napi_create_object(env, &object);
    if (status != napi_ok) {
        napi_throw_error(env, "ERROR: ", "...");
        return;
    }
    // 2.Create attribute values
    status = napi_create_string_utf8(env, "bar", NAPI_AUTO_LENGTH, &string);
    if (status != napi_ok) {
        napi_throw_error(env, "ERROR: ", "...");
        return;
    }
    // 3.Set the result of step 2 to the value of the object property foo
    status = napi_set_named_property(env, object, "foo", string);
    if (status != napi_ok) {
        napi_throw_error(env, "ERROR: ", "...");
        return;
    }
}
// [End erro_handle]

// [Start call_back_test]
void callbackTest(CallbackContext* context)
{
    uv_loop_s* loop = nullptr;
    napi_get_uv_event_loop(context->env, &loop);
    uv_work_t* work = new uv_work_t;
    context->retData = 1;
    work->data = (void*)context;
    uv_queue_work(
        loop, work,
        // Please note that uv_queue-work will create a thread and execute the callback function. If developers only
        // want to throw tasks to JS threads, it is not recommended to use uv_queue-work to avoid redundant thread
        // creation
        [](uv_work_t* work) {
            // Execute some business logic
        },
        // This callback will be executed on the JS thread where the loop is located
        [](uv_work_t* work, int status) {
            CallbackContext* context = (CallbackContext*)work->data;
            napi_handle_scope scope = nullptr;
            napi_open_handle_scope(context->env, &scope);
            if (scope == nullptr) {
                if (work != nullptr) {
                    delete work;
                }
                return;
            }
            napi_value callback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &callback);
            napi_value retArg;
            napi_create_int32(context->env, context->retData, &retArg);
            napi_value ret;
            napi_call_function(context->env, nullptr, callback, 1, &retArg, &ret);
            napi_delete_reference(context->env, context->callbackRef);
            napi_close_handle_scope(context->env, scope);
            if (work != nullptr) {
                delete work;
            }
            delete context;
        }
    );
}
// [End call_back_test]

// [Start napi_wrap_test]
void NapiWrapTest(napi_env env, napi_callback_info info) {
    napi_value jsobject, nativeObject;
    napi_finalize cb;
    // Usage 1: Napi_rap does not need to receive the created napi_ref, and the last parameter is passed as nulliptr.
    // The created napi_ref is a weak reference, managed by the system, and does not require manual release by the user
    napi_wrap(env, jsobject, nativeObject, cb, nullptr, nullptr);


    // Usage 2: napi_rap needs to receive the created napi_ref, the last parameter is not null ptr, and the returned
    // napi_ref is a strong reference that needs to be manually released by the user, otherwise it will cause memory
    // leakage
    napi_ref result;
    napi_wrap(env, jsobject, nativeObject, cb, nullptr, &result);
    // When js_order and result are no longer used in the future, promptly call napi_remove-wrap to release result
    void *nativeObjectResult = nullptr;
    napi_remove_wrap(env, jsobject, &nativeObjectResult);
}
// [End napi_wrap_test]

// [Start napi_array_demo]
// The following code uses a regular JSArray as a container, but it only stores data of type int32.
// But because it is a JS object, it can only be modified using the napi method, resulting in lower performance.
static napi_value ArrayDemo(napi_env env, napi_callback_info info)
{
    constexpr size_t arrSize = 1000;
    napi_value jsArr = nullptr;
    napi_create_array(env, &jsArr);
    for (int i = 0; i < arrSize; i++) {
        napi_value arrValue = nullptr;
        napi_create_int32(env, i, &arrValue);
        // Conventional JSArray uses napi method to read and write arrays, which results in poor performance.
        napi_set_element(env, jsArr, i, arrValue);
    }
    return jsArr;
}


// Recommended writing style:
// Taking int32 type data as an example, but the following code uses an ArrayBuffer as the container.
// Therefore, C/C++methods can be used to directly modify the buffer.
static napi_value ArrayBufferDemo(napi_env env, napi_callback_info info)
{
    constexpr size_t arrSize = 1000;
    napi_value arrBuffer = nullptr;
    void* data = nullptr;


    napi_create_arraybuffer(env, arrSize * sizeof(int32_t), &data, &arrBuffer);
    // Data is a null pointer, cancel writing to data
    if (data == nullptr) {
        return arrBuffer;
    }
    int32_t* i32Buffer = reinterpret_cast<int32_t*>(data);
    for (int i = 0; i < arrSize; i++) {
        // ArrayBuffer directly modifies the buffer, skipping runtime,
        // Equivalent in performance to manipulating C/C++objects
        i32Buffer[i] = i;
    }


    return arrBuffer;
}
// [End napi_array_demo]

// [Start create_my_external]
static void MyFinalizeCB(napi_env env, void *finalize_data, void *finalize_hint) { return; };

static napi_value CreateMyExternal(napi_env env, napi_callback_info info) {
    napi_value result = nullptr;
    napi_create_external(env, nullptr, MyFinalizeCB, nullptr, &result);
    return result;
}

// The code for module registration has been omitted here. You may need to register the CreateMyExternal method yourself
// [End create_my_external]

// [Start Init]
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // [StartExclude Init]
    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"createMyExternal", nullptr, CreateMyExternal, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    // [EndExclude Init]
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
// [End Init]