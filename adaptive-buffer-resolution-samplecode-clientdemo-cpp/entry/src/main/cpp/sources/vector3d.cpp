/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "vector3d.hpp"
#include <cstring>

namespace AdaptiveBufferResolution {
[[maybe_unused]] Vector3D Vector3D::Zero()
{
    return { 0.0F, 0.0F, 0.0F };
}

[[maybe_unused]] Vector3D Vector3D::X()
{
    return { 1.0F, 0.0F, 0.0F };
}

[[maybe_unused]] Vector3D Vector3D::Y()
{
    return { 0.0F, 1.0F, 0.0F };
}

[[maybe_unused]] Vector3D Vector3D::Z()
{
    return { 0.0F, 0.0F, 1.0F };
}

[[maybe_unused]] float Vector3D::Length() const
{
    return std::sqrtf(LengthSq());
}

[[maybe_unused]] float Vector3D::LengthSq() const
{
    return x_ * x_ + y_ * y_ + z_ * z_;
}

[[maybe_unused]] float Vector3D::GetDistanceSqFrom(Vector3D const & other) const
{
    Vector3D d = *this;
    d -= other;
    return d.LengthSq();
}

[[maybe_unused]] float Vector3D::GetDistanceFrom(Vector3D const & other) const
{
    return std::sqrt(GetDistanceSqFrom(other));
}

[[maybe_unused]] bool Vector3D::IsZero() const
{
    constexpr Vector3D const zero(0.0F);
    return std::memcmp(this, &zero, sizeof(zero)) == 0;
}

[[maybe_unused]] Vector3D &Vector3D::Normalize()
{
    float const l = InvSqrt(LengthSq());
    x_ *= l;
    y_ *= l;
    z_ *= l;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::RotateXZ(float angle)
{
    Rotate(x_, z_, angle);
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::RotateXY(float angle)
{
    Rotate(x_, y_, angle);
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::RotateYZ(float angle)
{
    Rotate(y_, z_, angle);
    return *this;
}

[[maybe_unused]] Vector3D::operator float *()
{
    return &x_;
}

[[maybe_unused]] Vector3D::operator float const *() const
{
    return &x_;
}

[[maybe_unused]] Vector3D Vector3D::operator - () const
{
    return { -x_, -y_, -z_ };
}

[[maybe_unused]] bool Vector3D::operator == (Vector3D const & v) const
{
    return (x_ == v.x_ && y_ == v.y_ && z_ == v.z_);
}

[[maybe_unused]] bool Vector3D::operator != (Vector3D const & v) const
{
    return (x_ != v.x_ || y_ != v.y_ || z_ != v.z_);
}

[[maybe_unused]] Vector3D &Vector3D::operator += (Vector3D const & v)
{
    x_ += v.x_;
    y_ += v.y_;
    z_ += v.z_;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator -= (Vector3D const & v)
{
    x_ -= v.x_;
    y_ -= v.y_;
    z_ -= v.z_;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator *= (float s)
{
    x_ *= s;
    y_ *= s;
    z_ *= s;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator /= (float s)
{
    *this *= (1.0F / s);
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator += (float s)
{
    x_ += s;
    y_ += s;
    z_ += s;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator -= (float s)
{
    x_ -= s;
    y_ -= s;
    z_ -= s;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator /= (Vector3D const & s)
{
    x_ /= s.x_;
    y_ /= s.y_;
    z_ /= s.z_;
    return *this;
}

[[maybe_unused]] Vector3D &Vector3D::operator *= (Vector3D const & v)
{
    x_ *= v.x_;
    y_ *= v.y_;
    z_ *= v.z_;
    return *this;
}

[[maybe_unused]] float &Vector3D::operator[](int index)
{
    return *(index + (&x_));
}

[[maybe_unused]] float Vector3D::operator[](int index) const
{
    return *(index + (&x_));
}

[[maybe_unused]] bool Vector3D::operator > (Vector3D const & v) const
{
    return x_ > v.x_ && y_ > v.y_ && z_ > v.z_;
}

[[maybe_unused]] bool Vector3D::operator >= (Vector3D const & v) const
{
    return x_ >= v.x_ && y_ >= v.y_ && z_ >= v.z_;
}

[[maybe_unused]] bool Vector3D::operator < (Vector3D const & v) const
{
    return x_ < v.x_ && y_ < v.y_ && z_ < v.z_;
}

[[maybe_unused]] bool Vector3D::operator <= (Vector3D const & v) const
{
    return x_ <= v.x_ && y_ <= v.y_ && z_ <= v.z_;
}

[[maybe_unused]] ABR_Vector3 Vector3D::operator () (Vector3D const & v)
{
    return ABR_Vector3{
        .x = v.x_,
        .y = v.y_,
        .z = v.z_
    };
}

[[maybe_unused]] Vector3D::operator ABR_Vector3() const
{
    return ABR_Vector3{
        .x = x_,
        .y = y_,
        .z = z_
    };
}

void Vector3D::Rotate(float &val1, float &val2, float angle)
{
    float const cosa = std::cos(angle);
    float const sina = std::sin(angle);
    float const v1 = val1 * cosa - val2 * sina;
    float const v2 = val1 * sina + val2 * cosa;
    val1 = v1;
    val2 = v2;
}

float Vector3D::InvSqrt(float x)
{
    // 0.5 means half of x value
    float const xhalf = 0.5F * x;
    int i = *reinterpret_cast<int *>(&x);

    // refer to the fast inverse square root implementation
    // Note "NOLINT" is a warning suppressor control macro for clang-tidy (bitwise and signed).
    i = 0x5f3759df - (i >> 1); // NOLINT
    x = *reinterpret_cast<float *>(&i);

    // Newton method iteration
    return x * (1.5F - xhalf * x * x);
}

[[maybe_unused]] float DotProduct(Vector3D const & v1, Vector3D const & v2)
{
    return v1.x_ * v2.x_ + v1.y_ * v2.y_ + v1.z_ * v2.z_;
}

[[maybe_unused]] Vector3D CrossProduct(Vector3D const & v1, Vector3D const & v2)
{
    return { v1.y_ * v2.z_ - v1.z_ * v2.y_, -v1.x_ * v2.z_ + v1.z_ * v2.x_, v1.x_ * v2.y_ - v1.y_ * v2.x_ };
}

[[maybe_unused]] Vector3D operator + (Vector3D const & v1, Vector3D const & v2)
{
    return { v1.x_ + v2.x_, v1.y_ + v2.y_, v1.z_ + v2.z_ };
}

[[maybe_unused]] Vector3D operator + (Vector3D const & v, float s)
{
    return { v.x_ + s, v.y_ + s, v.z_ + s };
}

[[maybe_unused]] Vector3D operator - (Vector3D const & v1, Vector3D const & v2)
{
    return { v1.x_ - v2.x_, v1.y_ - v2.y_, v1.z_ - v2.z_ };
}

[[maybe_unused]] Vector3D operator - (Vector3D const & v, float s)
{
    return { v.x_ - s, v.y_ - s, v.z_ - s };
}

[[maybe_unused]] Vector3D operator*(Vector3D const & v, float s)
{
    return { v.x_ * s, v.y_ * s, v.z_ * s };
}

[[maybe_unused]] Vector3D operator*(float s, Vector3D const & v)
{
    return { v.x_ * s, v.y_ * s, v.z_ * s };
}

[[maybe_unused]] Vector3D operator*(Vector3D const & v1, Vector3D const & v2)
{
    return { v1.x_ * v2.x_, v1.y_ * v2.y_, v1.z_ * v2.z_ };
}

[[maybe_unused]] Vector3D operator / (Vector3D const & v, float s)
{
    return v * (1.0F / s);
}

[[maybe_unused]] Vector3D operator / (float s, Vector3D const & v)
{
    return { s / v.x_, s / v.y_, s / v.z_ };
}
} // namespace AdaptiveBufferResolution
