/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef NATIVE_MESH_HPP
#define NATIVE_MESH_HPP

#include "vector2d.hpp"
#include "vector3d.hpp"

namespace FrameGeneration {
#pragma pack(push)
#pragma pack(1)

struct NativeMeshHeader final {
    uint32_t totalVertices_;
    uint64_t vboOffset_;
};

struct VertexInfo final {
    [[maybe_unused]] Vector3D vertex_;
    [[maybe_unused]] Vector2D uv_;
    [[maybe_unused]] Vector3D normal_;
    [[maybe_unused]] Vector3D tangent_;
    [[maybe_unused]] Vector3D bitangent_;
};

#pragma pack(pop)
} // namespace FrameGeneration

#endif // NATIVE_MESH_HPP
