/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <chrono>
#include <thread>
#include "hilog/log.h"
#include "task.h"

#undef LOG_TAG
#define LOG_TAG "TestTag"

double fetch_serial_exec_time()
{
    OH_LOG_INFO(LOG_APP, "Fetch the execution time of the task when it is executed serially.");
    std::thread::id master_tid = std::this_thread::get_id();
    OH_LOG_INFO(LOG_APP, "the master thread is %{public}zu.", std::hash<std::thread::id>{}(master_tid));

    auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < TASK_NUM; i++) {
        SimulateTask(50);
        SimulateTask(50);
        SimulateTask(50);
    }
    auto end = std::chrono::steady_clock::now();
    size_t cost = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    return cost;
}