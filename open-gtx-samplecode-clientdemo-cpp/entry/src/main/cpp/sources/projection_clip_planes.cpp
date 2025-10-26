#include <projection_clip_planes.hpp>
#include <array>

namespace OpenGTX {

void ProjectionClipPlanes::From(Matrix4x4 const &src) noexcept
{
    // Left clipping plane
    planes_[0U].a_ = src.data_[0U].w_ + src.data_[0U].x_;
    planes_[0U].b_ = src.data_[1U].w_ + src.data_[1U].x_;
    planes_[0U].c_ = src.data_[2U].w_ + src.data_[2U].x_;
    planes_[0U].d_ = src.data_[3U].w_ + src.data_[3U].x_;

    // Right clipping plane
    planes_[1U].a_ = src.data_[0U].w_ - src.data_[0U].x_;
    planes_[1U].b_ = src.data_[1U].w_ - src.data_[1U].x_;
    planes_[1U].c_ = src.data_[2U].w_ - src.data_[2U].x_;
    planes_[1U].d_ = src.data_[3U].w_ - src.data_[3U].x_;

    // Top clipping plane
    planes_[2U].a_ = src.data_[0U].w_ - src.data_[0U].y_;
    planes_[2U].b_ = src.data_[1U].w_ - src.data_[1U].y_;
    planes_[2U].c_ = src.data_[2U].w_ - src.data_[2U].y_;
    planes_[2U].d_ = src.data_[3U].w_ - src.data_[3U].y_;

    // Bottom clipping plane
    planes_[3U].a_ = src.data_[0U].w_ + src.data_[0U].y_;
    planes_[3U].b_ = src.data_[1U].w_ + src.data_[1U].y_;
    planes_[3U].c_ = src.data_[2U].w_ + src.data_[2U].y_;
    planes_[3U].d_ = src.data_[3U].w_ + src.data_[3U].y_;

    // Near clipping plane
    planes_[4U].a_ = src.data_[0U].w_ + src.data_[0U].z_;
    planes_[4U].b_ = src.data_[1U].w_ + src.data_[1U].z_;
    planes_[4U].c_ = src.data_[2U].w_ + src.data_[2U].z_;
    planes_[4U].d_ = src.data_[3U].w_ + src.data_[3U].z_;

    // Far clipping plane
    planes_[5U].a_ = src.data_[0U].w_ - src.data_[0U].z_;
    planes_[5U].b_ = src.data_[1U].w_ - src.data_[1U].z_;
    planes_[5U].c_ = src.data_[2U].w_ - src.data_[2U].z_;
    planes_[5U].d_ = src.data_[3U].w_ - src.data_[3U].z_;
}

bool ProjectionClipPlanes::IsVisible(AABB const &bounds) const noexcept
{
    uint8_t flags = PlaneTest(bounds.min_.x_, bounds.min_.y_, bounds.min_.z_);
    flags &= PlaneTest(bounds.min_.x_, bounds.max_.y_, bounds.min_.z_);
    flags &= PlaneTest(bounds.max_.x_, bounds.max_.y_, bounds.min_.z_);
    flags &= PlaneTest(bounds.max_.x_, bounds.min_.y_, bounds.min_.z_);

    flags &= PlaneTest(bounds.min_.x_, bounds.min_.y_, bounds.max_.z_);
    flags &= PlaneTest(bounds.min_.x_, bounds.max_.y_, bounds.max_.z_);
    flags &= PlaneTest(bounds.max_.x_, bounds.max_.y_, bounds.max_.z_);
    flags &= PlaneTest(bounds.max_.x_, bounds.min_.y_, bounds.max_.z_);

    return flags == 0U;
}

uint8_t ProjectionClipPlanes::PlaneTest(float x, float y, float z) const noexcept
{
    // clang-format off

    constexpr uint8_t const masks[] =
    {
        0b00000001U,
        0b00000010U,
        0b00000100U,
        0b00001000U,
        0b00010000U,
        0b00100000U
    };

    // clang-format on

    uint8_t result = 0U;

    for (size_t i = 0U; i < std::size(masks); ++i) {
        if (ClassifyVertex(planes_[i], x, y, z) == Classify::BEHIND) {
            result |= masks[i];
        }
    }

    return result;
}

ProjectionClipPlanes::Classify ProjectionClipPlanes::ClassifyVertex(Plane const &plane, float x, float y,
    float z) noexcept
{
    float const test = plane.a_ * x + plane.b_ * y + plane.c_ * z + plane.d_;

    if (test < 0.0F) {
        return Classify::BEHIND;
    }

    return test > 0.0F ? Classify::IN_FRONT : Classify::ON;
}

} // namespace OpenGTX
