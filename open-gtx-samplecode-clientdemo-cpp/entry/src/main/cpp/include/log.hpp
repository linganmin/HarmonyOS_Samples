#ifndef FRAMEWORK_LOG_HPP
#define FRAMEWORK_LOG_HPP
#include <cinttypes>


namespace OpenGTX {

class Log final {
public:
    enum class Priority : uint8_t
    {
        DEBUG = 0U,
        INFO = 1U,
        WARNING = 2U,
        ERROR = 3U
    };

    Log() = delete;

    Log(Log const &) = delete;
    Log &operator= (Log const &) = delete;

    Log(Log &&) = delete;
    Log &operator= (Log &&) = delete;

    ~Log() = delete;

    static void Report(Priority prio, char const* format, ...) noexcept;
};

#define GOLOGD(...) OpenGTX::Log::Report(OpenGTX::Log::Priority::DEBUG, __VA_ARGS__)
#define GOLOGI(...) OpenGTX::Log::Report(OpenGTX::Log::Priority::INFO, __VA_ARGS__)
#define GOLOGW(...) OpenGTX::Log::Report(OpenGTX::Log::Priority::WARNING, __VA_ARGS__)
#define GOLOGE(...) OpenGTX::Log::Report(OpenGTX::Log::Priority::ERROR, __VA_ARGS__)

} // namespace OpenGTX

#endif // FRAMEWORK_LOG_HPP
