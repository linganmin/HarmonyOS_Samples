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
#include <memory>
#include <chrono>


// [Start address_sanitizer_advise2_positive1]
class Task2 : public std::enable_shared_from_this<Task2> {
// [End address_sanitizer_advise2_positive1]
public:
    void DoWork() {
        std::cout << "Doing work\n";
    }
};

// [Start address_sanitizer_advise2_positive3]
void Start(std::shared_ptr<Task2> task)
{
   auto weak = task->weak_from_this();
   std::thread([weak]() {
       std::this_thread::sleep_for(std::chrono::milliseconds(100));
       auto strong = weak.lock();
       if (!strong) {
           return;
       }
       strong->DoWork();
   }).detach();
}
// [End address_sanitizer_advise2_positive3]

int main()
{
 // [Start address_sanitizer_advise2_positive2]
    auto task = std::make_shared<Task2>();
// [End address_sanitizer_advise2_positive2]
    Start(task);
}