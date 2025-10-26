/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "game_performance_sample.h"

int32_t Init() {
    // Create initialization parameters.
    GamePerformance_InitParameters *initParameters = NULL;
    HMS_GamePerformance_CreateInitParameters(&initParameters);

    // Create parameters. The second parameter of all set APIs is a placeholder. Replace it with the actual one.
    GamePerformance_ErrorCode appVersionSetCode =
        HMS_GamePerformance_InitParameters_SetAppVersion(initParameters, "1.0");

    // If a parameter of a set API is incorrect, error code 401 will be returned. 
    // To ensure the correct parameter settings, you are advised to obtain the returns and check the error code.
    if (appVersionSetCode != GAME_PERFORMANCE_SUCCESS) {
        // Troubleshooting.
    }
    HMS_GamePerformance_InitParameters_SetBundleName(initParameters, "com.example.gameperformancedemoforc");

    // Initialization.
    GamePerformance_ErrorCode ret = HMS_GamePerformance_Init(initParameters);

    // Free the memory after the settings are complete.
    HMS_GamePerformance_DestroyInitParameters(&initParameters);

    int32_t code = static_cast<int32_t>(ret);
    return code;
}