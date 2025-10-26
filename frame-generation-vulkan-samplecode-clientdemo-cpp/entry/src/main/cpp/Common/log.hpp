/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef FRAMEWORK_LOG_HPP
#define FRAMEWORK_LOG_HPP
#include <cinttypes>


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

#define GOLOGD(...) Log::Report(Log::Priority::DEBUG, __VA_ARGS__)
#define GOLOGI(...) Log::Report(Log::Priority::INFO, __VA_ARGS__)
#define GOLOGW(...) Log::Report(Log::Priority::WARNING, __VA_ARGS__)
#define GOLOGE(...) Log::Report(Log::Priority::ERROR, __VA_ARGS__)

#define VK_CHECK(x)                                   \
    do {                                              \
        VkResult err = x;                             \
        if (err) {                                    \
            GOLOGE("Detected Vulkan error: %d", err); \
            abort();                                  \
        }                                             \
    } while (0)


#endif // FRAMEWORK_LOG_HPP
