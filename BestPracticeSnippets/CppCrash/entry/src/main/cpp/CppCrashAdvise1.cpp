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
#include <list>
#include <map>
#include <memory>
#include <mutex>

struct Item {
    int id;
};

struct Object {
    int id;
};

std::map<int, Item> appRunningRecordMap_;
std::mutex mutex_;

// [Start cppcrash_advise_1_negative]
void EraseMapItem1(int key)
{
    appRunningRecordMap_.erase(key);
}
// [End cppcrash_advise_1_negative]

// [Start cppcrash_advise_1_positive]
void EraseMapItem2(int key)
{
    // 加锁
    std::lock_guard<std::mutex> lock(mutex_);
    appRunningRecordMap_.erase(key);
}

void FindMapItem(int key)
{
    // 加锁
    std::lock_guard<std::mutex> lock(mutex_);
    appRunningRecordMap_.find(key);
}
// [End cppcrash_advise_1_positive]