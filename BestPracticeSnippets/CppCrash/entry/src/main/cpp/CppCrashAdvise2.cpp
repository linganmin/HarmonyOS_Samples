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

#include <stdlib.h>
#include <signal.h>
#include <list>
#include <memory>
#include <mutex>

struct Object {
    int id;
    void method() {}
};

std::mutex mutexEx_;

// [Start cppcrash_advise_2_negative]
std::list<std::shared_ptr<Object>> g_list;

void MainFunc()
{
    auto xxx = std::make_shared<Object>();
    g_list.push_back(xxx);
}

// 线程1
void Thread1Func()
{
    for (auto &ptr : g_list) {
        ptr->method();
    }
}

// 线程2
void Thread2Func()
{
    g_list.clear(); // 此处清空list，可能会造成线程1使用g_list时发生崩溃
}
// [End cppcrash_advise_2_negative]

// [Start cppcrash_advise_2_positive]
// 线程1
void Thread1FuncEx()
{
    std::lock_guard<std::mutex> lock(mutexEx_);
    for (auto &ptr : g_list) {
        ptr->method();
    }
}

// 线程2
void Thread2FuncEx()
{
    std::lock_guard<std::mutex> lock(mutexEx_);
    g_list.clear();
}
// [End cppcrash_advise_2_positive]

class EventHandler {
public:
    template<typename Func>
    void PostAsyncTask(Func&& func) {
        // 实际异步投递实现
        func();
    }
};

class Checker {
public:
    void Detection(std::string& url);
    void Detection2(std::string& url);
    static bool DoCheck(const std::string& url);

private:
    EventHandler handler;
};

// [Start cppcrash_advise_3_negative]
void Checker::Detection(std::string& url)
{
    handler.PostAsyncTask(
        [this, &url]() {
            if (!Checker::DoCheck(url)) {
                // ...
            }
        }
    );
    // 这里url变量即将析构
}

bool Checker::DoCheck(const std::string& url)
{
    // ...
    return true;
}
// [End cppcrash_advise_3_negative]

// [Start cppcrash_advise_3_positive]
void Checker::Detection2(std::string& url)
{
    handler.PostAsyncTask(
        [this, url]() {
            if (!Checker::DoCheck(url)) {
                // ...
            }
        }
    );
    // 这里url变量即将析构，但lambda已经有自己的拷贝
}
// [End cppcrash_advise_3_positive]

void Advise4Negative()
{
// [Start cppcrash_advise_4_negative]
    std::shared_ptr<Object> smartPointer = nullptr;
    smartPointer->method();
// [End cppcrash_advise_4_negative]
}

void Advise4Positive()
{
// [Start cppcrash_advise_4_positive]
    std::shared_ptr<Object> smartPointer = nullptr;
    if (smartPointer != nullptr) {
        smartPointer->method();
    }
// [End cppcrash_advise_4_positive]
}

void Advise5Negative()
{
// [Start cppcrash_advise_5_negative]
    Object* xxx = new Object();
    std::shared_ptr<Object> xxx1(xxx); // xxx1引用计数减为0时析构一次xxx
    std::shared_ptr<Object> xxx2(xxx); // xxx2引用计数减为0时析构一次xxx
// [End cppcrash_advise_5_negative]
}

void Advise5Positive()
{
// [Start cppcrash_advise_5_positive]
    std::shared_ptr<Object> xxx = std::make_shared<Object>();
// [End cppcrash_advise_5_positive]
}

void Advise6Negative()
{
// [Start cppcrash_advise_6_negative]
    auto smartPointer = std::make_shared<Object>(); // smartPointer引用计数减为0时析构
    auto pointer = smartPointer.get();
    pointer->method(); // 当smartPinter析构后继续使用pointer可能发生crash
// [End cppcrash_advise_6_negative]
}

void Advise6Positive()
{
// [Start cppcrash_advise_6_positive]
    auto smartPointer = std::make_shared<Object>();
    smartPointer->method();
// [End cppcrash_advise_6_positive]
}

void Advise7Negative()
{
// [Start cppcrash_advise_7_negative]
    Object* pointer = new Object();
    std::shared_ptr<Object> smartPointer(pointer); // smartPointer引用计数减为0时析构
    pointer->method(); // 当smartPointer析构后继续使用pointer可能发生crash
    delete pointer; // 主动释放裸指针发生crash
// [End cppcrash_advise_7_negative]
}

void Advise7Positive()
{
// [Start cppcrash_advise_7_positive]
    auto smartPointer = std::make_shared<Object>();
    smartPointer->method();
// [End cppcrash_advise_7_positive]
}

// [Start cppcrash_advise_8_negative]
static void SignalHandler(int signo, siginfo_t* si, void* context) // 信号处理函数
{
    char *c = (char*)malloc(10); // 禁止使用malloc，malloc是非异步安全函数
}
// [End cppcrash_advise_8_negative]

// [Start cppcrash_advise_8_positive]
static void SignalHandlerEx(int signo, siginfo_t* si, void* context) // 信号处理函数
{
    char c[10] = {0};
}
// [End cppcrash_advise_8_positive]

// [Start cppcrash_advise_10_negative]
std::string& GetString()
{
    std::string result = "this is string";
    return result; // 禁止返回局部变量result的引用
}
// [End cppcrash_advise_10_negative]

// [Start cppcrash_advise_10_positive]
std::string GetStringEx()
{
    std::string result = "this is string";
    return result; // 返回局部变量的值
}
// [End cppcrash_advise_10_positive]