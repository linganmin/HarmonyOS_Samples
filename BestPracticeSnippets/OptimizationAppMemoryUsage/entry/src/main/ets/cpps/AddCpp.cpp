// [Start add_cpp]
#include "napi/native_api.h"
#define DATASIZE (4 * 1024 * 1024)
#include "purgeable_memory/purgeable_memory.h"

bool ModifyFunc(void *data, size_t size, void *param) {
    data = param;
    return true;
}
// Business definition object type
class ReqObj;
static napi_value Add(napi_env env, napi_callback_info info)
{
    size_t requireArgc = 2;
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
    double result = value0 + value1;
    // Create a PurgeableMemory object
    OH_PurgeableMemory *pPurgmem = OH_PurgeableMemory_Create(DATASIZE, ModifyFunc, &result);
    // Read the object
    OH_PurgeableMemory_BeginRead(pPurgmem);
    // Get the size of PurgeableMemory object
    size_t size = OH_PurgeableMemory_ContentSize(pPurgmem);
    // Get the content of the PurgeableMemory object
    ReqObj *pReqObj = (ReqObj *)OH_PurgeableMemory_GetContent(pPurgmem);
    // Read the end of the PurgeableMemory object
    OH_PurgeableMemory_EndRead(pPurgmem);
    
    // Modify the PurgeableMemory object
    OH_PurgeableMemory_BeginWrite(pPurgmem);
    // Declare the parameters of the extended creation function
    double newResult = value0 + value0;
    // Update PurgeableMemory object reconstruction rules
    OH_PurgeableMemory_AppendModify(pPurgmem, ModifyFunc, &newResult);
    // End of modifying the PurgeableMemory object
    OH_PurgeableMemory_EndWrite(pPurgmem);
    // Destroyed object
    OH_PurgeableMemory_Destroy(pPurgmem);
    napi_value sum;
    napi_create_double(env, result, &sum);
    return sum;
}
EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "add", nullptr, Add, nullptr, nullptr, nullptr, napi_default, nullptr }
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
extern "C" __attribute__((constructor)) void RegisterEntryModule(void)
{
    napi_module_register(&demoModule);
}
// [End add_cpp]