/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <log.hpp>
#include <hilog/log.h>
#include <cstdio>
#include <vector>

namespace FrameGeneration {
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

    auto const needed =
        static_cast<size_t>(std::vsnprintf(shortString, SHORT_STRING_OPTIMIZATION, format, argumentPtr)) + 1U;

    if (needed > SHORT_STRING_OPTIMIZATION) {
        bigString.resize(needed + 1U);
        str = bigString.data();
        std::vsnprintf(str, needed, format, argumentPtr);
    }

    va_end(argumentPtr);

    constexpr LogLevel const cases[] = {LOG_DEBUG, LOG_INFO, LOG_WARN, LOG_ERROR};
    OH_LOG_Print(LOG_APP, cases[static_cast<size_t>(prio)], FRAMEGENERATION_DOMAIN, "FrameGeneration", "%{public}s",
        str);
}
} // namespace FrameGeneration
