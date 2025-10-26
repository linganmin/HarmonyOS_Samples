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

#ifndef SAMPLE_LOG_H
#define SAMPLE_LOG_H

#include <hilog/log.h>
#include <cinttypes>

#undef LOG_DOMAIN
#define LOG_DOMAIN 0x0002B66

#define SAMPLE_LOG_FREQ_LIMIT(frequency)                                                                       \
    if (1) {                                                                                                           \
        thread_local uint64_t currentTimes = 0;                                                                        \
        if (currentTimes++ % ((uint64_t)(frequency)) != 0) {                                                           \
            break;                                                                                                     \
        }                                                                                                              \
    }

#define SAMPLE_LOG(func, fmt, args...)                                                                         \
    do {                                                                                                               \
        (void)func(LOG_APP, "{%{public}s():%{public}d} " fmt, __FUNCTION__, __LINE__, ##args);                         \
    } while (0)

#define SAMPLE_LOGF(fmt, ...) SAMPLE_LOG(OH_LOG_FATAL, fmt, ##__VA_ARGS__)
#define SAMPLE_LOGE(fmt, ...) SAMPLE_LOG(OH_LOG_ERROR, fmt, ##__VA_ARGS__)
#define SAMPLE_LOGW(fmt, ...) SAMPLE_LOG(OH_LOG_WARN, fmt, ##__VA_ARGS__)
#define SAMPLE_LOGI(fmt, ...) SAMPLE_LOG(OH_LOG_INFO, fmt, ##__VA_ARGS__)
#define SAMPLE_LOGD(fmt, ...) SAMPLE_LOG(OH_LOG_DEBUG, fmt, ##__VA_ARGS__)
#define SAMPLE_LOGD_LIMIT(frequency, fmt, ...)                                                                 \
    do {                                                                                                               \
        SAMPLE_LOG_FREQ_LIMIT(frequency);                                                                      \
        SAMPLE_LOGD(fmt, ##__VA_ARGS__);                                                                       \
    } while (0)

#define CHECK_AND_RETURN_RET_LOG(cond, ret, fmt, ...)                                                                  \
    do {                                                                                                               \
        if (!(cond)) {                                                                                                 \
            SAMPLE_LOGE(fmt, ##__VA_ARGS__);                                                                   \
            return ret;                                                                                                \
        }                                                                                                              \
    } while (0)

#define CHECK_AND_RETURN_LOG(cond, fmt, ...)                                                                           \
    do {                                                                                                               \
        if (!(cond)) {                                                                                                 \
            SAMPLE_LOGE(fmt, ##__VA_ARGS__);                                                                   \
            return;                                                                                                    \
        }                                                                                                              \
    } while (0)

#define CHECK_AND_BREAK_LOG(cond, fmt, ...)                                                                            \
    if (1) {                                                                                                           \
        if (!(cond)) {                                                                                                 \
            SAMPLE_LOGW(fmt, ##__VA_ARGS__);                                                                   \
            break;                                                                                                     \
        }                                                                                                              \
    } else                                                                                                             \
        void(0)

#define CHECK_AND_CONTINUE_LOG(cond, fmt, ...)                                                                         \
    if (1) {                                                                                                           \
        if (!(cond)) {                                                                                                 \
            SAMPLE_LOGW(fmt, ##__VA_ARGS__);                                                                   \
            continue;                                                                                                  \
        }                                                                                                              \
    } else                                                                                                             \
        void(0)

#endif // SAMPLE_LOG_H