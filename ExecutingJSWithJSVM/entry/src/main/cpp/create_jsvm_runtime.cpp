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
#include "ark_runtime/jsvm.h"
#include "common.h"
#include <deque>
#include <map>
#include <hilog/log.h>
#include <cstring>
#include <mutex>
#include <string>
#include <rawfile/raw_file_manager.h>
#define MY_LOG_TAG "TEST_TAG"

using namespace std;
// Define a map to manage each independent VM environment.
static map<int, JSVM_VM *> g_vmMap;
static map<int, JSVM_VMScope> g_vmScopeMap;
static map<int, JSVM_Env *> g_envMap;
static map<int, napi_env> g_napiEnvMap;
static map<int, JSVM_EnvScope> g_envScopeMap;
static map<int, napi_ref> g_callBackMap;
static map<int, JSVM_CallbackStruct *> g_callBackStructMap;
static uint32_t ENV_TAG_NUMBER = 0;
static std::mutex envMapLock;
static int g_count = 0;

class Task {
public:
    virtual ~Task() = default;
    virtual void Run() = 0;
};
static map<int, deque<Task *>> g_taskQueueMap;

// Define a custom ConsoleInfo method.
static JSVM_Value ConsoleInfo(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 1;
    JSVM_Value args[1];
    char log[256] = "";
    size_t log_length;
    OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL);

    OH_JSVM_GetValueStringUtf8(env, args[0], log, 255, &log_length);
    log[255] = 0;
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: %{public}s", log);
    return nullptr;
}

// Define a custom createPromise method to create Promises in JS code.
static JSVM_Value CreatePromise(JSVM_Env env, JSVM_CallbackInfo info) {
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise start");
    int envID = 0;
    // Obtain the envID through the current env.
    for (auto it = g_envMap.begin(); it != g_envMap.end(); ++it) {
        if (*it->second == env) {
            envID = it->first;
            break;
        }
    }
    if (envID == -1) {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise envID failed");
        return nullptr;
    }
    JSVM_Value promise;
    JSVM_Deferred deferred;
    OH_JSVM_CreatePromise(env, &deferred, &promise);
    // Design a ReadTask class to add the deferred object of a promise to the execution queue.
    class ReadTask : public Task {
    public:
        ReadTask(JSVM_Env env, JSVM_Deferred deferred, int envNum) : env_(env), envID_(envNum), deferred_(deferred) {}
        void Run() override {
            int envID = 0;
            for (auto it = g_envMap.begin(); it != g_envMap.end(); ++it) {
                if (*it->second == env_) {
                    envID = it->first;
                    break;
                }
            }
            OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise %{public}d", envID);
            JSVM_Value result;
            OH_JSVM_CreateInt32(env_, envID, &result);
            OH_JSVM_ResolveDeferred(env_, deferred_, result);
        }

    private:
        JSVM_Env env_;
        int envID_;
        JSVM_Deferred deferred_;
    };
    g_taskQueueMap[envID].push_back(new ReadTask(env, deferred, envID));
    OH_LOG_INFO(LOG_APP, "JSVM API TEST: CreatePromise end");
    return promise;
}


// Define a custom AssertEqual method.
static JSVM_Value AssertEqual(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 2;
    JSVM_Value args[2];
    JSVM_CALL(env, OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL));

    bool isStrictEquals = false;
    OH_JSVM_StrictEquals(env, args[0], args[1], &isStrictEquals);

    if (isStrictEquals) {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST RESULT: PASS");
    } else {
        OH_LOG_INFO(LOG_APP, "JSVM API TEST RESULT: FAILED");
    }
    return nullptr;
}

// To call the Callback function passed from the TS side in the native layer.
static JSVM_Value OnJSResultCallback(JSVM_Env env, JSVM_CallbackInfo info) {
    size_t argc = 3;
    JSVM_Value args[3];
    JSVM_CALL(env, OH_JSVM_GetCbInfo(env, info, &argc, args, NULL, NULL));
    int callId = 0;
    OH_JSVM_GetValueInt32(env, args[0], &callId);
    napi_value callArgs[2] = {nullptr, nullptr};
    size_t size1;
    size_t size2;

    OH_JSVM_GetValueStringUtf8(env, args[1], nullptr, 0, &size1);
    char str1[size1 + 1];
    OH_JSVM_GetValueStringUtf8(env, args[1], str1, size1 + 1, &size1);

    OH_JSVM_GetValueStringUtf8(env, args[2], nullptr, 0, &size2);
    char str2[size2 + 1];
    OH_JSVM_GetValueStringUtf8(env, args[2], str2, size2 + 1, &size2);

    napi_create_string_utf8(g_napiEnvMap[callId], str1, size1 + 1, &callArgs[0]);
    napi_create_string_utf8(g_napiEnvMap[callId], str2, size2 + 1, &callArgs[1]);
    napi_value callback = nullptr;
    // Obtain the TS callback method passed when creating the current JSVM environment through the callId.
    napi_get_reference_value(g_napiEnvMap[callId], g_callBackMap[callId], &callback);
    napi_value ret;
    // execute ts callback.
    napi_call_function(g_napiEnvMap[callId], nullptr, callback, 2, callArgs, &ret);
    char retStr[256];
    napi_get_value_string_utf8(g_napiEnvMap[callId], ret, retStr, 256, &size1);

    JSVM_Value returnVal;
    OH_JSVM_CreateStringUtf8(env, retStr, JSVM_AUTO_LENGTH, &returnVal);
    return returnVal;
}

std::string napiValueToString(napi_env env, napi_value nValue) {
    size_t buffLen = 0;
    napi_get_value_string_utf8(env, nValue, nullptr, 0, &buffLen);
    char buffer[buffLen + 1];
    napi_get_value_string_utf8(env, nValue, buffer, buffLen + 1, &buffLen);
    return buffer;
}

static std::string fromOHStringValue(JSVM_Env &env, JSVM_Value &value) {
    size_t size;
    JSVM_Status status;
    status = OH_JSVM_GetValueStringUtf8(env, value, nullptr, 0, &size);
    char resultStr[size + 1];
    status = OH_JSVM_GetValueStringUtf8(env, value, resultStr, size + 1, &size);
    return resultStr;
}

static void CreateArkJSContext() {
    JSVM_Status status;
    JSVM_InitOptions init_options;
    memset(&init_options, 0, sizeof(init_options));
    if (g_count == 0) {
        OH_JSVM_Init(&init_options);
        g_count++;
    }

    g_vmMap[ENV_TAG_NUMBER] = new JSVM_VM;
    JSVM_VMScope vmScope;
    g_vmScopeMap[ENV_TAG_NUMBER] = vmScope;
    JSVM_CreateVMOptions options;
    memset(&options, 0, sizeof(options));
    status = OH_JSVM_CreateVM(&options, g_vmMap[ENV_TAG_NUMBER]);
    status = OH_JSVM_OpenVMScope(*g_vmMap[ENV_TAG_NUMBER], &g_vmScopeMap[ENV_TAG_NUMBER]);

    g_envMap[ENV_TAG_NUMBER] = new JSVM_Env;
    g_callBackStructMap[ENV_TAG_NUMBER] = new JSVM_CallbackStruct[5];

    for (int i = 0; i < 5; i++) {
        g_callBackStructMap[ENV_TAG_NUMBER][i].data = nullptr;
    }
    g_callBackStructMap[ENV_TAG_NUMBER][0].callback = ConsoleInfo;
    g_callBackStructMap[ENV_TAG_NUMBER][2].callback = AssertEqual;
    g_callBackStructMap[ENV_TAG_NUMBER][3].callback = OnJSResultCallback;
    g_callBackStructMap[ENV_TAG_NUMBER][4].callback = CreatePromise;
    JSVM_PropertyDescriptor descriptors[] = {
        {"consoleInfo", NULL, &g_callBackStructMap[ENV_TAG_NUMBER][0], NULL, NULL, NULL, JSVM_DEFAULT},
        {"add", NULL, &g_callBackStructMap[ENV_TAG_NUMBER][1], NULL, NULL, NULL, JSVM_DEFAULT},
        {"assertEqual", NULL, &g_callBackStructMap[ENV_TAG_NUMBER][2], NULL, NULL, NULL, JSVM_DEFAULT},
        {"onJSResultCallback", NULL, &g_callBackStructMap[ENV_TAG_NUMBER][3], NULL, NULL, NULL, JSVM_DEFAULT},
        {"createPromise", NULL, &g_callBackStructMap[ENV_TAG_NUMBER][4], NULL, NULL, NULL, JSVM_DEFAULT},
    };
    status = OH_JSVM_CreateEnv(*g_vmMap[ENV_TAG_NUMBER], sizeof(descriptors) / sizeof(descriptors[0]), descriptors,
                               g_envMap[ENV_TAG_NUMBER]);
    JSVM_EnvScope envScope;
    g_envScopeMap[ENV_TAG_NUMBER] = envScope;
    status = OH_JSVM_OpenEnvScope(*g_envMap[ENV_TAG_NUMBER], &g_envScopeMap[ENV_TAG_NUMBER]);
}

// Provide an external interface to create a JSVM runtime environment and return the corresponding unique ID.
static napi_value CreateJsCore(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "JSVM CreateJsCore START");
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (argc < 1) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore the number of params must be one");
        return nullptr;
    }
    g_napiEnvMap[ENV_TAG_NUMBER] = env;
    g_taskQueueMap[ENV_TAG_NUMBER] = deque<Task *>{};
    napi_ref callFun;
    napi_create_reference(env, argv[0], 1, &callFun);
    g_callBackMap[ENV_TAG_NUMBER] = callFun;
    napi_value coreID = 0;
    
    CreateArkJSContext();
    napi_create_uint32(env, ENV_TAG_NUMBER, &coreID);
    ENV_TAG_NUMBER++;
    
    OH_LOG_INFO(LOG_APP, "JSVM CreateJsCore END");
    return coreID;
}

// Using the envId to release the corresponding environment.
static napi_value ReleaseJsCore(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "JSVM ReleaseJsCore START");
    size_t argc = 1;
    napi_value argv[1];
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (argc < 1) {
        OH_LOG_ERROR(LOG_APP, "JSVM ReleaseJsCore the number of params must be one");
        return nullptr;
    }

    uint32_t coreEnvId;
    napi_status status = napi_get_value_uint32(env, argv[0], &coreEnvId);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore napi_get_value_uint32 failed");
        return nullptr;
    }
    if (g_envMap.count(coreEnvId) == 0) {
        OH_LOG_ERROR(LOG_APP, "JSVM CreateJsCore not has env ");
        return nullptr;
    }
    if (g_envMap[coreEnvId] != nullptr) {
        OH_JSVM_CloseEnvScope(*g_envMap[coreEnvId], g_envScopeMap[coreEnvId]);
        g_envScopeMap.erase(coreEnvId);
        OH_JSVM_DestroyEnv(*g_envMap[coreEnvId]);
        g_envMap[coreEnvId] = nullptr;
        g_envMap.erase(coreEnvId);
        OH_JSVM_CloseVMScope(*g_vmMap[coreEnvId], g_vmScopeMap[coreEnvId]);
        g_vmScopeMap.erase(coreEnvId);
        OH_JSVM_DestroyVM(*g_vmMap[coreEnvId]);
        g_vmMap[coreEnvId] = nullptr;
        g_vmMap.erase(coreEnvId);
        delete[] g_callBackStructMap[coreEnvId];
        g_callBackStructMap[coreEnvId] = nullptr;
        g_callBackStructMap.erase(coreEnvId);
        napi_delete_reference(env, g_callBackMap[coreEnvId]);
        g_callBackMap.erase(coreEnvId);
        g_taskQueueMap.erase(coreEnvId);
    }
    OH_LOG_INFO(LOG_APP, "JSVM ReleaseJsCore END");
    return nullptr;
}

static std::mutex mutexLock;

static napi_value EvaluateJS(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "JSVM EvaluateJS START");
    size_t argc = 2;
    napi_value args[2] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    uint32_t envId;
    napi_status status = napi_get_value_uint32(env, args[0], &envId);
    if (status != napi_ok) {
        OH_LOG_ERROR(LOG_APP, "EvaluateJS first param should be number");
        return nullptr;
    }

    if (g_envMap.count(envId) == 0 || g_envMap[envId] == nullptr) {
        OH_LOG_ERROR(LOG_APP, "EvaluateJS env is null");
        return nullptr;
    }
    std::string dataStr = napiValueToString(env, args[1]);
    napi_value res = nullptr;
    {
        JSVM_HandleScope handleScope;
        OH_JSVM_OpenHandleScope(*g_envMap[envId], &handleScope);
        JSVM_Value sourceCodeValue;
        OH_JSVM_CreateStringUtf8(*g_envMap[envId], dataStr.c_str(), dataStr.size(), &sourceCodeValue);
        JSVM_Script script;
        OH_JSVM_CompileScript(*g_envMap[envId], sourceCodeValue, nullptr, 0, true, nullptr, &script);
        JSVM_Value JSVMRes;
        OH_JSVM_RunScript(*g_envMap[envId], script, &JSVMRes);
        JSVM_ValueType type;
        // Execute tasks in the current env event queue
        while (!g_taskQueueMap[envId].empty()) {
            auto task = g_taskQueueMap[envId].front();
            g_taskQueueMap[envId].pop_front();
            task->Run();
            delete task;
        }

        if (type == JSVM_STRING) {
            std::string stdResult = fromOHStringValue(*g_envMap[envId], JSVMRes);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_BOOLEAN) {
            bool ret = false;
            std::string stdResult;
            OH_JSVM_GetValueBool(*g_envMap[envId], JSVMRes, &ret);
            ret ? stdResult = "true" : stdResult = "false";
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_NUMBER) {
            int32_t num;
            OH_JSVM_GetValueInt32(*g_envMap[envId], JSVMRes, &num);
            std::string stdResult = std::to_string(num);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        } else if (type == JSVM_OBJECT) {
            JSVM_Value objResult;
            OH_JSVM_JsonStringify(*g_envMap[envId], JSVMRes, &objResult);
            std::string stdResult = fromOHStringValue(*g_envMap[envId], objResult);
            napi_create_string_utf8(env, stdResult.c_str(), stdResult.length(), &res);
        }
        OH_JSVM_CloseHandleScope(*g_envMap[envId], handleScope);
    }
    OH_LOG_INFO(LOG_APP, "JSVM EvaluateJS END");
    return res;
}


static std::string g_txt;

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"createJsCore", nullptr, CreateJsCore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"releaseJsCore", nullptr, ReleaseJsCore, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"evaluateJS", nullptr, EvaluateJS, nullptr, nullptr, nullptr, napi_default, nullptr}};

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