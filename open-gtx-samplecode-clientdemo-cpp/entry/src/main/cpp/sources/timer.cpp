#include <timer.hpp>

namespace OpenGTX {

void Timer::RestartTimer() noexcept
{
    startTime_ = std::chrono::steady_clock::now();
}

float Timer::DiffTime() const noexcept
{
    auto const now = std::chrono::steady_clock::now();
    std::chrono::duration<double> const seconds = now - startTime_;
    return static_cast<float>(seconds.count());
}

} // namespace OpenGTX
