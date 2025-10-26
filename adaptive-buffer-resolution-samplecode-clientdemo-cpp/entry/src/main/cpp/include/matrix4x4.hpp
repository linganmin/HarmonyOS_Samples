/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef MATRIX_4X4_HPP
#define MATRIX_4X4_HPP

#include "vector3d.hpp"
#include "vector4d.hpp"

namespace AdaptiveBufferResolution {
/*
By convention it's column-major matrix:
The elements are mapped to the C++ memory the following way:

    |a11 a12 a13 a14|
A = |a21 a22 a23 a24|
    |a31 a32 a33 a34|
    |a41 a42 a43 a44|
->
data[16] = {a11 a21 a31 a41  a12 a22 a32 a42  a13 a23 a33 a43  a14 a24 a34 a44}
*/

// Forward declaration
class Matrix4x4;
[[maybe_unused, nodiscard]] Matrix4x4 operator*(Matrix4x4 const & a, Matrix4x4 const & b);

class ALIGN16 Matrix4x4 final {
public:
    [[maybe_unused]] constexpr INLINE Matrix4x4() noexcept : data_{} {}

    INLINE Matrix4x4(Matrix4x4 const &) = default;
    INLINE Matrix4x4 &operator = (Matrix4x4 const &) = default;

    INLINE Matrix4x4(Matrix4x4 &&) = default;
    INLINE Matrix4x4 &operator = (Matrix4x4 &&) = default;

    [[maybe_unused]] constexpr explicit INLINE Matrix4x4(float a) noexcept
        : data_{ Vector4D(a, 0.0F, 0.0F, 0.0F), Vector4D(0.0F, a, 0.0F, 0.0F), Vector4D(0.0F, 0.0F, a, 0.0F),
        Vector4D(0.0F, 0.0F, 0.0F, a) }
    {}

    [[maybe_unused]] constexpr explicit INLINE Matrix4x4(float a, float d, float h, float l, float b, float e, float i,
        float m, float c, float f, float j, float n, float p, float q, float r, float s) noexcept
        : data_{ Vector4D(a, b, c, p), Vector4D(d, e, f, q), Vector4D(h, i, j, r), Vector4D(l, m, n, s) }
    {}

    [[maybe_unused, nodiscard]] float const * Data() const;
    [[maybe_unused, nodiscard]] float *Data();

    [[maybe_unused]] void FromRowMajorMatrix(float const * m);

    [[maybe_unused, nodiscard]] bool IsIdentity() const;
    [[maybe_unused, nodiscard]] static Matrix4x4 Identity();

    Matrix4x4 &Scale(float x, float y, float z);
    [[maybe_unused]] Matrix4x4 &Scale(float s);
    [[maybe_unused]] void Print() const;
    void RotateX(float angle);
    [[maybe_unused]] void RotateY(float angle);
    [[maybe_unused]] void RotateZ(float angle);
    [[maybe_unused]] void ClearRotate();

    // Calculate rotation matrix using angles
    [[maybe_unused]] void RotateYawPitchRollMatrix(float pitch, float yaw, float roll);

    void MatrixRotationAxis(Vector3D const & v, float angle);

    [[maybe_unused]] Matrix4x4 &FromQuaternion(float const * quat);
    [[maybe_unused]] void RotateMatrix(Vector3D const & v, float angle);
    [[maybe_unused]] void RotateXYZ(float pitch, float yaw, float roll);

    [[maybe_unused, nodiscard]] static Matrix4x4 MirrorX();
    [[maybe_unused, nodiscard]] static Matrix4x4 MirrorY();
    [[maybe_unused, nodiscard]] static Matrix4x4 MirrorZ();

    void Translate(float x, float y, float z);
    [[maybe_unused]] void Translate(Vector3D const & v);

    [[maybe_unused, nodiscard]] float Trace();

    // Extract euler angles. [pitch, yaw, roll] order
    [[maybe_unused, nodiscard]] Vector3D GetRollPitchYaw() const;

    // Extract euler angles.
    void GetRollPitchYaw(float &pitch, float &yaw, float &roll) const;

    [[maybe_unused, nodiscard]] Vector3D GetPosition();

    Matrix4x4 &Invert(Matrix4x4 const & a);
    [[maybe_unused]] Matrix4x4 &Invert();
    [[maybe_unused, nodiscard]] static Matrix4x4 InvertRotTrans(Matrix4x4 const & m);

    [[maybe_unused]] Matrix4x4 &Transpose();

    [[maybe_unused]] void PerspectiveFovOpenGL(float fov, float aspect, float zNear, float zFar);
    [[maybe_unused]] void PerspectiveOpenGL(float width, float height, float zNear, float zFar);
    [[maybe_unused]] void OrthoOpenGL(float left, float right, float top, float bottom, float zNear, float zFar);
    [[maybe_unused]] void OrthoOpenGL(float width, float height, float zNear, float zFar);
    [[maybe_unused]] void LookAtOpenGL(Vector3D const & eye, Vector3D const & lookat, Vector3D const & up);

    [[maybe_unused]] void LoadIdentity();
    [[maybe_unused, nodiscard]] Vector3D TransformAsNormal(Vector3D const & v) const;
    [[maybe_unused, nodiscard]] Vector3D TransformAsPoint(Vector3D const & v) const;

    [[maybe_unused]] Matrix4x4 &operator *= (float s);
    [[maybe_unused]] Matrix4x4 &operator /= (float s);
    [[maybe_unused]] Matrix4x4 &operator += (Matrix4x4 const & m);
    [[maybe_unused]] Matrix4x4 &operator -= (Matrix4x4 const & m);

    [[maybe_unused, nodiscard]] Vector4D const & operator[](int i) const;
    [[maybe_unused, nodiscard]] Vector4D &operator[](int i);

    Vector4D data_[4U];

private:
    [[maybe_unused]] [[nodiscard]] static float Det2x2(float a1, float a2, float b1, float b2);

    [[maybe_unused]] [[nodiscard]] static float Det3x3(float a1, float a2, float a3, float b1, float b2, float b3,
        float c1, float c2, float c3);
};

[[maybe_unused, nodiscard]] Matrix4x4 operator + (Matrix4x4 const & a, Matrix4x4 const & b);
[[maybe_unused, nodiscard]] Matrix4x4 operator - (Matrix4x4 const & a, Matrix4x4 const & b);
[[maybe_unused, nodiscard]] bool operator == (Matrix4x4 const & a, Matrix4x4 const & b);
[[maybe_unused, nodiscard]] bool operator != (Matrix4x4 const & a, Matrix4x4 const & b);
[[maybe_unused, nodiscard]] Matrix4x4 operator*(Matrix4x4 const & a, Matrix4x4 const & b);
} // namespace AdaptiveBufferResolution

#endif // MATRIX_4X4_HPP
