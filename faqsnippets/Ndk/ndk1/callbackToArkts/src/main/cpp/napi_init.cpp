//FAQ:ArkTS侧如何接收Native侧的键值对进行修改并返回到Native侧
// [Start call_back_to_arkts_cpp]
#include "napi/native_api.h" 
#include "hilog/log.h" 
#undef LOG_DOMAIN 
#undef LOG_TAG 
#define LOG_DOMAIN 0x3200 
#define LOG_TAG "MY_TAG" 
 
static bool Napi_AddPropertyInt32(napi_env env, napi_value obj, const char *key, int32_t value) { 
    napi_value key_napi = nullptr; 
    napi_status status = napi_create_string_utf8(env, key, NAPI_AUTO_LENGTH, &key_napi); 
    napi_value value_napi = nullptr; 
    status = napi_create_int32(env, value, &value_napi); 
    status = napi_set_property(env, obj, key_napi, value_napi); 
    return true; 
} 
static  napi_value CallbackToArkTS(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value args[1] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    // Native callback to ArkTS layer object
    napi_value argv = nullptr; 
    napi_create_object(env, &argv); 
    Napi_AddPropertyInt32(env, argv, "type", 1); 
    Napi_AddPropertyInt32(env, argv, "index", 2); 
    // Native callback to ArkTS layer
    napi_value result = nullptr; 
    napi_call_function(env, NULL, args[0], 1, &argv, &result); 
    // Obtain the modified object of ArkTS
    napi_value typeNumber = nullptr; 
    napi_get_named_property(env, result, "type", &typeNumber); 
    int32_t number; 
    napi_get_value_int32(env, typeNumber, &number); 
    OH_LOG_INFO(LOG_APP, "ArkTS modified type：%{public}d", number); 
    // Return the modified object
    return result; 
} 
EXTERN_C_START 
static napi_value Init(napi_env env, napi_value exports) 
{ 
    napi_property_descriptor desc[] = { 
        { "callbackToArkTS", nullptr, CallbackToArkTS, nullptr, nullptr, nullptr, napi_default, nullptr } 
    }; 
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc); 
    return exports; 
} 
EXTERN_C_END 
// [End call_back_to_arkts_cpp]

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterCallbackToArktsModule(void)
{
    napi_module_register(&demoModule);
}
