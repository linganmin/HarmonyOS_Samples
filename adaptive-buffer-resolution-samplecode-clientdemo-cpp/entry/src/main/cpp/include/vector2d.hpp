/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef VECTOR_2D_HPP
#define VECTOR_2D_HPP

#include "math_common.hpp"

namespace AdaptiveBufferResolution {
class [[maybe_unused]] Vector2D final {
public:
    [[maybe_unused]] constexpr INLINE Vector2D() noexcept : x_(0.0F), y_(0.0F) {}

    INLINE Vector2D(Vector2D const &) = default;
    INLINE Vector2D &operator = (Vector2D const &) = default;

    [[maybe_unused]] constexpr explicit INLINE Vector2D(float const * raw) noexcept : x_(raw[0U]), y_(raw[1U]) {}

    [[maybe_unused]] constexpr explicit INLINE Vector2D(float val) noexcept : x_(val), y_(val) {}

    template <typename T>
    [[maybe_unused]] constexpr INLINE Vector2D(T x, T y) noexcept : x_(static_cast<float>(x)), y_(static_cast<float>(y))
    {}

    INLINE ~Vector2D() = default;

    [[maybe_unused]] static Vector2D Zero();
    [[maybe_unused]] static Vector2D X();
    [[maybe_unused]] static Vector2D Y();

    [[nodiscard, maybe_unused]] float Length() const;
    [[nodiscard, maybe_unused]] float LengthSq() const;

    [[maybe_unused]] [[nodiscard]] float GetDistanceFrom(Vector2D const & other) const;
    [[maybe_unused]] Vector2D &Rotate(float angle);
    [[maybe_unused]] Vector2D &Normalize();
    [[nodiscard, maybe_unused]] Vector2D &RotateRad(float angle);
    [[maybe_unused]] Vector2D &RotateDeg(float angle);

    template <typename T>[[maybe_unused]] INLINE Vector2D &operator = (T const & data)
    {
        *this = reinterpret_cast<Vector2D const &>(data);
        return *this;
    }

    template <typename T>[[maybe_unused]] INLINE Vector2D &operator = (const T *data)
    {
        *this = reinterpret_cast<Vector2D const &>(data);
        return *this;
    }

    [[maybe_unused]] operator float *();
    operator float const *() const;

    [[maybe_unused]] Vector2D operator - () const;
    [[maybe_unused]] Vector2D &operator += (Vector2D const & v);
    [[maybe_unused]] Vector2D &operator -= (Vector2D const & v);

    [[maybe_unused]] Vector2D &operator *= (float s);
    [[maybe_unused]] Vector2D &operator /= (float s);
    [[maybe_unused]] Vector2D &operator -= (float s);
    [[maybe_unused]] Vector2D &operator += (float s);
    [[maybe_unused]] Vector2D &operator /= (Vector2D const & v);
    Vector2D &operator *= (Vector2D const & v);

    [[maybe_unused, nodiscard]] bool operator == (Vector2D const & other) const;
    [[maybe_unused, nodiscard]] bool operator != (Vector2D const & other) const;

    [[maybe_unused, nodiscard]] float &operator[](int index);
    [[maybe_unused, nodiscard]] float operator[](int index) const;

    [[maybe_unused, nodiscard]] bool operator > (Vector2D const & v) const;
    [[maybe_unused, nodiscard]] bool operator < (Vector2D const & v) const;

    float x_;
    float y_;
};

[[maybe_unused, nodiscard]] float DotProduct(Vector2D const & v1, Vector2D const & v2);
[[maybe_unused, nodiscard]] Vector2D operator + (Vector2D const & v1, Vector2D const & v2);
[[maybe_unused, nodiscard]] Vector2D operator + (Vector2D const & v, float s);
[[maybe_unused, nodiscard]] Vector2D operator - (Vector2D const & v1, Vector2D const & v2);
[[maybe_unused, nodiscard]] Vector2D operator - (Vector2D const & v, float s);
[[maybe_unused, nodiscard]] Vector2D operator - (float s, Vector2D const & v);
[[maybe_unused, nodiscard]] Vector2D operator*(Vector2D const & v, float s);
[[maybe_unused, nodiscard]] Vector2D operator*(float s, Vector2D const & v);
[[maybe_unused, nodiscard]] Vector2D operator*(Vector2D const & v1, Vector2D const & v2);
[[maybe_unused, nodiscard]] Vector2D operator / (Vector2D const & v1, Vector2D const & v2);
[[maybe_unused, nodiscard]] Vector2D operator / (Vector2D const & v, float s);
[[maybe_unused, nodiscard]] Vector2D operator / (float s, Vector2D const & v);
} // namespace AdaptiveBufferResolution

#endif // VECTOR_2D_HPP
