/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef CAMERA_HPP
#define CAMERA_HPP

#include <matrix4x4.hpp>

namespace AdaptiveBufferResolution {
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
    [[nodiscard]] Vector3D const & GetPosition() const noexcept;
    [[nodiscard]] Vector3D const & GetRotation() const noexcept;
    [[nodiscard]] float const & GetX() const noexcept;
    [[nodiscard]] float const & GetY() const noexcept;
    [[nodiscard]] float const & GetZ() const noexcept;

    void Init(float aspectRatio) noexcept;
    void Update(float deltaTime) noexcept;

private:
    float slider_ = 0.0F;
    Vector3D rotationAxis0_{};
    Vector3D rotationAxis1_{};
    Matrix4x4 proj_{};
    Matrix4x4 view_{};
    Matrix4x4 viewProj_{};
    Vector3D position_;
    Vector3D rotation_;
    float x_;
    float y_;
    float z_;
};
} // namespace AdaptiveBufferResolution

#endif // CAMERA_HPP
