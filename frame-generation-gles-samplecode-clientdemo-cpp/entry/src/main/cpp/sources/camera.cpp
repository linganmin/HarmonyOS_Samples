/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <camera.hpp>
#include <cmath>
#include <random>

namespace FrameGeneration {
namespace {
constexpr float FOVY = 60.0F;
constexpr float ZNEAR = 1.0e-1F;
constexpr float ZFAR = 1.0e+4F;
} // end of anonymous namespace

Matrix4x4 const & Camera::GetViewMatrix() const noexcept
{
    return view_;
}

Matrix4x4 const & Camera::GetProjectionMatrix() const noexcept
{
    return proj_;
}

Matrix4x4 const & Camera::GetViewProjectionMatrix() const noexcept
{
    return viewProj_;
}

Matrix4x4 const & Camera::GetTranslatedViewMatrix() const noexcept
{
    return translatedView_;
}

Vector3D Camera::GetWorldPosition() const noexcept
{
    Matrix4x4 invView{};
    invView = invView.Invert(view_);
    return Vector3D{invView[3][0], invView[3][1], invView[3][2]};
}

void Camera::Init(float aspectRatio) noexcept
{
    proj_.PerspectiveFovOpenGL(DEG2RAD * FOVY, aspectRatio, ZNEAR, ZFAR);

    std::random_device rd{};
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> dir(-1.0F, 1.0F);

    auto rollDice = [&]() noexcept -> Vector3D {
        Vector3D v(dir(gen), dir(gen), dir(gen));
        v.Normalize();

        if (!std::isnan(v.x_)) {
            return v;
        }

        v.x_ = 1.0F;
        v.y_ = dir(gen);
        v.z_ = dir(gen);
        v.Normalize();
        return v;
    };

    rotationAxis0_ = rollDice();
    rotationAxis1_ = rollDice();
}

void Camera::Update(float deltaTime) noexcept
{
    slider_ += deltaTime;

    Matrix4x4 rY(1.0f);
    Matrix4x4 rX(1.0f);
    Matrix4x4 t{};

    t.Translate(32.0F * std::cos(0.2F * slider_), 10.0F + 6.0F * std::sin(0.3F * slider_),
        32.0F * std::sin(0.2F * slider_));

    rY.RotateY(-0.2F * slider_);
    rX.RotateX(0.6F + 0.3F * std::sin(0.3F * slider_));
    
    translatedView_.Invert(rY * rX);
    view_.Invert(t * rY * rX);
    viewProj_ = proj_ * view_;
}
} // namespace FrameGeneration
