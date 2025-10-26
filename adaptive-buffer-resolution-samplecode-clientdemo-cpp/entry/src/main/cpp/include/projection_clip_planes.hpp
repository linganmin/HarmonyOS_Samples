/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef PROJECTION_CLIP_PLANES_HPP
#define PROJECTION_CLIP_PLANES_HPP

#include "aabb.hpp"

namespace AdaptiveBufferResolution {
class ProjectionClipPlanes final {
public:
    ProjectionClipPlanes() = default;

    ProjectionClipPlanes(ProjectionClipPlanes const &) = default;
    ProjectionClipPlanes &operator = (ProjectionClipPlanes const &) = default;

    ProjectionClipPlanes(ProjectionClipPlanes &&) = default;
    ProjectionClipPlanes &operator = (ProjectionClipPlanes &&) = default;

    ~ProjectionClipPlanes() = default;

    void From(Matrix4x4 const & src) noexcept;
    [[nodiscard]] bool IsVisible(AABB const & bounds) const noexcept;

private:
    struct Plane final {
        float a_ = 0.0F;
        float b_ = 0.0F;
        float c_ = 0.0F;
        float d_ = 0.0F;
    };

    enum class Classify : uint8_t {
        IN_FRONT = 0U,
        ON = 1U,
        BEHIND = 2U
    };

    [[nodiscard]] uint8_t PlaneTest(float x, float y, float z) const noexcept;
    [[nodiscard]] static Classify ClassifyVertex(Plane const & plane, float x, float y, float z) noexcept;

    Plane planes_[6U]{};
};
} // namespace AdaptiveBufferResolution

#endif // PROJECTION_CLIP_PLANES_HPP
