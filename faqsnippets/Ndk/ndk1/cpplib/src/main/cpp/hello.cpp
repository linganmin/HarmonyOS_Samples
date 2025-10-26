/**
 * FAQ: 如何对多个C++源文件中接口进行导出声明
 */
// [Start number_type_hello]
#include "NumberType.h"
#include "napi/native_api.h"

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    /* Associate the externally provided interface with the written method, for example, associate add with the Add 
     * method. 
    */ 
    napi_property_descriptor desc[] = {
        { "add", nullptr, NumberType::Add, nullptr, nullptr, nullptr, napi_default, nullptr }
    };
    // napi_define_properties construct a return value that contains a list of methods that correspond. 
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END
// [End number_type_hello]
static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "cpplib",
    .nm_priv = ((void*)0),
    .reserved = { 0 },
};

extern "C" __attribute__((constructor)) void RegisterCpplibModule(void)
{
    napi_module_register(&demoModule);
}
