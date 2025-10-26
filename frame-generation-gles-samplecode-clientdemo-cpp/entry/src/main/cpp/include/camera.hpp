/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef CAMERA_HPP
#define CAMERA_HPP

#include <matrix4x4.hpp>

namespace FrameGeneration {
class Camera final {
public:
    Camera() = default;

    Camera(Camera const &) = delete;
    Camera &operator = (Camera const &) = delete;

    Camera(Camera &&) = delete;
    Camera &operator = (Camera &&) = delete;

    ~Camera() = default;

    [[nodiscard]] Matrix4x4 const & GetViewMatrix() const noexcept;
    [[nodiscard]] Matrix4x4 const & GetProjectionMatrix() const noexcept;
    [[nodiscard]] Matrix4x4 const & GetViewProjectionMatrix() const noexcept;
    Matrix4x4 const & GetTranslatedViewMatrix() const noexcept;
    [[nodiscard]] Vector3D GetWorldPosition() const noexcept;

    void Init(float aspectRatio) noexcept;
    void Update(float deltaTime) noexcept;

private:
    float slider_ = 0.0F;
    Vector3D rotationAxis0_{};
    Vector3D rotationAxis1_{};
    Matrix4x4 proj_{};
    Matrix4x4 view_{};
    Matrix4x4 viewProj_{};
    Matrix4x4 translatedView_{};
};
} // namespace FrameGeneration

#endif // CAMERA_HPP
