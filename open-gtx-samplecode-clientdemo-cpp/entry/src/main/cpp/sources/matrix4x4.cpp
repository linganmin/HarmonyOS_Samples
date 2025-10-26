#include <matrix4x4.hpp>
#include <log.hpp>
#include <cstring>

namespace OpenGTX {

[[maybe_unused]] float const *Matrix4x4::Data() const
{
    // Sanity check
    static_assert(sizeof(Matrix4x4) == 16U * sizeof(float));
    return &data_[0U].x_;
}

[[maybe_unused]] float *Matrix4x4::Data()
{
    // Sanity check
    static_assert(sizeof(Matrix4x4) == 16U * sizeof(float));
    return &data_[0U].x_;
}

[[maybe_unused]] void Matrix4x4::Print() const
{
    for (auto &v : data_) {
        GOLOGD("%f, %f, %f, %f", v.x_, v.y_, v.z_, v.w_);
    }
}

[[maybe_unused]] void Matrix4x4::FromColumnMajorMatrix(float const *m)
{
    std::memcpy(data_, m, sizeof(Matrix4x4));
}

[[maybe_unused]] void Matrix4x4::FromRowMajorMatrix(float const *m)
{
    Vector4D &c0 = data_[0U];
    c0.x_ = m[0U];
    c0.y_ = m[4U];
    c0.z_ = m[8U];
    c0.w_ = m[12U];

    Vector4D &c1 = data_[1U];
    c1.x_ = m[1U];
    c1.y_ = m[5U];
    c1.z_ = m[9U];
    c1.w_ = m[13U];

    Vector4D &c2 = data_[2U];
    c2.x_ = m[2U];
    c2.y_ = m[6U];
    c2.z_ = m[10U];
    c2.w_ = m[14U];

    Vector4D &c3 = data_[3U];
    c3.x_ = m[3U];
    c3.y_ = m[7U];
    c3.z_ = m[11U];
    c3.w_ = m[15U];
}

[[maybe_unused]] bool Matrix4x4::IsIdentity() const
{
    constexpr Matrix4x4 const identity(1.0F);
    return memcmp(this, &identity, sizeof(identity)) == 0;
}

[[maybe_unused]] Matrix4x4 Matrix4x4::Identity()
{
    return Matrix4x4(1.0F);
}

Matrix4x4 &Matrix4x4::Scale(float x, float y, float z)
{
    data_[0U] = Vector4D(x, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, y, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, z, 0.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
    return *this;
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::Scale(float s)
{
    return Scale(s, s, s);
}

void Matrix4x4::RotateX(float angle)
{
    float const c = std::cos(angle);
    float const s = std::sin(angle);

    data_[0U] = Vector4D(1.0F, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, c, s, 0.0F);
    data_[2U] = Vector4D(0.0F, -s, c, 0.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
}

[[maybe_unused]] void Matrix4x4::RotateY(float angle)
{
    float const c = std::cos(angle);
    float const s = std::sin(angle);

    data_[0U] = Vector4D(c, 0.0F, -s, 0.0F);
    data_[1U] = Vector4D(0.0F, 1.0F, 0.0F, 0.0F);
    data_[2U] = Vector4D(s, 0.0F, c, 0.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
}

[[maybe_unused]] void Matrix4x4::RotateZ(float angle)
{
    float const c = std::cos(angle);
    float const s = std::sin(angle);

    data_[0U] = Vector4D(c, s, 0.0F, 0.0F);
    data_[1U] = Vector4D(-s, c, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, 1.0F, 0.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
}

[[maybe_unused]] void Matrix4x4::ClearRotate()
{
    Vector4D &c0 = data_[0U];
    c0.x_ = 1.0F;
    c0.y_ = 0.0F;
    c0.z_ = 0.0F;

    Vector4D &c1 = data_[1U];
    c1.x_ = 0.0F;
    c1.y_ = 1.0F;
    c1.z_ = 0.0F;

    Vector4D &c2 = data_[2U];
    c2.x_ = 0.0F;
    c2.y_ = 0.0F;
    c2.z_ = 1.0F;
}

[[maybe_unused]] void Matrix4x4::RotateYawPitchRollMatrix(float pitch, float yaw, float roll)
{
    Matrix4x4 matPitch;
    Matrix4x4 matYaw;
    Matrix4x4 matRoll;
    matPitch.RotateX(pitch);
    matYaw.RotateX(yaw);
    matRoll.RotateX(roll);
    *this = matPitch * matYaw * matRoll;
}

void Matrix4x4::MatrixRotationAxis(Vector3D const &v, float angle)
{
    float const c = std::cos(angle);
    float const s = std::sin(angle);

    float const t = 1.0F - c;
    float const tx = t * v.x_;
    float const ty = t * v.y_;
    float const tz = t * v.z_;
    float const tzy = ty * v.z_;
    float const txy = tx * v.y_;
    float const txz = tx * v.z_;
    float const sx = s * v.x_;
    float const sy = s * v.y_;
    float const sz = s * v.z_;

    Vector4D &c0 = data_[0U];
    c0.x_ = tx * v.x_ + c;
    c0.y_ = txy + sz;
    c0.z_ = txz - sy;
    c0.w_ = 0.0F;

    Vector4D &c1 = data_[1U];
    c1.x_ = txy - sz;
    c1.y_ = ty * v.y_ + c;
    c1.z_ = tzy + sx;
    c1.w_ = 0.0F;

    Vector4D &c2 = data_[2U];
    c2.x_ = txz + sy;
    c2.y_ = tzy - sx;
    c2.z_ = tz * v.z_ + c;
    c1.w_ = 0.0F;

    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::FromQuaternion(float const *quat)
{
    struct Quat final {
        float x_;
        float y_;
        float z_;
        float w_;
    };

    auto const &q = *reinterpret_cast<Quat const *>(quat);

    float const x2 = q.x_ + q.x_;
    float const y2 = q.y_ + q.y_;
    float const z2 = q.z_ + q.z_;
    float const xx = q.x_ * x2;
    float const yy = q.y_ * y2;
    float const zz = q.z_ * z2;
    float const xy = q.x_ * y2;
    float const yz = q.y_ * z2;
    float const xz = q.z_ * x2;
    float const wx = q.w_ * x2;
    float const wy = q.w_ * y2;
    float const wz = q.w_ * z2;

    Vector4D &c0 = data_[0U];
    c0.x_ = 1.0F - (yy + zz);
    c0.y_ = xy + wz;
    c0.z_ = xz - wy;
    c0.w_ = 0.0F;

    Vector4D &c1 = data_[1U];
    c1.x_ = xy - wz;
    c1.y_ = 1.0F - (xx + zz);
    c1.z_ = yz + wx;
    c1.w_ = 0.0F;

    Vector4D &c2 = data_[2U];
    c2.x_ = xz + wy;
    c2.y_ = yz - wx;
    c2.z_ = 1.0F - (xx + yy);
    c2.w_ = 0.0F;

    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
    return *this;
}

[[maybe_unused]] void Matrix4x4::RotateMatrix(Vector3D const &v, float angle)
{
    MatrixRotationAxis(v, DEG2RAD * angle);
}

[[maybe_unused]] void Matrix4x4::RotateXYZ(float pitch, float yaw, float roll)
{
    float const cosPitch = std::cos(pitch);
    float const sinPitch = std::sin(pitch);
    float const cosYaw = std::cos(yaw);
    float const sinYaw = std::sin(yaw);
    float const cosRoll = std::cos(roll);
    float const sinRoll = std::sin(roll);

    Vector4D &c0 = data_[0U];
    c0.x_ = cosYaw * cosRoll;
    c0.y_ = sinPitch * sinYaw * cosRoll - sinRoll * cosPitch;
    c0.z_ = sinYaw * cosPitch * cosRoll + sinPitch * sinRoll;
    c0.w_ = 0.0F;

    Vector4D &c1 = data_[1U];
    c1.x_ = sinRoll * cosYaw;
    c1.y_ = sinPitch * sinYaw * sinRoll + cosPitch * cosRoll;
    c1.z_ = sinRoll * sinYaw * cosPitch - cosRoll * sinPitch;
    c1.w_ = 0.0F;

    Vector4D &c2 = data_[2U];
    c2.x_ = -sinYaw;
    c2.y_ = -sinPitch * cosYaw;
    c2.z_ = cosPitch * cosYaw;
    c1.w_ = 0.0F;

    data_[3U] = Vector4D(0.0F, 0.0F, 0.0F, 1.0F);
}

[[maybe_unused]] Matrix4x4 Matrix4x4::MirrorX()
{
    Matrix4x4 a(1.0F);
    a.data_[0U].x_ = -1.0F;
    return a;
}

[[maybe_unused]] Matrix4x4 Matrix4x4::MirrorY()
{
    Matrix4x4 a(1.0F);
    a.data_[1U].y_ = -1.0F;
    return a;
}

[[maybe_unused]] Matrix4x4 Matrix4x4::MirrorZ()
{
    Matrix4x4 a(1.0F);
    a.data_[2U].z_ = -1.0F;
    return a;
}

void Matrix4x4::Translate(float x, float y, float z)
{
    data_[0U] = Vector4D(1.0F, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, 1.0F, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, 1.0F, 0.0F);
    data_[3U] = Vector4D(x, y, z, 1.0F);
}

[[maybe_unused]] void Matrix4x4::Translate(Vector3D const &v)
{
    Translate(v.x_, v.y_, v.z_);
}

[[maybe_unused]] float Matrix4x4::Trace()
{
    return data_[0U][0U] + data_[1U][1U] + data_[2U][2U] + data_[3U][3U];
}

// Extract euler angles. [pitch, yaw, roll] order
[[maybe_unused]] Vector3D Matrix4x4::GetRollPitchYaw() const
{
    Vector3D angles;
    GetRollPitchYaw(angles.x_, angles.y_, angles.z_);
    return angles;
}

// Extract euler angles.
void Matrix4x4::GetRollPitchYaw(float &pitch, float &yaw, float &roll) const
{
    // Calculate Y-axis angle
    float const d = std::asin(data_[2U].x_);
    float const c = std::cos(d);

    yaw = d;

    if (std::fabs(c) <= EPS) {
        // Set X-axis angle to zero
        pitch = 0.0F;

        // And calculate Z-axis angle
        roll = std::atan2(-data_[1U].x_, data_[0U].x_);
        return;
    }

    float invC = 1.0F / c;

    // x = cos x * cos x / cos x
    float x = data_[2U].z_ * invC;

    // y = sin x * cos x / cos x
    float y = -data_[2U].y_ * invC;

    // atan2f(y, x) = atanf(y / x)
    pitch = std::atan2(y, x);
    x = data_[0U].x_ * invC;
    y = -data_[1U].x_ * invC;
    roll = std::atan2(y, x);
}

[[maybe_unused]] Vector3D Matrix4x4::GetPosition()
{
    Vector4D const &pos = data_[3U];
    return {pos.x_, pos.y_, pos.z_};
}

Matrix4x4 &Matrix4x4::Invert(Matrix4x4 const &a)
{
    auto const &aData = a.data_;
    auto const &a0 = aData[0U];
    auto const &a1 = aData[1U];
    auto const &a2 = aData[2U];
    auto const &a3 = aData[3U];

    auto &m0 = data_[0U];
    auto &m1 = data_[1U];
    auto &m2 = data_[2U];
    auto &m3 = data_[3U];

    m0.x_ = Det3x3(a1.y_, a1.z_, a1.w_, a2.y_, a2.z_, a2.w_, a3.y_, a3.z_, a3.w_);
    m0.y_ = -Det3x3(a0.y_, a0.z_, a0.w_, a2.y_, a2.z_, a2.w_, a3.y_, a3.z_, a3.w_);
    m0.z_ = Det3x3(a0.y_, a0.z_, a0.w_, a1.y_, a1.z_, a1.w_, a3.y_, a3.z_, a3.w_);
    m0.w_ = -Det3x3(a0.y_, a0.z_, a0.w_, a1.y_, a1.z_, a1.w_, a2.y_, a2.z_, a2.w_);

    m1.x_ = -Det3x3(a1.x_, a1.z_, a1.w_, a2.x_, a2.z_, a2.w_, a3.x_, a3.z_, a3.w_);
    m1.y_ = Det3x3(a0.x_, a0.z_, a0.w_, a2.x_, a2.z_, a2.w_, a3.x_, a3.z_, a3.w_);
    m1.z_ = -Det3x3(a0.x_, a0.z_, a0.w_, a1.x_, a1.z_, a1.w_, a3.x_, a3.z_, a3.w_);
    m1.w_ = Det3x3(a0.x_, a0.z_, a0.w_, a1.x_, a1.z_, a1.w_, a2.x_, a2.z_, a2.w_);

    m2.x_ = Det3x3(a1.x_, a1.y_, a1.w_, a2.x_, a2.y_, a2.w_, a3.x_, a3.y_, a3.w_);
    m2.y_ = -Det3x3(a0.x_, a0.y_, a0.w_, a2.x_, a2.y_, a2.w_, a3.x_, a3.y_, a3.w_);
    m2.z_ = Det3x3(a0.x_, a0.y_, a0.w_, a1.x_, a1.y_, a1.w_, a3.x_, a3.y_, a3.w_);
    m2.w_ = -Det3x3(a0.x_, a0.y_, a0.w_, a1.x_, a1.y_, a1.w_, a2.x_, a2.y_, a2.w_);

    m3.x_ = -Det3x3(a1.x_, a1.y_, a1.z_, a2.x_, a2.y_, a2.z_, a3.x_, a3.y_, a3.z_);
    m3.y_ = Det3x3(a0.x_, a0.y_, a0.z_, a2.x_, a2.y_, a2.z_, a3.x_, a3.y_, a3.z_);
    m3.z_ = -Det3x3(a0.x_, a0.y_, a0.z_, a1.x_, a1.y_, a1.z_, a3.x_, a3.y_, a3.z_);
    m3.w_ = Det3x3(a0.x_, a0.y_, a0.z_, a1.x_, a1.y_, a1.z_, a2.x_, a2.y_, a2.z_);

    float const det = (a0.x_ * m0.x_) + (a1.x_ * m0.y_) + (a2.x_ * m0.z_) + (a3.x_ * m0.w_);

    // The following divions goes unchecked for division
    // by zero. We should consider throwing Matrix exception
    // if det < eps.

    return this->operator*= (1.0F / det);
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::Invert()
{
    Matrix4x4 a(*this);
    Invert(a);
    return *this;
}

[[maybe_unused]] Matrix4x4 Matrix4x4::InvertRotTrans(Matrix4x4 const &m)
{
    Matrix4x4 result;
    auto &dstData = result.data_;

    auto const &srcData = m.data_;
    auto const &srcC0 = srcData[0U];
    auto const &srcC1 = srcData[1U];
    auto const &srcC2 = srcData[2U];
    auto const &srcC3 = srcData[3U];

    Vector4D &dstC0 = dstData[0U];
    dstC0.x_ = srcC0.x_;
    dstC0.y_ = srcC1.x_;
    dstC0.z_ = srcC2.x_;
    dstC0.w_ = 0.0F;

    Vector4D &dstC1 = dstData[1U];
    dstC1.x_ = srcC0.y_;
    dstC1.y_ = srcC1.y_;
    dstC1.z_ = srcC2.y_;
    dstC1.w_ = 0.0F;

    Vector4D &dstC2 = dstData[2U];
    dstC2.x_ = srcC0.z_;
    dstC2.y_ = srcC1.z_;
    dstC2.z_ = srcC2.z_;
    dstC2.w_ = 0.0F;

    Vector4D &dstC3 = dstData[3U];
    dstC3.x_ = -(srcC3.x_ * srcC0.x_) - (srcC3.y_ * srcC0.y_) - (srcC3.z_ * srcC0.z_);
    dstC3.y_ = -(srcC3.x_ * srcC1.x_) - (srcC3.y_ * srcC1.y_) - (srcC3.z_ * srcC1.z_);
    dstC3.z_ = -(srcC3.x_ * srcC2.x_) - (srcC3.y_ * srcC2.y_) - (srcC3.z_ * srcC2.z_);
    dstC3.w_ = 1.0F;

    return result;
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::Transpose()
{
    Matrix4x4 src(*this);

    auto const &srcData = src.data_;
    auto const &srcC0 = srcData[0U];
    auto const &srcC1 = srcData[1U];
    auto const &srcC2 = srcData[2U];
    auto const &srcC3 = srcData[3U];

    auto &dstC0 = data_[0U];
    auto &dstC1 = data_[1U];
    auto &dstC2 = data_[2U];
    auto &dstC3 = data_[3U];

    // Note main diagonal swap is not needed for transpose operation.

    dstC0.y_ = srcC1.x_;
    dstC0.z_ = srcC2.x_;
    dstC0.w_ = srcC3.x_;

    dstC1.x_ = srcC0.y_;
    dstC1.z_ = srcC2.y_;
    dstC1.w_ = srcC3.y_;

    dstC2.x_ = srcC0.z_;
    dstC2.y_ = srcC1.z_;
    dstC2.w_ = srcC3.z_;

    dstC3.x_ = srcC0.w_;
    dstC3.y_ = srcC1.w_;
    dstC3.z_ = srcC2.w_;

    return *this;
}

[[maybe_unused]] void Matrix4x4::PerspectiveFovOpenGL(float fov, float aspect, float zNear, float zFar)
{
    float const yScale = 1.0F / std::tan(fov * 0.5F);
    float const invRange = 1.0F / (zFar - zNear);

    data_[0U] = Vector4D(yScale / aspect, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, yScale, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, (zFar + zNear) * invRange, 1.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, -2.0F * zFar * zNear * invRange, 0.0F);
}

[[maybe_unused]] void Matrix4x4::PerspectiveOpenGL(float width, float height, float zNear, float zFar)
{
    float const invRange = 1.0F / (zFar - zNear);

    data_[0U] = Vector4D(2.0F * zNear / width, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, 2.0F * zNear / height, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, (zNear + zFar) * invRange, 1.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, -2.0F * zFar * zNear * invRange, 0.0F);
}

[[maybe_unused]] void Matrix4x4::OrthoOpenGL(float left, float right, float top, float bottom, float zNear, float zFar)
{
    float const drl = right - left;
    float const dtb = top - bottom;
    float const dfn = zFar - zNear;

    data_[0U] = Vector4D(2.0F / drl, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, 2.0F / dtb, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, -2.0F / dfn, 0.0F);
    data_[3U] = Vector4D(-(right + left) / drl, -(top + bottom) / dtb, -(zFar + zNear) / dfn, 1.0F);
}

[[maybe_unused]] void Matrix4x4::OrthoOpenGL(float width, float height, float zNear, float zFar)
{
    float const dfn = zFar - zNear;

    data_[0U] = Vector4D(2.0F / width, 0.0F, 0.0F, 0.0F);
    data_[1U] = Vector4D(0.0F, 2.0F / height, 0.0F, 0.0F);
    data_[2U] = Vector4D(0.0F, 0.0F, 2.0F / dfn, 0.0F);
    data_[3U] = Vector4D(0.0F, 0.0F, -(zFar + zNear) / dfn, 1.0F);
}

[[maybe_unused]] void Matrix4x4::LookAtOpenGL(Vector3D const &eye, Vector3D const &lookat, Vector3D const &up)
{
    Vector3D zaxis = lookat - eye;
    zaxis.Normalize();

    Vector3D const xaxis = CrossProduct(up, zaxis);
    Vector3D const yaxis = CrossProduct(zaxis, xaxis);

    data_[0U] = Vector4D(xaxis.x_, yaxis.x_, -zaxis.x_, 0.0F);
    data_[1U] = Vector4D(xaxis.y_, yaxis.y_, -zaxis.y_, 0.0F);
    data_[2U] = Vector4D(xaxis.z_, yaxis.z_, -zaxis.z_, 0.0F);
    data_[3U] = Vector4D(-DotProduct(xaxis, eye), -DotProduct(yaxis, eye), DotProduct(zaxis, eye), 1.0F);
}

[[maybe_unused]] void Matrix4x4::LoadIdentity()
{
    Scale(1.0F);
}

[[maybe_unused]] Vector3D Matrix4x4::TransformAsNormal(Vector3D const &v) const
{
    Vector3D const &r0 = *reinterpret_cast<Vector3D const *>(data_);
    Vector3D const &r1 = *reinterpret_cast<Vector3D const *>(data_ + 1U);
    Vector3D const &r2 = *reinterpret_cast<Vector3D const *>(data_ + 2U);
    return r0 * v.x_ + r1 * v.y_ + r2 * v.z_;
}

[[maybe_unused]] Vector3D Matrix4x4::TransformAsPoint(Vector3D const &v) const
{
    Vector3D const &r0 = *reinterpret_cast<Vector3D const *>(data_);
    Vector3D const &r1 = *reinterpret_cast<Vector3D const *>(data_ + 1U);
    Vector3D const &r2 = *reinterpret_cast<Vector3D const *>(data_ + 2U);
    Vector3D const &r3 = *reinterpret_cast<Vector3D const *>(data_ + 3U);
    return r0 * v.x_ + r1 * v.y_ + r2 * v.z_ + r3;
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::operator*= (float s)
{
    data_[0U] *= s;
    data_[1U] *= s;
    data_[2U] *= s;
    data_[3U] *= s;
    return *this;
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::operator/= (float s)
{
    return operator*= (1.0F / s);
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::operator+= (Matrix4x4 const &m)
{
    data_[0U] += m.data_[0U];
    data_[1U] += m.data_[1U];
    data_[2U] += m.data_[2U];
    data_[3U] += m.data_[3U];
    return *this;
}

[[maybe_unused]] Matrix4x4 &Matrix4x4::operator-= (Matrix4x4 const &m)
{
    data_[0U] -= m.data_[0U];
    data_[1U] -= m.data_[1U];
    data_[2U] -= m.data_[2U];
    data_[3U] -= m.data_[3U];
    return *this;
}

[[maybe_unused]] Vector4D const &Matrix4x4::operator[] (int i) const
{
    return data_[i];
}

[[maybe_unused]] Vector4D &Matrix4x4::operator[] (int i)
{
    return data_[i];
}

[[maybe_unused]] float Matrix4x4::Det2x2(float a1, float a2, float b1, float b2)
{
    return a1 * b2 - b1 * a2;
}

[[maybe_unused]] float Matrix4x4::Det3x3(float a1, float a2, float a3, float b1, float b2, float b3, float c1, float c2,
    float c3)
{
    return a1 * Det2x2(b2, b3, c2, c3) - b1 * Det2x2(a2, a3, c2, c3) + c1 * Det2x2(a2, a3, b2, b3);
}

[[maybe_unused]] Matrix4x4 operator+ (Matrix4x4 const &a, Matrix4x4 const &b)
{
    Matrix4x4 c(a);
    c += b;
    return c;
}

[[maybe_unused]] Matrix4x4 operator- (Matrix4x4 const &a, Matrix4x4 const &b)
{
    Matrix4x4 c(a);
    c -= b;
    return c;
}

[[maybe_unused]] bool operator== (Matrix4x4 const &a, Matrix4x4 const &b)
{
    return memcmp(&a, &b, sizeof(Matrix4x4)) == 0;
}

[[maybe_unused]] bool operator!= (Matrix4x4 const &a, Matrix4x4 const &b)
{
    return memcmp(&a, &b, sizeof(Matrix4x4)) != 0;
}

Matrix4x4 operator* (Matrix4x4 const &a, Matrix4x4 const &b)
{
    auto const &aData = a.data_;
    auto const &a0 = aData[0U];
    auto const &a1 = aData[1U];
    auto const &a2 = aData[2U];
    auto const &a3 = aData[3U];

    auto const &bData = b.data_;
    auto const &b0 = bData[0U];
    auto const &b1 = bData[1U];
    auto const &b2 = bData[2U];
    auto const &b3 = bData[3U];

    Matrix4x4 c;
    auto &cData = c.data_;
    auto &c0 = cData[0U];
    auto &c1 = cData[1U];
    auto &c2 = cData[2U];
    auto &c3 = cData[3U];

    c0.x_ = a0.x_ * b0.x_ + a1.x_ * b0.y_ + a2.x_ * b0.z_ + a3.x_ * b0.w_;
    c0.y_ = a0.y_ * b0.x_ + a1.y_ * b0.y_ + a2.y_ * b0.z_ + a3.y_ * b0.w_;
    c0.z_ = a0.z_ * b0.x_ + a1.z_ * b0.y_ + a2.z_ * b0.z_ + a3.z_ * b0.w_;
    c0.w_ = a0.w_ * b0.x_ + a1.w_ * b0.y_ + a2.w_ * b0.z_ + a3.w_ * b0.w_;
    c1.x_ = a0.x_ * b1.x_ + a1.x_ * b1.y_ + a2.x_ * b1.z_ + a3.x_ * b1.w_;
    c1.y_ = a0.y_ * b1.x_ + a1.y_ * b1.y_ + a2.y_ * b1.z_ + a3.y_ * b1.w_;
    c1.z_ = a0.z_ * b1.x_ + a1.z_ * b1.y_ + a2.z_ * b1.z_ + a3.z_ * b1.w_;
    c1.w_ = a0.w_ * b1.x_ + a1.w_ * b1.y_ + a2.w_ * b1.z_ + a3.w_ * b1.w_;
    c2.x_ = a0.x_ * b2.x_ + a1.x_ * b2.y_ + a2.x_ * b2.z_ + a3.x_ * b2.w_;
    c2.y_ = a0.y_ * b2.x_ + a1.y_ * b2.y_ + a2.y_ * b2.z_ + a3.y_ * b2.w_;
    c2.z_ = a0.z_ * b2.x_ + a1.z_ * b2.y_ + a2.z_ * b2.z_ + a3.z_ * b2.w_;
    c2.w_ = a0.w_ * b2.x_ + a1.w_ * b2.y_ + a2.w_ * b2.z_ + a3.w_ * b2.w_;
    c3.x_ = a0.x_ * b3.x_ + a1.x_ * b3.y_ + a2.x_ * b3.z_ + a3.x_ * b3.w_;
    c3.y_ = a0.y_ * b3.x_ + a1.y_ * b3.y_ + a2.y_ * b3.z_ + a3.y_ * b3.w_;
    c3.z_ = a0.z_ * b3.x_ + a1.z_ * b3.y_ + a2.z_ * b3.z_ + a3.z_ * b3.w_;
    c3.w_ = a0.w_ * b3.x_ + a1.w_ * b3.y_ + a2.w_ * b3.z_ + a3.w_ * b3.w_;

    return c;
}

} // namespace OpenGTX
