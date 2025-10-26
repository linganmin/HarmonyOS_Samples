/**
 * FAQ: 在Native侧如何集成三方SO库
 */
#include "napi/native_api.h"

// [Start dlopen_so_cpp]
#include <dlfcn.h>
typedef double (*Sub)(double, double);
static napi_value SubSobyDlOpenSo(napi_env env, napi_callback_info info) {
    size_t requireArgc = 3;
    size_t argc = 3;
    napi_value args[3] = {nullptr};
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    double value0;
    napi_get_value_double(env, args[0], &value0);    
    double value1;
    napi_get_value_double(env, args[1], &value1);
    char* path = new char[1024];
    size_t size = 1024;
    napi_get_value_string_utf8(env, args[2], path, 255, &size); // Obtain dynamic library path information
    void *handle = dlopen(path, RTLD_LAZY);                     // Open the dynamic link library with path as path
    napi_value result;
    Sub sub_func = (Sub)dlsym(handle, "sub");                   // Get the function named sub
    napi_create_double(env, sub_func(value0, value1), &result);
    dlclose(handle);                                            // Finally, close the dynamic library
    return result;
}
// [End dlopen_so_cpp]

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

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "subSobyDlOpenSo", nullptr, SubSobyDlOpenSo, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
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
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterIntegrateThirdPartySOModule(void)
{
    napi_module_register(&demoModule);
}
