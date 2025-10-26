/**
 * FAQ:多so相互依赖场景下如何解耦
 */
// [Start demo_so]
// hello.cpp
#include "a.h"
#include "b.h"
#include "napi/native_api.h"

static napi_value Add(napi_env env, napi_callback_info info) {
    size_t requireArgc = 3;
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);
    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);
    napi_valuetype valuetype2;
    napi_typeof(env, args[2], &valuetype2);
    int value0;
    napi_get_value_int32(env, args[0], &value0);
    int value1;
    napi_get_value_int32(env, args[1], &value1);
    char path[255];
    size_t size = 255;
    napi_get_value_string_utf8(env, args[2], path, 255, &size);
    int res = geta(path, value0, value1);                    // Call the function and pass the sandbox path
    napi_value sum;
    napi_create_int32(env, res, &sum);
    return sum;
}
static napi_value Sub(napi_env env, napi_callback_info info) {
    size_t requireArgc = 3;
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    napi_valuetype valuetype0;
    napi_typeof(env, args[0], &valuetype0);
    napi_valuetype valuetype1;
    napi_typeof(env, args[1], &valuetype1);
    napi_valuetype valuetype2;
    napi_typeof(env, args[2], &valuetype2);
    int value0;
    napi_get_value_int32(env, args[0], &value0);
    int value1;
    napi_get_value_int32(env, args[1], &value1);
    char path[255];
    size_t size = 255;
    napi_get_value_string_utf8(env, args[2], path, 255, &size);
    int res = getb(path, value0, value1);                 // Call the function and pass the sandbox path
    napi_value sum;
    napi_create_int32(env, res, &sum);
    return sum;
}
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {{"add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr},
                                       {"sub", nullptr, Sub, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "demoso",
    .nm_priv = ((void *)0),
    .reserved = {0},
};
extern "C" __attribute__((constructor)) void RegisterDemosoModule(void) { napi_module_register(&demoModule); }
// [End demo_so]