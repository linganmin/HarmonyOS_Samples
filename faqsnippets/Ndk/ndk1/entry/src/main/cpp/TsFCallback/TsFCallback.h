//
// Created on 2025/5/23.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef NDK1_TSFCALBACK_H
#define NDK1_TSFCALBACK_H
#include "napi/native_api.h"
#include "thread"

napi_threadsafe_function tsfn;
using namespace std;
struct CallbackData {
    napi_threadsafe_function tsfn;
    napi_async_work work;
    double result = 0;
    double data[2] = {0};
};

// [Start ts_f_callback]
static void CallJsFunction(napi_env env, napi_value callBack, [[maybe_unused]] void *context, void *data) {
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);

    napi_value callBackArgs = nullptr;
    napi_create_double(env, callbackData->result, &callBackArgs);
    napi_value callBackResult = nullptr;
    napi_call_function(env, nullptr, callBack, 1, &callBackArgs,
                       &callBackResult); // Call the callback to send the result to the ArkTS side.
    delete callbackData;
}

static void AddFunc(void *data) {
    CallbackData *callbackData = static_cast<CallbackData *>(data); // Parse the context, and process the service (add the two numbers).
    callbackData->result = callbackData->data[0] + callbackData->data[1]; // Place the result.
    napi_acquire_threadsafe_function(callbackData->tsfn);
    napi_call_threadsafe_function(callbackData->tsfn, data, napi_tsfn_blocking); // Call the thread-safe function.
    napi_release_threadsafe_function(callbackData->tsfn, napi_tsfn_release);
}

static napi_value AddTSFCallback(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {nullptr};

    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    CallbackData *callbackData = new CallbackData();
    napi_get_value_double(env, args[0], &callbackData->data[0]);
    napi_get_value_double(env, args[1], &callbackData->data[1]);

    napi_value resourceName = nullptr;
    napi_create_string_utf8(env, "Thread_safe Function", NAPI_AUTO_LENGTH, &resourceName);

    // Create a thread-safe function object, and register and bind callback and call_js_cb.
    napi_create_threadsafe_function(env, args[2], nullptr, resourceName, 0, 1, callbackData, nullptr, callbackData,
                                    CallJsFunction, &callbackData->tsfn);
    thread t(AddFunc, reinterpret_cast<void *>(callbackData)); // Create a C++ subthread to process service logic.
    t.detach();
    return nullptr;
}
// [End ts_f_callback]

#endif // NDK1_TSFCALBACK_H
