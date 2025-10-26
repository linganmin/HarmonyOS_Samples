/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <sprite.hpp>
#include <renderer.hpp>
#include <texture_loader.hpp>

namespace AdaptiveBufferResolution {
constexpr uint32_t NUMBER_FOUR = 4;

float Sprite::GetHeight() const noexcept
{
    return height_;
}

bool Sprite::Init(char const * image) noexcept
{
    if (texture_ = TextureLoader::Load(sourceWidth_, sourceHeight_, image); !texture_) {
        return false;
    }

    SetWidth(sourceWidth_);
    return true;
}

void Sprite::Destroy() noexcept
{
    if (!texture_) {
        return;
    }

    glDeleteTextures(1, &texture_);
    CheckOpenGLError();
}

void Sprite::Draw() noexcept
{
    glUniformMatrix4fv(TRANSFORM, 1, GL_FALSE, transform_.Data());
    CheckOpenGLError();

    glUniform1f(TRANSPARENCY, transparency_);
    CheckOpenGLError();

    Renderer::BindTexture(texture_, TEXTURE_UNIT);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, NUMBER_FOUR);
    CheckOpenGLError();
}

void Sprite::SetLocation(float x, float y, Matrix4x4 const & proj) noexcept
{
    location_.x_ = x;
    location_.y_ = y;

    Matrix4x4 m{};
    m.data_[0U] = Vector4D(width_, 0.0F, 0.0F, 0.0F);
    m.data_[1U] = Vector4D(0.0F, height_, 0.0F, 0.0F);
    m.data_[2U] = Vector4D(0.0F, 0.0F, 1.0F, 0.0F);
    m.data_[3U] = Vector4D(x, y, 0.0F, 1.0F);

    transform_ = proj * m;
}

void Sprite::SetOrientation(float rollRadians, Matrix4x4 const & proj) noexcept
{
    Matrix4x4 m{};
    m.RotateZ(rollRadians);
    m.data_[0U] *= width_;
    m.data_[1U] *= height_;
    m.data_[3U] = Vector4D(location_.x_, location_.y_, 0.0F, 1.0F);

    transform_ = proj * m;
}

void Sprite::SetTransparency(float transparency) noexcept
{
    transparency_ = transparency;
}

void Sprite::SetWidth(uint32_t width) noexcept
{
    constexpr uint32_t multiplier = 10000U;
    uint32_t const aspectFactor = (sourceWidth_ * multiplier) / sourceHeight_;

    width_ = static_cast<float>(width);

    // NOLINTNEXTLINE - fine with lost of precision
    height_ = static_cast<float>((width * multiplier) / aspectFactor);

    transform_ = Matrix4x4::Identity();
}
} // namespace AdaptiveBufferResolution
