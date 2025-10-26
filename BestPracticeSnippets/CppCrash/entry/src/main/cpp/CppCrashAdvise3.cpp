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

// [Start cppcrash_advise_9_positive]
class Object2 : public std::enable_shared_from_this<Object2> {
public:
    void Run();
    void GetInfo() {}
    // ...

private:
    std::shared_ptr<std::thread> startThread_;
    // ...
};

void Object2::Run()
{
    std::weak_ptr<Object2> weakPtr = shared_from_this(); // 调用shared_from_this捕获this(c++17开始可使用waek_form_this)
    startThread_ = std::shared_ptr<std::thread>(new std::thread([weakPtr] { // weakPtr传递给其他线程
        auto ptr = weakPtr.lock();
        if (ptr == nullptr) {
            return;
        }
        ptr->GetInfo();
        // ...
    }));
    // ...
}

void MainFuncEx()
{
    auto object = std::make_shared<Object2>(); // 必须使用智能指针初始化Object对象
    object->Run();
}
// [End cppcrash_advise_9_positive]