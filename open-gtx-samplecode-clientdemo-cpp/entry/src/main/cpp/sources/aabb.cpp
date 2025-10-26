#include <aabb.hpp>

namespace OpenGTX {

void AABB::AddVertex(Vector3D const &vertex) noexcept
{
    AddVertex(vertex.x_, vertex.y_, vertex.z_);
}

void AABB::AddVertex(float x, float y, float z) noexcept
{
    if (vertices_ > 1U) {
        if (min_.x_ > x) {
            min_.x_ = x;
        } else if (max_.x_ < x) {
            max_.x_ = x;
        }

        if (min_.y_ > y) {
            min_.y_ = y;
        } else if (max_.y_ < y) {
            max_.y_ = y;
        }

        if (min_.z_ > z) {
            min_.z_ = z;
        } else if (max_.z_ < z) {
            max_.z_ = z;
        }

        return;
    }

    if (vertices_ == 0U) {
        ++vertices_;
        min_ = Vector3D(x, y, z);
        return;
    }

    ++vertices_;

    if (min_.x_ > x) {
        max_.x_ = min_.x_;
        min_.x_ = x;
    } else {
        max_.x_ = x;
    }

    if (min_.y_ > y) {
        max_.y_ = min_.y_;
        min_.y_ = y;
    } else {
        max_.y_ = y;
    }

    if (min_.z_ > z) {
        max_.z_ = min_.z_;
        min_.z_ = z;
    } else {
        max_.z_ = z;
    }
}

void AABB::Empty() noexcept
{
    max_ = VOID_MAX;
    min_ = VOID_MIN;
    vertices_ = 0U;
}

void AABB::Transform(AABB &bounds, Matrix4x4 const &transform) const noexcept
{
    Vector3D const verticesLocal[8U] =
    {
        Vector3D(min_.x_, min_.y_, min_.z_),
        Vector3D(max_.x_, min_.y_, min_.z_),
        Vector3D(max_.x_, min_.y_, max_.z_),
        Vector3D(min_.x_, min_.y_, max_.z_),
        Vector3D(min_.x_, max_.y_, min_.z_),
        Vector3D(max_.x_, max_.y_, min_.z_),
        Vector3D(max_.x_, max_.y_, max_.z_),
        Vector3D(min_.x_, max_.y_, max_.z_)
    };
    
    bounds.Empty();

    for (auto const &v : verticesLocal) {
        bounds.AddVertex(transform.TransformAsPoint(v));
    }
}

} // namespace OpenGTX
