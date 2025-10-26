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
 * 最佳实践：资源泄漏类问题优化建议
 */

#include <cstring>
#include <stdlib.h>
#include <string>
#include <pthread.h>
#include <memory>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int g_cmdLen = 128;

// [Start resource_leak_advise2_negative]
static bool InjectNativeLeak1()
{
    char* p = (char*)malloc(g_cmdLen + 1);
    if (!p) {
        return false;
    }
    auto err = memset(p, 'a', g_cmdLen);
    if (err) {
        // 异常分支退出未释放
        return false;
    }
    free(p);
    return true;
}
// [End resource_leak_advise2_negative]

// [Start resource_leak_advise2_positive]
static bool InjectNativeLeak2()
{
    char* p = (char*)malloc(g_cmdLen + 1);
    if (!p) {
        return false;
    }
    auto err = memset(p, 'a', g_cmdLen);
    if (err) {
        free(p);
        return false;
    }
    free(p);
    return true;
}
// [End resource_leak_advise2_positive]

void processData(void* ptr)
{
    // process ptr
}

/**
 * 最佳实践：资源泄漏类问题优化建议
 */

// [Start resource_leak_advise3_negative]
void processWithLeak1(int fd, size_t size) {
    void* ptr = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        return;
    }
    // 使用共享内存
    processData(ptr);
    // 忘记调用munmap(ptr, size);
    // 每一次调用都会泄漏一块映射内存
}
// [End resource_leak_advise3_negative]

// [Start resource_leak_advise3_positive]
void processWithLeak2(int fd, size_t size) {
    void* ptr = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        return;
    }
    // 使用共享内存
    processData(ptr);
    munmap(ptr, size);
}
// [End resource_leak_advise3_positive]

/**
 * 最佳实践：资源泄漏类问题优化建议
 */

bool CheckStatus() {
    return true;
}

// [Start resource_leak_advise4_negative]
void InjectContinuingFileFdLeak1(std::string path) {
    mode_t fileMode = 0644;
    int fd = open(path.c_str(), O_CREAT | O_RDWR, fileMode);
    if (fd < 0) {
        return;
    }

    if (!CheckStatus()) {
        // 异常分支未关闭句柄
        return;
    }
    close(fd); // 正常业务流程关闭句柄
}
// [End resource_leak_advise4_negative]

// [Start resource_leak_advise4_positive]
void InjectContinuingFileFdLeak2(std::string path) {
    mode_t fileMode = 0644;
    int fd = open(path.c_str(), O_CREAT | O_RDWR, fileMode);
    if (fd < 0) {
        return;
    }

    if (!CheckStatus()) {
        close(fd);
        return;
    }
    close(fd); // 正常业务流程关闭句柄
}
// [End resource_leak_advise4_positive]

/**
 * 最佳实践：资源泄漏类问题优化建议
 */

void* LeadThreadFn(void* args)
{
    // todo
    return nullptr;
}

// [Start resource_leak_advise5_negative]
void riskyThreadFunction(int num) {
    for (int i = 0; i < num; i++) { // 创建 Num 个线程
        pthread_t thread;
        pthread_create(&thread, NULL, LeadThreadFn, NULL);
        // ...
    }
    // ...
    return;
}
// [End resource_leak_advise5_negative]

class Task {};

// [Start resource_leak_advise5_positive]
class ThreadPool { // 线程池实现，支持线程生命周期管理和回收
public:
    // ...
    static bool addTask(const Task& task) {
        // ...
        return true;
    }
};

void safeThreadFunction(int num) {
    for (int i = 0; i < num; i++) { // 创建 Num 个线程
        Task task;
        bool ret = ThreadPool::addTask(task); // 使用线程池管理线程
        if (ret) {
            break;
        }
        // ...
    }
    // ...
    return;
}
// [End resource_leak_advise5_positive]

/**
 * 最佳实践：资源泄漏类问题案例
 */
int inShapeFromImage[10] = {0};
int inShapeForImage[10] = {0};

bool CheckBuffer(unsigned char* buffer)
{
    // todo
    return true;
}

// [Start resource_leak_case_1]
void DemoCase(int length)
{
    // ...
    int bitmapLength = inShapeFromImage[0] * inShapeForImage[1];
    auto bitmapBuffer = new unsigned char[bitmapLength];
    for (int i = 0; i < length; ++i) {
        if (!CheckBuffer(bitmapBuffer)) {
            free(bitmapBuffer);
            bitmapBuffer = nullptr;
            return;
        }
    }
    // ...
    delete[] bitmapBuffer;
}
// [End resource_leak_case_1]