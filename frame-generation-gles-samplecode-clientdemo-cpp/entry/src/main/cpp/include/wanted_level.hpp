/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef WANTED_LEVEL_HPP
#define WANTED_LEVEL_HPP

#include "matrix4x4.hpp"
#include <GLES3/gl32.h>

namespace FrameGeneration {
class WantedLevel final {
public:
    WantedLevel() = default;

    WantedLevel(WantedLevel const &) = delete;
    WantedLevel &operator = (WantedLevel const &) = delete;

    WantedLevel(WantedLevel &&) = delete;
    WantedLevel &operator = (WantedLevel &&) = delete;

    ~WantedLevel() = default;

    [[nodiscard]] bool Init() noexcept;
    void Draw(float deltaTime, GLuint sampler) noexcept;
    void Destroy() noexcept;
    void OnSwapchainChanged(float pixelsInCentimeter, Matrix4x4 const & proj, uint32_t width, uint32_t height) noexcept;

private:
    struct State final {
        int32_t data_[4U]{};

        void Toggle() noexcept;
    };

    constexpr static GLint TRANSFORMS = 0;
    constexpr static GLint STATES = 5;

    constexpr static GLuint ACTIVE_UNIT = 1U;
    constexpr static GLuint PASSIVE_UNIT = 0U;

    constexpr static size_t STARS = 5U;

    GLuint activeStar_ = 0U;
    GLuint passiveStar_ = 0U;
    GLuint program_ = 0U;
    State states_[STARS]{};
    float blink_ = 0.0F;
};
} // namespace FrameGeneration

#endif // WANTED_LEVEL_HPP
