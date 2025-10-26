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
 * 最佳实践：CppCrash类问题案例
 */
#include <cstdint>
#include <string.h>

char cache[128];
uint32_t appendOffset = 128;

// [Start trigger_crash_8]
static int xxxFunc(const uint8_t *buf, uint32_t bufSize)
{
    // ...
    uint32_t srcOffset = appendOffset - bufSize;
    auto ret = memcpy(cache + srcOffset, buf, bufSize);
    if (ret == nullptr) {
        return -1;
    }
    // ...
}
// [End trigger_crash_8]