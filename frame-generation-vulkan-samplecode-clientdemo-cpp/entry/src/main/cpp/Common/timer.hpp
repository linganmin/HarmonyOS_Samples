/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef TIMER_HPP
#define TIMER_HPP
#include <chrono>


class Timer final {
public:
    Timer() = default;

    Timer(Timer const &) = delete;
    Timer &operator = (Timer const &) = delete;

    Timer(Timer &&) = delete;
    Timer &operator = (Timer &&) = delete;

    ~Timer() = default;

    void RestartTimer() noexcept;
    [[nodiscard]] float DiffTime() const noexcept;

private:
    std::chrono::time_point<std::chrono::steady_clock> startTime_{};
};


#endif // TIMER_HPP
