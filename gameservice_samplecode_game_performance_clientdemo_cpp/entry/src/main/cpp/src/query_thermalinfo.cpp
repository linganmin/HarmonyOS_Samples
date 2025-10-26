/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "game_performance_sample.h"


int32_t QueryThermalInfo() {
    // Query the temperature and temperature trend information.
    GamePerformance_ThermalInfo *thermalInfo = NULL;
    GamePerformance_ThermalInfoQueryParameters *parameters = NULL;

    // Create query parameters.
    HMS_GamePerformance_CreateThermalInfoQueryParameters(&parameters);

    // / Set if predicting temperature trend is required. true: yes; false: no. The default value is false.
    HMS_GamePerformance_ThermalInfoQueryParameters_SetNeedsPrediction(parameters, true);

    // Set target temperature level as required when needsPrediction is true, and skip this step when needsPrediction is
    // false. when a target temperature level is set, temperature trend will be predicted based on this temperature
    // level. Otherwise, the default level will be used.
    HMS_GamePerformance_ThermalInfoQueryParameters_SetTargetThermalLevel(parameters, 4);

    // Query the temperature and temperature trend information.
    GamePerformance_ErrorCode ret = HMS_GamePerformance_QueryThermalInfo(parameters, &thermalInfo);
    
    int32_t margin = INT32_MIN;
    int32_t trend = INT32_MIN;
    int32_t level = -1;
    HMS_GamePerformance_ThermalInfo_GetThermalLevel(thermalInfo, &level);
    HMS_GamePerformance_ThermalInfo_GetThermalMargin(thermalInfo, &margin); // A valid value will be returned when needsPrediction is true.
    HMS_GamePerformance_ThermalInfo_GetThermalTrend(thermalInfo, &trend);   // A valid value will be returned when needsPrediction is true.

    // Free the memory after the settings are complete.
    HMS_GamePerformance_DestroyThermalInfo(&thermalInfo);
    HMS_GamePerformance_DestroyThermalInfoQueryParameters(&parameters);

    int32_t code = static_cast<int32_t>(ret);
    return code;
}
