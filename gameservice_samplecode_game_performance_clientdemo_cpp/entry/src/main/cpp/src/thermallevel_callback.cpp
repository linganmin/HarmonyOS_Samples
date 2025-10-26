/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "game_performance_sample.h"

// defines callback function
static void onThermalLevelChanged(GamePerformance_DeviceInfo *deviceInfo, void *userData) {
    // Obtain the GPU load level. (Make sure you subscribe to the device information type GAME_PERFORMANCE_DEVICEINFO_TYPE_GPU.)
    (void) userData; 
    GamePerformance_GpuInfo *gpuInfo = NULL;
    HMS_GamePerformance_DeviceInfo_GetGpuInfo(deviceInfo, &gpuInfo);
    int32_t gpuloadLevel = -1;
    int32_t vertexLevel = -1;
    int32_t fragmentLoadLevel = -1;
    int32_t bandwidthLoadLevel = -1;
    int32_t textureLoadLevel = -1;
    int32_t currentFrequency = -1;
    HMS_GamePerformance_GpuInfo_GetGpuLoadLevel(gpuInfo, &gpuloadLevel);
    HMS_GamePerformance_GpuInfo_GetVertexLoadLevel(gpuInfo, &vertexLevel);
    HMS_GamePerformance_GpuInfo_GetFragmentLoadLevel(gpuInfo, &fragmentLoadLevel);
    HMS_GamePerformance_GpuInfo_GetBandwidthLoadLevel(gpuInfo, &bandwidthLoadLevel);
    HMS_GamePerformance_GpuInfo_GetTextureLoadLevel(gpuInfo, &textureLoadLevel);
    HMS_GamePerformance_GpuInfo_GetCurrentFrequency(gpuInfo, &currentFrequency);

    // Obtain temperature information. (Make sure you subscribe to the device information type
    // GAME_PERFORMANCE_DEVICEINFO_TYPE_THERMAL.)
    GamePerformance_ThermalInfo *thermalInfo = NULL;
    HMS_GamePerformance_DeviceInfo_GetThermalInfo(deviceInfo, &thermalInfo);
    int32_t margin = INT32_MIN;
    int32_t trend = INT32_MIN;
    int32_t level = -1;
    HMS_GamePerformance_ThermalInfo_GetThermalMargin(thermalInfo, &margin);
    HMS_GamePerformance_ThermalInfo_GetThermalTrend(thermalInfo, &trend);
    HMS_GamePerformance_ThermalInfo_GetThermalLevel(thermalInfo, &level);

    // Free the memory after the settings are complete.
    HMS_GamePerformance_DestroyGpuInfo(&gpuInfo);
    HMS_GamePerformance_DestroyThermalInfo(&thermalInfo);
}

int32_t RegisterThermalLevelChangedCallback() {
    // Subscribe to device information types as required.
    size_t size = 2; // Number of subscribed device information types, that is, the length of the types array.
    GamePerformance_DeviceInfoType *types[] = {
        new GamePerformance_DeviceInfoType(GAME_PERFORMANCE_DEVICEINFO_TYPE_GPU),
        new GamePerformance_DeviceInfoType(GAME_PERFORMANCE_DEVICEINFO_TYPE_THERMAL)};
    void *userData = (void *)"mydata"; //  User-defined data of any type. The data will be passed through the callback.
    GamePerformance_ErrorCode ret =
        HMS_GamePerformance_RegisterThermalLevelChangedCallback(types, size, onThermalLevelChanged, userData);

    int32_t code = static_cast<int32_t>(ret);
    return code;
}

int32_t UnregisterThermalLevelChangedCallback() {
    // Unregister the callback.
    GamePerformance_ErrorCode ret = HMS_GamePerformance_UnregisterThermalLevelChangedCallback(onThermalLevelChanged);

    int32_t code = static_cast<int32_t>(ret);
    return code;
}

int32_t UnregisterAllThermalLevelChangedCallbacks() {
    // Unregister all callbacks.
    GamePerformance_ErrorCode ret = HMS_GamePerformance_UnregisterAllThermalLevelChangedCallbacks();

    int32_t code = static_cast<int32_t>(ret);
    return code;
}
