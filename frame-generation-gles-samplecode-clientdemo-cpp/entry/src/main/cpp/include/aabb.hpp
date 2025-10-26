/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef AABB_HPP
#define AABB_HPP

#include "matrix4x4.hpp"
#include <cstdint>

namespace FrameGeneration {
struct AABB final {
    constexpr AABB() noexcept : max_(VOID_MAX), min_(VOID_MIN), vertices_(0U) {}

    AABB(AABB const &) = default;
    AABB &operator = (AABB const &) = default;

    AABB(AABB &&) = default;
    AABB &operator = (AABB &&) = default;

    ~AABB() = default;

    void AddVertex(Vector3D const & vertex) noexcept;
    void AddVertex(float x, float y, float z) noexcept;
    void Empty() noexcept;
    void Transform(AABB &bounds, Matrix4x4 const & transform) const noexcept;

    Vector3D max_;
    Vector3D min_;
    uint8_t vertices_;

private:
    constexpr static float M = std::numeric_limits<float>::max();
    constexpr static Vector3D VOID_MAX{ -M, -M, -M };
    constexpr static Vector3D VOID_MIN{ M, M, M };
};
} // namespace FrameGeneration

#endif // AABB_HPP
