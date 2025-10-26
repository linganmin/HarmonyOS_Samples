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
/**
 * 最佳实践：CppCrash类问题优化建议
 */

#include <memory>
#include <thread>

class Object1 {
public:
    void Run();
    void GetInfo() {}

private:
    std::shared_ptr<std::thread> startThread_;
};

// [Start cppcrash_advise_9_negative]
void Object1::Run()
{
    startThread_ = std::shared_ptr<std::thread>(new std::thread([this] { // 将this指针传递给其他线程
        if (this == nullptr) {
            return;
        }
        this->GetInfo();
        // ...
    }));
    // ...
}
// [End cppcrash_advise_9_negative]