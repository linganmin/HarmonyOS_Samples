#include "napi/native_api.h"
#include "NativeMap/NativeMap.h"
#include "Test/Test.h"
#include "TsFCallback/TsFCallback.h"
#include <hilog/log.h>

/**
 * FAQ:Native侧如何打印char指针
 */
void TestLog() {
    // [Start log_char]
    char *path = "abc";
    OH_LOG_INFO(LOG_APP, "path: %{public}s", path);
    // [End log_char]
}
static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value args[2] = {nullptr};

    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr);

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

/**
 * FAQ: Native如何调ArkTS的方法
 */
// [Start native_call_arkts_cpp]
static napi_value NativeCallArkTS(napi_env env, napi_callback_info info) 
{     
    size_t argc = 1; 
    // Declaring parameter array ARG
    napi_value args[1] = { nullptr }; 
 
    // Retrieve the passed parameters and place them in the parameter array 'rgs'
    napi_get_cb_info(env, info, &argc, args , nullptr, nullptr); 
 
    // Create int as an input parameter for ArkTS
    napi_value argv = nullptr;     
    napi_create_int32(env, 2, &argv ); 
 
    // Call the incoming callback and return the result
    napi_value result = nullptr; 
    napi_call_function(env, nullptr, args[0], 1, &argv, &result); 
    return result; 
}
// [End native_call_arkts_cpp]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "nativeCallArkTS", nullptr, NativeCallArkTS, nullptr, nullptr, nullptr, napi_default, nullptr },
        {"mapDemo", nullptr, NativeMap::MapDemo, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"testFunc", nullptr, Test::TestFunc, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"addTSFCallback", nullptr, AddTSFCallback, nullptr, nullptr, nullptr, napi_default, nullptr},
    };
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END
/*
* FAQ:napi_module结构体字段描述解析
*/

// [Start NapiModuleStructure]
static napi_module demoModule = {
    .nm_version = 1,             // nm Version number, default value is 1
    .nm_flags = 0,               // nm Identifier
    .nm_filename = nullptr,      // File name, don't pay attention to it for now, just use the default value
    .nm_register_func = Init,    // Specify the entrance function for nm
    .nm_modname = "entry",       // Specify the module name to import from the ArkTS page
    .nm_priv = ((void*)0),       // Don't follow for now, just use the default settings
    .reserved = { 0 },           // Don't pay attention for now, just use the default value
};
// [End NapiModuleStructure]
extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
