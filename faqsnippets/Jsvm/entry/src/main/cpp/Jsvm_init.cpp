//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
//FAQ:如何管理JSVM_CallbackStruct生命周期

#include "napi/native_api.h"
#include "hilog/log.h"
#include "ark_runtime/jsvm.h"


#define LOG_DOMAIN 0x3200
#define LOG_TAG "APP"

static int g_aa = 0;

#define CHECK_RET(theCall)                                                                                             \
    do {                                                                                                               \
        JSVM_Status cond = theCall;                                                                                    \
        if ((cond) != JSVM_OK) {                                                                                       \
            const JSVM_ExtendedErrorInfo *info;                                                                        \
            OH_JSVM_GetLastErrorInfo(env, &info);                                                                      \
            OH_LOG_ERROR(LOG_APP, "jsvm fail file: %{public}s line: %{public}d ret = %{public}d message = %{public}s", \
                         __FILE__, __LINE__, cond, info != nullptr ? info->errorMessage : "");                         \
            return -1;                                                                                                 \
        }                                                                                                              \
    } while (0)

#define CHECK(theCall)                                                                                                 \
    do {                                                                                                               \
        JSVM_Status cond = theCall;                                                                                    \
        if ((cond) != JSVM_OK) {                                                                                       \
            OH_LOG_ERROR(LOG_APP, "jsvm fail file: %{public}s line: %{public}d ret = %{public}d", __FILE__, __LINE__,  \
                         cond);                                                                                        \
            return -1;                                                                                                 \
        }                                                                                                              \
    } while (0)

// 用于调用theCall并检查其返回值是否为JSVM_OK。
// 如果不是，则调用OH_JSVM_GetLastErrorInfo处理错误并返回retVal。
#define JSVM_CALL_BASE(env, theCall, retVal)                                                                           \
    do {                                                                                                               \
        JSVM_Status cond = theCall;                                                                                    \
        if (cond != JSVM_OK) {                                                                                         \
            const JSVM_ExtendedErrorInfo *info;                                                                        \
            OH_JSVM_GetLastErrorInfo(env, &info);                                                                      \
            OH_LOG_ERROR(LOG_APP, "jsvm fail file: %{public}s line: %{public}d ret = %{public}d message = %{public}s", \
                         __FILE__, __LINE__, cond, info != nullptr ? info->errorMessage : "");                         \
            return retVal;                                                                                             \
        }                                                                                                              \
    } while (0)

// JSVM_CALL_BASE的简化版本，返回nullptr
#define JSVM_CALL(theCall) JSVM_CALL_BASE(env, theCall, nullptr)

//[Start create_function]
JSVM_Value CreateFunction(JSVM_Env env) {
    JSVM_Callback cb = new JSVM_CallbackStruct;
    cb->data = nullptr;
    cb->callback = [](JSVM_Env env, JSVM_CallbackInfo info) -> JSVM_Value { return nullptr; };

    JSVM_Value result = nullptr;
    OH_JSVM_CreateFunction(env, "foo", JSVM_AUTO_LENGTH, cb, &result);
    OH_JSVM_AddFinalizer(
        env, result, reinterpret_cast<void *>(cb),
        [](JSVM_Env env, void *data, void *hint) -> void { 
            delete static_cast<JSVM_Callback>(data);
        }, nullptr, nullptr);

    return result;
}
//[End create_function]

// OH_JSVM_StrictEquals的样例方法
static JSVM_Value IsStrictEquals(JSVM_Env env, JSVM_CallbackInfo info) {
    // 接受两个入参
    size_t argc = 2;
    JSVM_Value args[2] = {nullptr};
    JSVM_CALL(OH_JSVM_GetCbInfo(env, info, &argc, args, nullptr, nullptr));
    // 调用OH_JSVM_StrictEquals接口判断给定的两个JavaScript value是否严格相等
    bool result = false;
    JSVM_Status status = OH_JSVM_StrictEquals(env, args[0], args[1], &result);
    if (status != JSVM_OK) {
        OH_LOG_ERROR(LOG_APP, "JSVM OH_JSVM_StrictEquals: failed");
    } else {
        OH_LOG_INFO(LOG_APP, "JSVM OH_JSVM_StrictEquals: success: %{public}d", result);
    }
    JSVM_Value isStrictEqual;
    JSVM_CALL(OH_JSVM_GetBoolean(env, result, &isStrictEqual));
    return isStrictEqual;
}
// IsStrictEquals注册回调
static JSVM_CallbackStruct param[] = {
    {.data = nullptr, .callback = IsStrictEquals},
};
static JSVM_CallbackStruct *method = param;
// IsStrictEquals方法别名，供JS调用
static JSVM_PropertyDescriptor descriptor[] = {
    {"isStrictEquals", nullptr, method++, nullptr, nullptr, nullptr, JSVM_DEFAULT},
};
// 样例测试js
const char *srcCallNative = R"JS(    let data = '123';
    let value = 123;
    isStrictEquals(data,value);)JS";

static int32_t TestJSVM() {
    JSVM_InitOptions initOptions = {0};
    JSVM_VM vm;
    JSVM_Env env = nullptr;
    JSVM_VMScope vmScope;
    JSVM_EnvScope envScope;
    JSVM_HandleScope handleScope;
    JSVM_Value result;
    // 初始化JavaScript引擎实例
    if (g_aa == 0) {
        g_aa++;
       CHECK(OH_JSVM_Init(&initOptions));
    }
    // 创建JSVM环境
    CHECK(OH_JSVM_CreateVM(nullptr, &vm));
    CHECK(OH_JSVM_CreateEnv(vm, sizeof(descriptor) / sizeof(descriptor[0]), descriptor, &env));
    CHECK(OH_JSVM_OpenVMScope(vm, &vmScope));
    CHECK_RET(OH_JSVM_OpenEnvScope(env, &envScope));
    CHECK_RET(OH_JSVM_OpenHandleScope(env, &handleScope));

    // 通过script调用测试函数
    JSVM_Script script;
    JSVM_Value jsSrc;
    CHECK_RET(OH_JSVM_CreateStringUtf8(env, srcCallNative, JSVM_AUTO_LENGTH, &jsSrc));
    CHECK_RET(OH_JSVM_CompileScript(env, jsSrc, nullptr, 0, true, nullptr, &script));
    CHECK_RET(OH_JSVM_RunScript(env, script, &result));

    // 销毁JSVM环境
    CHECK_RET(OH_JSVM_CloseHandleScope(env, handleScope));
    CHECK_RET(OH_JSVM_CloseEnvScope(env, envScope));
    CHECK(OH_JSVM_CloseVMScope(vm, vmScope));
    CHECK(OH_JSVM_DestroyEnv(env));
    CHECK(OH_JSVM_DestroyVM(vm));
    return 0;
}

static napi_value RunTest(napi_env env, napi_callback_info info)
{
    TestJSVM();
    return nullptr;
}

// 模块初始化
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    // 实现ArkTS接口与C++接口的绑定和映射  
    napi_property_descriptor desc[] = {
      {"runTest", nullptr, RunTest, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    // 在exports对象上挂载RunJsVm的Native方法
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