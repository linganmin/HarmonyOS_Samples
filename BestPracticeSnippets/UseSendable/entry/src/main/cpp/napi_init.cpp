/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#include "napi/native_api.h"
#include <cassert>
#include <mutex>
#include <unordered_set>

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

/*
 * 最佳实践: 应用并发设计 线程间通信 跨语言多线程通信（C++与ArkTS）
 */
// [Start callbackdata]
// napi_init.cpp
struct CallbackData {
    napi_env env;
    napi_async_work asyncWork = nullptr;
    napi_threadsafe_function tsfn = nullptr;
    int32_t data = -1;
};

static void CallJs(napi_env env, napi_value jsCb, void *context, void *data) {
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    napi_value global;
    assert(napi_get_global(env, &global) == napi_ok);
    napi_value number;
    assert(napi_create_int32(env, callbackData->data, &number) == napi_ok);
    assert(napi_call_function(env, global, jsCb, 1, &number, nullptr) == napi_ok);
}
static void NativeThread(void *data) {
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);
    /* Cross-thread call */
    {
        assert(napi_acquire_threadsafe_function(callbackData->tsfn) == napi_ok);

        callbackData->data = 123456;
        napi_status status = napi_call_threadsafe_function(callbackData->tsfn, callbackData, napi_tsfn_blocking);
        assert(status == napi_ok);
    }
}
static void ThreadFinished(napi_env env, void *data, [[maybe_unused]] void *context) {
    CallbackData *callbackData = reinterpret_cast<CallbackData *>(data);

    assert(napi_release_threadsafe_function(callbackData->tsfn, napi_tsfn_release) == napi_ok);
    ;
    callbackData->asyncWork = nullptr;
    callbackData->tsfn = nullptr;
    delete callbackData;
}
static napi_value NativeCall(napi_env env, napi_callback_info info) {
    napi_value resourceName = nullptr;
    CallbackData *callbackData = new CallbackData;
    callbackData->env = env;

    napi_value jsCb = nullptr;
    size_t argc = 1;

    assert(napi_get_cb_info(env, info, &argc, &jsCb, nullptr, nullptr) == napi_ok);
    assert(argc == 1);

    assert(napi_create_string_utf8(env, "Call thread-safe function from c++ thread", NAPI_AUTO_LENGTH, &resourceName) ==
           napi_ok);
    napi_status status;
    status = napi_create_threadsafe_function(env, jsCb, nullptr, resourceName, 0, 1, callbackData, ThreadFinished,
                                             callbackData, CallJs, &(callbackData->tsfn));
    assert(status == napi_ok);
    return nullptr;
}
// [End callbackdata]

/*
 * 最佳实践: 应用并发设计 线程间通信 线程间模块共享（单例模式） （方案一）
 */
// [Start singleton]
// napi_init.cpp
class Singleton {
public:
    static Singleton &GetInstance() {
        static Singleton instance;
        return instance;
    }
    static napi_value GetAddress(napi_env env, napi_callback_info info) {
        uint64_t addressVal = reinterpret_cast<uint64_t>(&GetInstance());
        napi_value napiAddress = nullptr;
        napi_create_bigint_uint64(env, addressVal, &napiAddress);
        return napiAddress;
    }
    static napi_value GetSetSize(napi_env env, napi_callback_info info) {
        std::lock_guard<std::mutex> lock(Singleton::GetInstance().numberSetMutex_);
        uint32_t setSize = Singleton::GetInstance().numberSet_.size();
        napi_value napiSize = nullptr;
        napi_create_uint32(env, setSize, &napiSize);
        return napiSize;
    }
    static napi_value Store(napi_env env, napi_callback_info info) {
        size_t argc = 1;
        napi_value args[1] = {nullptr};
        napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
        if (argc != 1) {
            napi_throw_error(env, "ERROR: ", "store args number must be one");
            return nullptr;
        }
        napi_valuetype type = napi_undefined;
        napi_typeof(env, args[0], &type);
        if (type != napi_number) {
            napi_throw_error(env, "ERROR: ", "store args is not number");
            return nullptr;
        }
        std::lock_guard<std::mutex> lock(Singleton::GetInstance().numberSetMutex_);
        uint32_t value = 0;
        napi_get_value_uint32(env, args[0], &value);
        Singleton::GetInstance().numberSet_.insert(value);
        return nullptr;
    }

private:
    Singleton() {}                                    // Private constructor to prevent external instantiation of objects
    Singleton(const Singleton &) = delete;            // Do not copy the constructor
    Singleton &operator=(const Singleton &) = delete; // The assignment operator is prohibited

public:
    std::unordered_set<uint32_t> numberSet_{};
    std::mutex numberSetMutex_{};
};
// [End singleton]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"nativeCall", nullptr, NativeCall, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getAddress", nullptr, Singleton::GetAddress, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSetSize", nullptr, Singleton::GetSetSize, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"store", nullptr, Singleton::Store, nullptr, nullptr, nullptr, napi_default, nullptr}};
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