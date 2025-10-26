#ifndef VECTOR_3D_HPP
#define VECTOR_3D_HPP
#include <graphics_game_sdk/opengtx_base.h>
#include "math_common.hpp"

namespace OpenGTX {

class [[maybe_unused]] Vector3D final {
public:
    [[maybe_unused]] constexpr INLINE Vector3D() noexcept
        : x_(0.0F),
          y_(0.0F),
          z_(0.0F)
    {}

    INLINE constexpr Vector3D(Vector3D const &) = default;
    INLINE Vector3D &operator= (Vector3D const &) = default;

    [[maybe_unused]] constexpr INLINE explicit Vector3D(float val) noexcept
        : x_(val),
          y_(val),
          z_(val)
    {}

    constexpr INLINE Vector3D(float x, float y, float z) noexcept
        : x_(x),
          y_(y),
          z_(z)
    {}

    [[maybe_unused]] constexpr INLINE explicit Vector3D(float const *raw) noexcept
        : x_(raw[0U]),
          y_(raw[1U]),
          z_(raw[2U])
    {}

    [[maybe_unused]] constexpr INLINE Vector3D(const OpenGTX_Vector3 &v3) noexcept
        : x_(v3.x), 
          y_(v3.y),
          z_(v3.z) 
    {}

    ~Vector3D() = default;

    [[maybe_unused, nodiscard]] static Vector3D Zero();
    [[maybe_unused, nodiscard]] static Vector3D X();
    [[maybe_unused, nodiscard]] static Vector3D Y();
    [[maybe_unused, nodiscard]] static Vector3D Z();

    // Vector length
    [[maybe_unused]] [[nodiscard]] float Length() const;

    // Square of vector length
    [[maybe_unused, nodiscard]] float LengthSq() const;
    [[maybe_unused, nodiscard]] float GetDistanceSqFrom(Vector3D const &other) const;
    [[maybe_unused, nodiscard]] float GetDistanceFrom(Vector3D const &other) const;
    [[maybe_unused, nodiscard]] bool IsZero() const;

    [[maybe_unused]] Vector3D &Normalize();

    [[maybe_unused]] Vector3D &RotateXZ(float angle);
    [[maybe_unused]] Vector3D &RotateXY(float angle);
    [[maybe_unused]] Vector3D &RotateYZ(float angle);

    [[maybe_unused]] explicit operator float * ();
    [[maybe_unused]] explicit operator float const * () const;

    [[maybe_unused, nodiscard]] Vector3D operator - () const;

    [[maybe_unused, nodiscard]] bool operator == (Vector3D const &v) const;
    [[maybe_unused, nodiscard]] bool operator != (Vector3D const &v) const;

    [[maybe_unused]] Vector3D &operator += (Vector3D const &v);
    [[maybe_unused]] Vector3D &operator -= (Vector3D const &v);
    [[maybe_unused]] Vector3D &operator *= (float s);
    [[maybe_unused]] Vector3D &operator /= (float s);
    [[maybe_unused]] Vector3D &operator += (float s);
    [[maybe_unused]] Vector3D &operator -= (float s);
    [[maybe_unused]] Vector3D &operator /= (Vector3D const &s);
    [[maybe_unused]] Vector3D &operator *= (Vector3D const &v);
    [[maybe_unused]] OpenGTX_Vector3 operator()(Vector3D const &v);
    [[maybe_unused]] operator OpenGTX_Vector3() const;

    [[maybe_unused, nodiscard]] float &operator [](int index);
    [[maybe_unused, nodiscard]] float operator [] (int index) const;

    [[maybe_unused, nodiscard]] bool operator > (Vector3D const &v) const;
    [[maybe_unused, nodiscard]] bool operator >= (Vector3D const &v) const;
    [[maybe_unused, nodiscard]] bool operator < (Vector3D const &v) const;
    [[maybe_unused, nodiscard]] bool operator <= (Vector3D const &v) const;

    float x_;
    float y_;
    float z_;

private:
    static void Rotate(float &val1, float &val2, float angle);
    [[nodiscard]] static float InvSqrt(float x);
};

[[maybe_unused]] void CopyVector(Vector3D *outVector, Vector3D const *inVector);
[[maybe_unused]] void CopyVector(Vector3D &outVector, Vector3D const &inVector);
[[maybe_unused]] void CopyVector(Vector3D *outVector, Vector3D const &inVector);
[[maybe_unused]] void CopyVector(Vector3D &outVector, Vector3D const *inVector);

[[maybe_unused, nodiscard]] float DotProduct(Vector3D const &v1, Vector3D const &v2);
[[maybe_unused, nodiscard]] Vector3D CrossProduct(Vector3D const &v1, Vector3D const &v2);

[[maybe_unused, nodiscard]] Vector3D operator + (Vector3D const &v1, Vector3D const &v2);
[[maybe_unused, nodiscard]] Vector3D operator + (Vector3D const &v, float s);
[[maybe_unused, nodiscard]] Vector3D operator - (Vector3D const &v1, Vector3D const &v2);
[[maybe_unused, nodiscard]] Vector3D operator - (Vector3D const &v, float s);
[[maybe_unused, nodiscard]] Vector3D operator * (Vector3D const &v, float s);
[[maybe_unused, nodiscard]] Vector3D operator * (float s, Vector3D const &v);
[[maybe_unused, nodiscard]] Vector3D operator * (Vector3D const &v1, Vector3D const &v2);
[[maybe_unused, nodiscard]] Vector3D operator / (Vector3D const &v, float s);
[[maybe_unused, nodiscard]] Vector3D operator / (float s, Vector3D const &v);

} // namespace OpenGTX

#endif // VECTOR_3D_HPP
