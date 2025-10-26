/**
 * FAQ:ArkTS侧与Native侧分别如何动态加载SO库
 */
// [Start dlopen_so]
#include "napi/native_api.h" 
#include <dlfcn.h> 
typedef double (*FUNC_ADD)(int, int); 
static napi_value AddByLibPath(napi_env env, napi_callback_info info) { 
    size_t requireArgc = 3; 
    size_t argc = 3; 
    napi_value args[3] = {nullptr}; 
    napi_get_cb_info(env, info, &argc, args, nullptr, nullptr); 
    double value0; 
    napi_get_value_double(env, args[0], &value0); 
    double value1; 
    napi_get_value_double(env, args[1], &value1); 
    char path[255]; 
    size_t size = 255; 
    napi_get_value_string_utf8(env, args[2], path, 255, &size); // Obtain dynamic library path information 
    void *handle = dlopen(path, RTLD_LAZY);                     // Open a dynamic link library, The path is "path".  
    dlerror(); 
    FUNC_ADD add_func = (FUNC_ADD)dlsym(handle, "add"); // Retrieve the function named "add" 
    if (dlerror()) { 
        return nullptr; 
    } 
    double res = add_func(value0, value1);              // Call add and pass the parameter information 
    dlclose(handle);                                    // Close the dynamic library 
    napi_value sum; 
    napi_create_double(env, res, &sum); 
    return sum; 
} 
// ...
// [End dlopen_so]

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "addByLibPath", nullptr, AddByLibPath, nullptr, nullptr, nullptr, napi_default, nullptr }
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

extern "C" __attribute__((constructor)) void RegisterDynamicallyloadModule(void)
{
    napi_module_register(&demoModule);
}
