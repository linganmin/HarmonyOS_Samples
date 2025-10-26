/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

#ifndef GAMEPERFORMANCEDEMOFORC_GAME_PERFORMANCE_SAMPLE_H
#define GAMEPERFORMANCEDEMOFORC_GAME_PERFORMANCE_SAMPLE_H

#include <GameServiceKit/game_performance.h>

int32_t Init();
int32_t RegisterThermalLevelChangedCallback();
int32_t UnregisterThermalLevelChangedCallback();
int32_t UnregisterAllThermalLevelChangedCallbacks();
int32_t UpdateSceneInfo();
int32_t QueryGpuInfo();
int32_t QueryThermalInfo();

#endif // GAMEPERFORMANCEDEMOFORC_GAME_PERFORMANCE_SAMPLE_H
