#include "vector4d.hpp"
#include <climits>
#include <cstring>


namespace OpenGTX {

// Note "NOLINT" is a suppressor control macro for clang-tidy.
[[maybe_unused]] Vector4D::Vector4D(uchar const *color) noexcept // NOLINT
{
    FromColor(color);
}

[[maybe_unused]] [[nodiscard]] Vector4D Vector4D::Zero()
{
    return {0.0F, 0.0F, 0.0F, 0.0F};
}

[[maybe_unused]] void Vector4D::Set(float x, float y, float z, float w)
{
    x_ = x;
    y_ = y;
    z_ = z;
    w_ = w;
}

Vector4D::uint Vector4D::RGBA() const
{
    uint const dwR = (r_ >= 1.0F) ? 0xFFU : (r_ <= 0.0F) ? 0x00U : static_cast<uint>(std::lround(r_ * 255.0F + 0.5F));
    uint const dwG = (g_ >= 1.0F) ? 0xFFU : (g_ <= 0.0F) ? 0x00U : static_cast<uint>(std::lround(g_ * 255.0F + 0.5F));
    uint const dwB = (b_ >= 1.0F) ? 0xFFU : (b_ <= 0.0F) ? 0x00U : static_cast<uint>(std::lround(b_ * 255.0F + 0.5F));
    uint const dwA = (a_ >= 1.0F) ? 0xFFU : (a_ <= 0.0F) ? 0x00U : static_cast<uint>(std::lround(a_ * 255.0F + 0.5F));

    return (dwA << 24U) | (dwB << 16U) | (dwG << 8U) | dwR;
}

[[maybe_unused]] [[nodiscard]] bool Vector4D::IsZero() const
{
    constexpr Vector4D const zero(0.0F, 0.0F, 0.0F, 0.0F);
    return memcmp(this, &zero, sizeof(zero)) == 0;
}

[[maybe_unused]] Vector4D &Vector4D::FromARGB(uint color)
{
    constexpr float const f = 1.0F / 255.0F;
    r_ = f * static_cast<float>((color >> 16U) & 0xFFU);
    g_ = f * static_cast<float>((color >> 8U) & 0xFFU);
    b_ = f * static_cast<float>(color & 0xFFU);
    a_ = f * static_cast<float>((color >> 24U) & 0xFFU);
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::FromRGBA(uint color)
{
    constexpr float const f = 1.0F / 255.0F;
    r_ = f * static_cast<float>((color >> 24U) & 0xFFU);
    g_ = f * static_cast<float>((color >> 16U) & 0xFFU);
    b_ = f * static_cast<float>((color >> 8U) & 0xFFU);
    a_ = f * static_cast<float>(color & 0xFFU);
    return *this;
}

void Vector4D::FromColor(unsigned char const *color)
{
    constexpr float const colorFloatToUchar = 1.0F / static_cast<float>(UCHAR_MAX);
    x_ = static_cast<float>(color[0U]) * colorFloatToUchar;
    y_ = static_cast<float>(color[1U]) * colorFloatToUchar;
    z_ = static_cast<float>(color[2U]) * colorFloatToUchar;
    w_ = static_cast<float>(color[3U]) * colorFloatToUchar;
}

[[maybe_unused]] Vector4D::operator uint () const
{
    return RGBA();
}

[[maybe_unused]] Vector4D::operator float * ()
{
    return &x_;
}

[[maybe_unused]] Vector4D::operator float const * () const
{
    return &x_;
}

[[maybe_unused]] Vector4D Vector4D::operator - () const
{
    return {-x_, -y_, -z_, -w_};
}

[[maybe_unused]] Vector4D &Vector4D::operator += (Vector4D const &v)
{
    x_ += v.x_;
    y_ += v.y_;
    z_ += v.z_;
    w_ += v.w_;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator -= (Vector4D const &v)
{
    x_ -= v.x_;
    y_ -= v.y_;
    z_ -= v.z_;
    w_ -= v.w_;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator *= (float s)
{
    x_ *= s;
    y_ *= s;
    z_ *= s;
    w_ *= s;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator /= (float s)
{
    x_ /= s;
    y_ /= s;
    z_ /= s;
    w_ /= s;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator /= (Vector4D const &v)
{
    x_ /= v.x_;
    y_ /= v.y_;
    z_ /= v.z_;
    w_ /= v.w_;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator *= (Vector4D const &v)
{
    x_ *= v.x_;
    y_ *= v.y_;
    z_ *= v.z_;
    w_ *= v.w_;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator += (float v)
{
    x_ += v;
    y_ += v;
    z_ += v;
    w_ += v;
    return *this;
}

[[maybe_unused]] Vector4D &Vector4D::operator -= (float v)
{
    x_ -= v;
    y_ -= v;
    z_ -= v;
    w_ -= v;
    return *this;
}

[[maybe_unused]] bool Vector4D::operator == (Vector4D const &v) const
{
    return x_ == v.x_ && y_ == v.y_ && z_ == v.z_ && w_ == v.w_;
}

[[maybe_unused]] bool Vector4D::operator != (Vector4D const &v) const
{
    return (x_ != v.x_ || y_ != v.y_ || z_ != v.z_ || w_ != v.w_);
}

[[maybe_unused]] float &Vector4D::operator [](int index)
{
    // Some sanity checks
    static_assert(offsetof(Vector4D, x_) == 0);
    static_assert(offsetof(Vector4D, y_) == sizeof(float));

    return *(index + &x_);
}

[[maybe_unused]] float Vector4D::operator [](int index) const
{
    // Some sanity checks
    static_assert(offsetof(Vector4D, x_) == 0);
    static_assert(offsetof(Vector4D, y_) == sizeof(float));

    return *(index + &x_);
}

[[maybe_unused]] bool Vector4D::operator > (Vector4D const &v) const
{
    return x_ > v.x_ && y_ > v.y_ && z_ > v.z_ && w_ > v.w_;
}

[[maybe_unused]] bool Vector4D::operator < (Vector4D const &v) const
{
    return x_ < v.x_ && y_ < v.y_ && z_ < v.z_ && w_ < v.w_;
}

[[maybe_unused]] Vector4D operator + (Vector4D const &v1, Vector4D const &v2)
{
    return {v1.x_ + v2.x_, v1.y_ + v2.y_, v1.z_ + v2.z_, v1.w_ + v2.w_};
}

[[maybe_unused]] Vector4D operator + (Vector4D const &v, float s)
{
    return {v.x_ + s, v.y_ + s, v.z_ + s, v.w_ + s};
}

[[maybe_unused]] Vector4D operator - (Vector4D const &v1, Vector4D const &v2)
{
    return {v1.x_ - v2.x_, v1.y_ - v2.y_, v1.z_ - v2.z_, v1.w_ - v2.w_};
}

[[maybe_unused]] Vector4D operator - (Vector4D const &v, float s)
{
    return {v.x_ - s, v.y_ - s, v.z_ - s, v.w_ - s};
}

[[maybe_unused]] Vector4D operator * (float s, Vector4D const &v)
{
    return {v.x_ * s, v.y_ * s, v.z_ * s, v.w_ * s};
}

[[maybe_unused]] Vector4D operator * (Vector4D const &v, float s)
{
    return {v.x_ * s, v.y_ * s, v.z_ * s, v.w_ * s};
}

[[maybe_unused]] Vector4D operator * (Vector4D const &v1, Vector4D const &v2)
{
    return {v1.x_ * v2.x_, v1.y_ * v2.y_, v1.z_ * v2.z_, v1.w_ * v2.w_};
}

[[maybe_unused]] Vector4D operator / (Vector4D const &v, float s)
{
    float const inv = 1.0F / s;
    return {v.x_ * inv, v.y_ * inv, v.z_ * inv, v.w_ * inv};
}

[[maybe_unused]] Vector4D operator / (float s, Vector4D const &v)
{
    return {s / v.x_, s / v.y_, s / v.z_, s / v.w_};
}

} // namespace OpenGTX
