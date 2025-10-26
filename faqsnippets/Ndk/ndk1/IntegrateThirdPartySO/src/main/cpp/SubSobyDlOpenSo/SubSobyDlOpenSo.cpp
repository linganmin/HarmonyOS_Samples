//
// Created on 2025/5/22.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "napi/native_api.h"
#include "SubSobyDlOpenSo.h"

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