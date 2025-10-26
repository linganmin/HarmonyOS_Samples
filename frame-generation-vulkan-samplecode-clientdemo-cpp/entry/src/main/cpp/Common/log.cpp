/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "log.hpp"
#include <hilog/log.h>
#include <cstdio>
#include <vector>
#include <securec.h>

namespace {
constexpr unsigned int FRAMEGENERATION_DOMAIN = 0xD005810;
constexpr size_t SHORT_STRING_OPTIMIZATION = 256U;
} // end of anonymous namespace

void Log::Report(Priority prio, const char *format, ...) noexcept
{
    char shortString[SHORT_STRING_OPTIMIZATION];
    std::vector<char> bigString{};
    char *str = shortString;

    va_list argumentPtr;
    va_start(argumentPtr, format);

    auto const needed = static_cast<size_t>(vsnprintf_s(shortString, SHORT_STRING_OPTIMIZATION,
        SHORT_STRING_OPTIMIZATION, format, argumentPtr)) + 1U;

    if (needed > SHORT_STRING_OPTIMIZATION) {
        bigString.resize(needed + 1U);
        str = bigString.data();
        int ret = vsnprintf_s(str, needed, needed, format, argumentPtr);
        if (ret == -1) {
        }
    }

    va_end(argumentPtr);

    constexpr LogLevel const cases[] = {LOG_DEBUG, LOG_INFO, LOG_WARN, LOG_ERROR};
    OH_LOG_Print(LOG_APP, cases[static_cast<size_t>(prio)], FRAMEGENERATION_DOMAIN, "VulKanFG", "%{public}s", str);
} // namespace FrameGeneration
