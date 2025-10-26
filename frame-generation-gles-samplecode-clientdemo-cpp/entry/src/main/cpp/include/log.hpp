/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef FRAMEWORK_LOG_HPP
#define FRAMEWORK_LOG_HPP
#include <cinttypes>


namespace FrameGeneration {
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

#define GOLOGD(...) FrameGeneration::Log::Report(FrameGeneration::Log::Priority::DEBUG, __VA_ARGS__)
#define GOLOGI(...) FrameGeneration::Log::Report(FrameGeneration::Log::Priority::INFO, __VA_ARGS__)
#define GOLOGW(...) FrameGeneration::Log::Report(FrameGeneration::Log::Priority::WARNING, __VA_ARGS__)
#define GOLOGE(...) FrameGeneration::Log::Report(FrameGeneration::Log::Priority::ERROR, __VA_ARGS__)
} // namespace FrameGeneration

#endif // FRAMEWORK_LOG_HPP
