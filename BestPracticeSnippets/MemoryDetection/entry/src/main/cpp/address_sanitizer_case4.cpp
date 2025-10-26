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
 * 最佳实践：地址越界优化建议
 */

#include <thread>

// [Start address_sanitizer_advise4_positive]
int* g_ptr2 = nullptr;

void WorkerThread2()
{
    std::this_thread::sleep_for(std::chrono::milliseconds(100));
    if (g_ptr2 != nullptr) { // 判空处理
        *g_ptr2 = 24;
    }
}

int Demo4() {
    g_ptr2 = new int(42);
    std::thread t(WorkerThread2);
    delete g_ptr2; // 主线程提前释放
    g_ptr2 = nullptr; // 指针置空
    t.join();
    return 0;
}
// [End address_sanitizer_advise4_positive]

