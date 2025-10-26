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

#include <map>
#include <thread>

// [Start address_sanitizer_advise3_negative]
std::map<int, int*> myMap1;

void Erase1(int key)
{
    auto it = myMap1.find(key);
    if (it != myMap1.end()) {
        delete it->second;
        myMap1.erase(it); // 多线程下未加锁，可能重复删除
    }
}

int Demo1()
{
    myMap1[1] = new int(100);
    std::thread t1(Erase1, 1);
    std::thread t2(Erase1, 1); // 两个线程同时删除同一个 key
    t1.join();
    t2.join();
    return 0;
}
// [End address_sanitizer_advise3_negative]

