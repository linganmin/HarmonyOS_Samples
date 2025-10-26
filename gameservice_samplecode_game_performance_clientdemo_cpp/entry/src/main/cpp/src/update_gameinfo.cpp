/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#include "game_performance_sample.h"

int32_t UpdateSceneInfo() {
    // The second parameter of set APIs is a placeholder. Replace it with the actual one.
    GamePerformance_SceneInfo *sceneInfo = NULL;
    HMS_GamePerformance_CreateSceneInfo(&sceneInfo);

    // If multiple times of reporting are required using the same instance, you only need to use set APIs to update the
    // parameters. (The parameters set last time are retained for the same instance.)
    // Set mandatory fields.
    HMS_GamePerformance_SceneInfo_SetSceneID(sceneInfo, 1);
    HMS_GamePerformance_SceneInfo_SetImportanceLevel(sceneInfo, GAME_PERFORMANCE_SIL_LEVEL1);

    // Set the following fields as required.
    HMS_GamePerformance_SceneInfo_SetDescription(sceneInfo, "this is description of scene");
    HMS_GamePerformance_SceneInfo_SetSubSceneID(sceneInfo, "20101020304");
    HMS_GamePerformance_SceneInfo_SetSubDescription(sceneInfo, "this is description of subscene");
    HMS_GamePerformance_SceneInfo_SetSceneFrequency(sceneInfo, 2);
    HMS_GamePerformance_SceneInfo_SetSceneTime(sceneInfo, 15);
    HMS_GamePerformance_SceneInfo_SetRecommendedCpuLevel(sceneInfo, GAME_PERFORMANCE_CPU_LEVEL_HIGH);
    HMS_GamePerformance_SceneInfo_SetRecommendedGpuLevel(sceneInfo, GAME_PERFORMANCE_GPU_LEVEL_HIGH);
    HMS_GamePerformance_SceneInfo_SetRecommendedDdrLevel(sceneInfo, GAME_PERFORMANCE_DDR_LEVEL_HIGH);
    HMS_GamePerformance_SceneInfo_SetKeyThread(sceneInfo, "render");
    HMS_GamePerformance_SceneInfo_SetDrawCallCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetVertexCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetTriangleCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetShaderCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetTextureCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetMeshCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetChannelCount(sceneInfo, 100);
    HMS_GamePerformance_SceneInfo_SetParticipantCount(sceneInfo, 5);

    // Report game scene information.
    GamePerformance_ErrorCode ret = HMS_GamePerformance_UpdateSceneInfo(sceneInfo);

    // Free the memory after the settings are complete.
    HMS_GamePerformance_DestroySceneInfo(&sceneInfo);
    int32_t code = static_cast<int32_t>(ret);

    return code;
}

