//
// Created on 2025/5/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
// [Start call_napi]
static napi_value CallNapi(napi_env env, napi_callback_info info) { 
    size_t argc = 1; 
    napi_value object = nullptr; 
    napi_status status; 
    status = napi_get_cb_info(env, info, &argc, &object, nullptr, nullptr); 
    return object; 
} 
NAPI_MODULE_INIT() { 
    napi_property_descriptor desc[] = { 
        { "callNapi", nullptr, CallNapi, nullptr, nullptr, nullptr, napi_default, nullptr } 
    }; 
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc); 
    return exports; 
}
// [End call_napi]