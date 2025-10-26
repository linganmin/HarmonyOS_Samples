/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef FRAMEWORK_LOG_HPP
#define FRAMEWORK_LOG_HPP
#include <cinttypes>


namespace AdaptiveBufferResolution {
class Log final {
public:
    enum class Priority : uint8_t {
        DEBUG = 0U,
        INFO = 1U,
        WARNING = 2U,
        ERROR = 3U
    };

    Log() = delete;

    Log(Log const &) = delete;
    Log &operator = (Log const &) = delete;

    Log(Log &&) = delete;
    Log &operator = (Log &&) = delete;

    ~Log() = delete;

    static void Report(Priority prio, char const * format, ...) noexcept;
};

#define GOLOGD(...) AdaptiveBufferResolution::Log::Report(AdaptiveBufferResolution::Log::Priority::DEBUG, __VA_ARGS__)
#define GOLOGI(...) AdaptiveBufferResolution::Log::Report(AdaptiveBufferResolution::Log::Priority::INFO, __VA_ARGS__)
#define GOLOGW(...) AdaptiveBufferResolution::Log::Report(AdaptiveBufferResolution::Log::Priority::WARNING, __VA_ARGS__)
#define GOLOGE(...) AdaptiveBufferResolution::Log::Report(AdaptiveBufferResolution::Log::Priority::ERROR, __VA_ARGS__)
} // namespace AdaptiveBufferResolution

#endif // FRAMEWORK_LOG_HPP
