/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef SPRITE_HPP
#define SPRITE_HPP

#include "matrix4x4.hpp"
#include "vector2d.hpp"
#include <GLES3/gl32.h>

namespace FrameGeneration {
class Sprite final {
public:
    Sprite() = default;

    Sprite(Sprite const &) = delete;
    Sprite &operator = (Sprite const &) = delete;

    Sprite(Sprite &&) = delete;
    Sprite &operator = (Sprite &&) = delete;

    ~Sprite() = default;

    [[nodiscard]] float GetHeight() const noexcept;

    [[nodiscard]] bool Init(char const * image) noexcept;
    void Destroy() noexcept;

    void Draw() noexcept;

    void SetLocation(float x, float y, Matrix4x4 const & proj) noexcept;
    void SetOrientation(float rollRadians, Matrix4x4 const & proj) noexcept;
    void SetTransparency(float transparency) noexcept;
    void SetWidth(uint32_t width) noexcept;

private:
    constexpr static GLint TRANSFORM = 0;
    constexpr static GLint TRANSPARENCY = 1;
    constexpr static GLuint TEXTURE_UNIT = 0U;

    Vector2D location_{};

    uint32_t sourceWidth_ = 0U;
    uint32_t sourceHeight_ = 0U;

    float transparency_ = 1.0F;
    GLuint texture_ = 0U;
    Matrix4x4 transform_{};

    float width_ = 0U;
    float height_ = 0U;
};
} // namespace FrameGeneration

#endif // SPRITE_HPP
