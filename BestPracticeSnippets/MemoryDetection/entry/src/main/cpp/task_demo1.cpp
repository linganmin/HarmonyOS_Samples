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

//
// Created on 2025/7/24.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include <iostream>
#include <thread>

/**
 * 最佳实践：地址越界优化建议
 */
// [Start address_sanitizer_advise2_negative]
class Task1 {
public:
    void Start() {
        std::thread([this]() {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
            DoWork(); // 如果 Task 已析构，这里是悬空调用
        }).detach();
    }

    void DoWork() {
        std::cout << "Doing work\n";
    }

    ~Task1() {
        std::cout << "Task destructed\n";
    }
};

void Run() {
    Task1* task = new Task1();
    task->Start();
    delete task; // 析构发生在 lambda 执行前
    std::this_thread::sleep_for(std::chrono::milliseconds(1));
}
// [End address_sanitizer_advise2_negative]