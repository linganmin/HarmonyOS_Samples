#ifndef VECTOR_4D_HPP
#define VECTOR_4D_HPP

#include "math_common.hpp"

namespace OpenGTX {

class Vector4D final {
public:
    using uchar = unsigned char;
    using uint = unsigned int;

    [[maybe_unused]] INLINE Vector4D() = default;

    [[maybe_unused]] INLINE Vector4D(Vector4D const &) = default;
    [[maybe_unused]] INLINE Vector4D &operator= (Vector4D const &) = default;

    [[maybe_unused]] INLINE Vector4D(Vector4D &&) = default;
    [[maybe_unused]] INLINE Vector4D &operator= (Vector4D &&) = default;

    constexpr INLINE Vector4D(float x, float y, float z, float w) noexcept
        : x_(x),
          y_(y),
          z_(z),
          w_(w)
    {}

    [[maybe_unused]] explicit Vector4D(uchar const *color) noexcept;

    ~Vector4D() = default;

    [[maybe_unused, nodiscard]] static Vector4D Zero();
    [[maybe_unused]] void Set(float x, float y, float z, float w);

    uint RGBA() const;
    [[maybe_unused, nodiscard]] bool IsZero() const;
    [[maybe_unused]] Vector4D &FromARGB(uint color);
    [[maybe_unused]] Vector4D &FromRGBA(uint color);
    void FromColor(unsigned char const *color);

    [[maybe_unused]] explicit operator uint () const;

    [[maybe_unused]] explicit operator float * ();
    [[maybe_unused]] explicit operator float const * () const;

    [[maybe_unused]] Vector4D operator - () const;
    [[maybe_unused]] Vector4D &operator += (Vector4D const &v);
    [[maybe_unused]] Vector4D &operator -= (Vector4D const &v);
    [[maybe_unused]] Vector4D &operator *= (float s);
    [[maybe_unused]] Vector4D &operator /= (float s);
    [[maybe_unused]] Vector4D &operator /= (Vector4D const &v);
    [[maybe_unused]] Vector4D &operator *= (Vector4D const &v);
    [[maybe_unused]] Vector4D &operator += (float v);
    [[maybe_unused]] Vector4D &operator -= (float v);

    [[maybe_unused]] bool operator == (Vector4D const &v) const;
    [[maybe_unused]] bool operator != (Vector4D const &v) const;

    [[maybe_unused]] float &operator [](int index);
    [[maybe_unused]] float operator [](int index) const;

    [[maybe_unused, nodiscard]] bool operator > (Vector4D const &v) const;
    [[maybe_unused, nodiscard]] bool operator < (Vector4D const &v) const;

    union {
        float x_;
        float r_;
    };

    union {
        float y_;
        float g_;
    };

    union {
        float z_;
        float b_;
    };

    union {
        float w_;
        float a_;
    };
};

[[maybe_unused, nodiscard]] Vector4D operator + (Vector4D const &v1, Vector4D const &v2);
[[maybe_unused, nodiscard]] Vector4D operator + (Vector4D const &v, float s);
[[maybe_unused, nodiscard]] Vector4D operator - (Vector4D const &v1, Vector4D const &v2);
[[maybe_unused, nodiscard]] Vector4D operator - (Vector4D const &v, float s);
[[maybe_unused, nodiscard]] Vector4D operator * (float s, Vector4D const &v);
[[maybe_unused, nodiscard]] Vector4D operator * (Vector4D const &v, float s);
[[maybe_unused, nodiscard]] Vector4D operator * (Vector4D const &v1, Vector4D const &v2);
[[maybe_unused, nodiscard]] Vector4D operator / (Vector4D const &v, float s);
[[maybe_unused, nodiscard]] Vector4D operator / (float s, Vector4D const &v);

} // namespace OpenGTX

#endif // VECTOR_4D_HPP
