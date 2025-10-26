#include <camera.hpp>
#include <cmath>
#include <random>

namespace OpenGTX {

namespace {

constexpr float FOVY = 60.0F;
constexpr float ZNEAR = 1.0e-1F;
constexpr float ZFAR = 1.0e+4F;

} // end of anonymous namespace
double custom_mod(double x, double y) { return x - y * std::floor(x / y); }

float Normalize(float num) {
    if (num >= 0) {
        return custom_mod(num, 360);
    } else {
        return custom_mod((num + 360), 360);
    }
}

Matrix4x4 const &Camera::GetViewMatrix() const noexcept
{
    return view_;
}

Matrix4x4 const &Camera::GetProjectionMatrix() const noexcept 
{
    return proj_; 
}

Matrix4x4 const &Camera::GetViewProjectionMatrix() const noexcept
{
    return viewProj_;
}

Vector3D const &Camera::GetPosition() const noexcept
{
    return position_;
};

Vector3D const &Camera::GetRotation() const noexcept
{
    return rotation_;
}

float const &Camera::GetX() const noexcept
{
    return x_;
}

float const &Camera::GetY() const noexcept
{
    return y_; 
}

float const &Camera::GetZ() const noexcept 
{ 
    return z_;
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

    Matrix4x4 rY{};
    Matrix4x4 rX{};
    Matrix4x4 t{};

    Vector3D translate(32.0F * std::cos(0.2F * slider_), 10.0F + 6.0F * std::sin(0.3F * slider_),
        32.0F * std::sin(0.2F * slider_));
    float y = -0.2F * slider_;
    float x = 0.6F + 0.3F * std::sin(0.3F * slider_);
    
    position_ = translate;
    y_ = Normalize(y);
    x_ = Normalize(x);
    rotation_ = Vector3D(x_,y_,z_);
    
    t.Translate(translate);
    rY.RotateY(y);
    rX.RotateX(x);

    view_.Invert(t * rY * rX);
    viewProj_ = proj_ * view_;
}

} // namespace OpenGTX
