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
 * 最佳实践：AppFreeze 类问题优化建议
 */

#include <algorithm>
#include <mutex>
#include <vector>

std::mutex mtx;
std::vector<int> sharedVec;

// [Start appfreeze_advise1]
bool ContainTarget(int target) {
    auto ret = std::find(sharedVec.begin(), sharedVec.end(), target);
    if (ret == sharedVec.end()) {
        return false;
    }
    return true;
}

int AppFreezeAdvise1() {
    // ...
    mtx.lock();
    if (ContainTarget(1)) {
        return -1;
        // 没有释放锁
    }
    // 没有释放锁
     return 0;
}
// [End appfreeze_advise1]


/**
 * 最佳实践：AppFreeze 类问题案例
 */

// [Start appfreeze_case_1_negative]
int AppFreezeAdviseNegative() {
    // ...
    mtx.lock();
    if (ContainTarget(1)) {
        return -1;
    }
    // ...
     return 0;
}
// [End appfreeze_case_1_negative]

// [Start appfreeze_case_1_positive]
int AppFreezeAdvisePositive() {
    // ...
    mtx.lock();
    if (ContainTarget(1)) {
        mtx.unlock();
        return -1;
    }
    mtx.unlock();
    // ...
    return 0;
}
// [End appfreeze_case_1_positive]