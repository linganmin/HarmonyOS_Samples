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
#include "ffrt/cpp/pattern/job_partner.h"

#undef LOG_TAG
#define LOG_TAG "TestTag"

double fetch_parallel_exec_time()
{
    OH_LOG_INFO(LOG_APP, "Fetch the execution time of the task when it is executed in parallel.");
    std::thread::id master_tid = std::this_thread::get_id();
    OH_LOG_INFO(LOG_APP, "the master thread is %{public}zu.", std::hash<std::thread::id>{}(master_tid));

    auto start = std::chrono::steady_clock::now();
    constexpr uint64_t stack_size = 16 * 1024;
    auto stack = std::make_unique<std::array<char, stack_size>[]>(TASK_NUM);
    auto partner = ffrt::job_partner<>::get_partner_of_this_thread();
    for (int i = 0; i < TASK_NUM; i++) {
        partner->submit([&] {
            SimulateTask(50);
            ffrt::job_partner<>::submit_to_master([&] {
                SimulateTask(50);
                std::thread::id tid = std::this_thread::get_id();
                if (tid != master_tid) {
                    OH_LOG_ERROR(LOG_APP, "The task is executed on the worker thread %{public}zu.",
                        std::hash<std::thread::id>{}(tid));
                }
            });
            SimulateTask(50);
        }, &stack[i], stack_size);
    }
    partner->wait();
    auto end = std::chrono::steady_clock::now();
    size_t cost = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    return cost;
}