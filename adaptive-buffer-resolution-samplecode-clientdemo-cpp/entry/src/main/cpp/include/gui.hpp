/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef GUI_HPP
#define GUI_HPP

#include "renderer.hpp"
#include "sprite.hpp"
#include "wanted_level.hpp"

namespace AdaptiveBufferResolution {
class GUI final {
public:
    GUI() = default;

    GUI(GUI const &) = delete;
    GUI &operator = (GUI const &) = delete;

    GUI(GUI &&) = delete;
    GUI &operator = (GUI &&) = delete;

    ~GUI() = default;

    [[nodiscard]] bool Init() noexcept;
    void Destroy() noexcept;
    void Draw(Renderer &renderer, float deltaTime) noexcept;
    void OnSwapchainChanged(uint32_t width, uint32_t height) noexcept;

private:
    constexpr static GLuint TEXTURE_UNIT = 0U;

    Sprite logo_{};
    GLuint program_ = 0U;
    Matrix4x4 proj_{};
    GLuint sampler_ = 0U;
    Sprite saving_{};

    Sprite spinner_{};
    float spinnerOrientation_ = 0.0F;

    WantedLevel wantedLevel_{};
};
} // namespace AdaptiveBufferResolution

#endif // GUI_HPP
