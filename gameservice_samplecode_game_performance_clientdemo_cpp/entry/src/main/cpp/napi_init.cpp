/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "napi/native_api.h"
#include "include/game_performance_sample.h"

static napi_value HMS_GamePerformance_Init(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = Init();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_RegisterThermalLevelChangedCallback(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = RegisterThermalLevelChangedCallback();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_UnregisterThermalLevelChangedCallback(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = UnregisterThermalLevelChangedCallback();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_UnregisterAllThermalLevelChangedCallbacks(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = UnregisterAllThermalLevelChangedCallbacks();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_UpdateSceneInfo(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = UpdateSceneInfo();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_QueryGpuInfo(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = QueryGpuInfo();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

static napi_value HMS_GamePerformance_QueryThermalInfo(napi_env env, napi_callback_info info) {
    napi_value retVal = nullptr;
    int32_t ret = QueryThermalInfo();
    napi_create_int32(env, ret, &retVal);
    return retVal;
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor desc[] = {
        { "HMS_GamePerformance_Init", nullptr, HMS_GamePerformance_Init, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_RegisterThermalLevelChangedCallback", nullptr, HMS_GamePerformance_RegisterThermalLevelChangedCallback, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_UnregisterThermalLevelChangedCallback", nullptr, HMS_GamePerformance_UnregisterThermalLevelChangedCallback, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_UnregisterAllThermalLevelChangedCallbacks", nullptr, HMS_GamePerformance_UnregisterAllThermalLevelChangedCallbacks, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_UpdateSceneInfo", nullptr, HMS_GamePerformance_UpdateSceneInfo, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_QueryGpuInfo", nullptr, HMS_GamePerformance_QueryGpuInfo, nullptr, nullptr, nullptr, napi_default, nullptr },
        { "HMS_GamePerformance_QueryThermalInfo", nullptr, HMS_GamePerformance_QueryThermalInfo, nullptr, nullptr, nullptr, napi_default, nullptr },
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
