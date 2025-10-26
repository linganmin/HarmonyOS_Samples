//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

// [Start native_call]
#include "napi/native_api.h" 
#include <assert.h> 
static napi_value NativeCall(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value args[1] = { nullptr }; 
    napi_status status; 
    status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    assert(status == napi_ok); 
    napi_valuetype valuetype; 
    napi_typeof(env, args[0], &valuetype); 
    if (valuetype != napi_valuetype::napi_function) { 
        napi_throw_type_error(env, nullptr, "napi_function is expected"); 
    } 
    napi_value cb = args[0]; 
    napi_value undefined; 
    status = napi_get_undefined(env, &undefined); 
    assert(status == napi_ok); 
    napi_value argv[2] = { nullptr }; 
    status = napi_create_int32(env, 1, &argv[0]); 
    assert(status == napi_ok); 
    status = napi_create_int32(env, 2, &argv[1]); 
    assert(status == napi_ok); 
    napi_value result; 
    status = napi_call_function(env, undefined, cb, 2, argv, &result); 
    assert(status == napi_ok); 
    return nullptr; 
} 
EXTERN_C_START 
static napi_value Init(napi_env env, napi_value exports) { 
    napi_property_descriptor desc[] = { 
        { "nativeCall", nullptr, NativeCall, nullptr, nullptr, nullptr, napi_default, nullptr } 
    }; 
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc); 
    return exports; 
} 
EXTERN_C_END 
static napi_module module = { 
    .nm_version = 1, 
    .nm_flags = 0, 
    .nm_filename = nullptr, 
    .nm_register_func = Init, 
    .nm_modname = "callback", 
    .nm_priv = nullptr, 
    .reserved = { 0 }, 
}; 
extern "C" __attribute__((constructor)) void RegisterCallbackModule(void) { 
    napi_module_register(&module); 
}
// [End native_call]