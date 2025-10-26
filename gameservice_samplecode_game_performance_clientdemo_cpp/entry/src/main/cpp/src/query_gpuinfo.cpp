/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "game_performance_sample.h"

int32_t QueryGpuInfo() {
    // Query GPU information.
    GamePerformance_GpuInfo *gpuInfo = NULL;
    GamePerformance_ErrorCode ret = HMS_GamePerformance_QueryGpuInfo(&gpuInfo);

    // Obtain indicator data.
    int32_t gpuloadLevel = -1;
    int32_t bandwidth = -1;
    int32_t currentFrequency = -1;
    int32_t fragmentLoadLevel = -1;
    int32_t textureLoadLevel = -1;
    int32_t vertexLoadLevel = -1;
    HMS_GamePerformance_GpuInfo_GetGpuLoadLevel(gpuInfo, &gpuloadLevel);
    HMS_GamePerformance_GpuInfo_GetBandwidthLoadLevel(gpuInfo, &bandwidth);
    HMS_GamePerformance_GpuInfo_GetCurrentFrequency(gpuInfo, &currentFrequency);
    HMS_GamePerformance_GpuInfo_GetFragmentLoadLevel(gpuInfo, &fragmentLoadLevel);
    HMS_GamePerformance_GpuInfo_GetTextureLoadLevel(gpuInfo, &textureLoadLevel);
    HMS_GamePerformance_GpuInfo_GetVertexLoadLevel(gpuInfo, &vertexLoadLevel);

    // Free the memory after the settings are complete.
    HMS_GamePerformance_DestroyGpuInfo(&gpuInfo);
    int32_t code = static_cast<int32_t>(ret);
    return code;
}
