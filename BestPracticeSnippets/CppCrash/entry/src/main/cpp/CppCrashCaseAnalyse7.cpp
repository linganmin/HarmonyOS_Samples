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
// Created on 2025/7/17.
//

/**
 * 最佳实践：CppCrash类问题案例
 */

#include <iostream>
#include <string.h>

struct SupportPac {
    static void SupportPacPrint() {};
};

// [Start trigger_crash_7]
char g_ori[12] = "hello!";

int main()
{
    unsigned long context = 0xa51f;
    void *addr = (void*)(&SupportPac::SupportPacPrint);
    char a[8] = {};
    memcpy(a, &g_ori, sizeof(g_ori)); // 伪造内存溢出攻击，篡改addr内容
#ifdef __ARM_FEATURE_PAUTH
    __asm__ __volatile__("autia %0, %1\n\t"
        "blr %0\n\t"
        : "+r"(addr) : "r"(context):);
#endif
    std::cout << a;
    return 0;
}
// [End trigger_crash_7]