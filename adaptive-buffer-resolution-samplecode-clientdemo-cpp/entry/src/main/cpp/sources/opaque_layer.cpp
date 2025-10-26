/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <opaque_layer.hpp>
#include <projection_clip_planes.hpp>

namespace AdaptiveBufferResolution {
namespace {
constexpr char const g_vs[] =
    R"__(#version 320 es

#define VERTICES            0
#define UVS                 1
#define NORMALS             2
#define TANGENTS            3
#define BITANGENTS          4

#define TRANSFORM           0
#define NORMAL_TRANSFORM    1

layout(location = VERTICES) in highp vec3                   v_Vertex;
layout(location = UVS) in highp vec2                        v_UV;
layout(location = NORMALS) in highp vec3                    v_Normal;
layout(location = TANGENTS) in highp vec3                   v_Tangent;
layout(location = BITANGENTS) in highp vec3                 v_Bitangent;

layout(location = TRANSFORM) uniform highp mat4             g_Transform;
layout(location = NORMAL_TRANSFORM) uniform highp mat4      g_NormalTransform;

out smooth highp vec2                                       a_UV;
out smooth highp vec3                                       a_FragmentView;
out smooth highp vec3                                       a_NormalView;
out smooth highp vec3                                       a_TangentView;
out smooth highp vec3                                       a_BitangentView;

void main()
{
    a_FragmentView = (g_NormalTransform * vec4(v_Vertex, 1.0F)).xyz;
    highp mat3 n = mat3(g_NormalTransform);

    a_NormalView = n * v_Normal;
    a_TangentView = n * v_Tangent;
    a_BitangentView = n * v_Bitangent;

    a_UV = v_UV;
    gl_Position = g_Transform * vec4(v_Vertex, 1.0F);
}
)__";

constexpr char const g_fs[] =
    R"__(#version 320 es

#define DIFFUSE_UNIT                    0
#define NORMAL_UNIT                     1

#define AMBIENT_LIGHT_COLOR             2
#define SPOT_LIGHT_COLOR                3
#define SPOT_LIGHT_LOCATION             4
#define MATERIAL_COLOR                  5

in smooth highp vec2                                            a_UV;
in smooth highp vec3                                            a_FragmentView;
in smooth highp vec3                                            a_NormalView;
in smooth highp vec3                                            a_TangentView;
in smooth highp vec3                                            a_BitangentView;

layout(binding = DIFFUSE_UNIT) uniform lowp sampler2D           g_Diffuse;
layout(binding = NORMAL_UNIT) uniform lowp sampler2D            g_Normal;

layout(location = AMBIENT_LIGHT_COLOR) uniform highp vec3       g_AmbientLightColor;
layout(location = SPOT_LIGHT_COLOR) uniform highp vec3          g_SpotLightColor;
layout(location = SPOT_LIGHT_LOCATION) uniform highp vec3       g_SpotLightLocation;

highp float TARGET_SHININESS = 128.0F;

layout(location = 0) out lowp vec4                              o_Color;

mediump vec3 GetFinalNormalView(in mediump vec3 tangentView, in mediump vec3 bitangentView, in mediump vec3 normalView,
    in highp vec2 flippedUV)
{
    mediump vec3 normalData = fma(texture(g_Normal, flippedUV).xyz, vec3(2.0F), vec3(-1.0F));
    mediump mat3 tbnView = mat3(tangentView, bitangentView, normalView);
    return normalize(tbnView * normalData);
}

mediump float GetSpecular(in mediump vec3 finalNormalView, in mediump vec3 toViewerView, in mediump vec3 toLightView,
    in mediump float shininess)
{
    // See https://en.wikipedia.org/wiki/Blinn%E2%80%93Phong_reflection_model

    mediump vec3 halfVector = normalize(toViewerView + toLightView);
    mediump float angleFactor = max(0.0F, dot(halfVector, finalNormalView));
    return pow(angleFactor, shininess);
}

void main()
{
    highp vec2 flippedUV = vec2(a_UV.x, 1.0 - a_UV.y);
    mediump vec3 diffuseData = texture(g_Diffuse, flippedUV).xyz;
    mediump vec3 normalView = GetFinalNormalView(a_TangentView, a_BitangentView, a_NormalView, flippedUV);

    mediump vec3 toView = -normalize(a_FragmentView);
    mediump float lambertian = max(0.0F, dot(toView, normalView));

    mediump vec3 toLight = normalize(g_SpotLightLocation - a_FragmentView);
    mediump vec3 specularFactor = g_SpotLightColor * GetSpecular(normalView, toView, toLight, TARGET_SHININESS);

    o_Color = vec4(g_AmbientLightColor + fma(diffuseData, vec3(lambertian), specularFactor), 1.0F);
}
)__";
} // end of anomynous namespace

void OpaqueLayer::Instance::UpdateTransform(GPUInstance &gpuInstance, Matrix4x4 const &view,
    Matrix4x4 const &viewProj, float deltaTime) noexcept
{
    angle_ += deltaTime * ROTATION_SPEED;

    FromAxisAngle(ROTATION_AXIS, angle_);

    transform_.FromQuaternion(data_);

    auto &xAxis = *reinterpret_cast<Vector3D *>(transform_.data_);
    auto &yAxis = *reinterpret_cast<Vector3D *>(transform_.data_ + 1U);
    auto &zAxis = *reinterpret_cast<Vector3D *>(transform_.data_ + 2U);

    xAxis *= SCALE;
    yAxis *= SCALE;
    zAxis *= SCALE;

    auto &loc = *reinterpret_cast<Vector3D *>(&transform_.data_[3U]);

    constexpr float wavelength = 1.0F / DENSITY;
    loc = location_;
    loc.y_ = WAVE_HEIGHT * std::sin(wavelength * angle_);

    gpuInstance.normalTransform_ = view * transform_;
    gpuInstance.transform_ = viewProj * transform_;
}

void OpaqueLayer::Culler::Execute(Matrix4x4 const &view, Matrix4x4 const &viewProj, float deltaTime) noexcept
{
    {
        // Note: operator block is needed because of std::unique_lock.
        std::unique_lock<std::mutex> const lock(mutex_);
        view_ = view;
        viewProj_ = viewProj;
        deltaTime_ = deltaTime;
        ready_ = true;
    }

    cond_.notify_one();
}

void OpaqueLayer::Culler::FillResult(std::span<GPUInstance> &instances) noexcept
{
    std::unique_lock lock(mutex_);

    cond_.wait(lock, [&]() noexcept -> bool { return proceed_; });

    std::memcpy(instances.data(), visible_.data(), instances_ * sizeof(GPUInstance));
    instances = instances.subspan(instances_);

    proceed_ = false;
}

void OpaqueLayer::Culler::Join() noexcept
{
    if (!thread_.joinable()) {
        return;
    }

    {
        // Note: operator block is needed because of std::unique_lock.
        std::unique_lock<std::mutex> const lock(mutex_);
        loop_ = false;
        ready_ = true;
    }

    cond_.notify_one();
    thread_.join();
}

void OpaqueLayer::Destroy() noexcept
{
    for (auto &culler : cullers_) {
        culler.Join();
    }

    OpaqueLayerBase::Destroy();
}

auto OpaqueLayer::CullBody(std::reference_wrapper<Culler> culler, AABB const &bounds,
    std::span<Instance> &&instances) noexcept
{
    Culler &c = culler.get();

    auto &cond = c.cond_;
    auto &mutex = c.mutex_;

    bool const &loop = c.loop_;
    bool &ready = c.ready_;
    bool &proceed = c.proceed_;

    auto &insts = c.instances_;
    auto &visible = c.visible_;

    Matrix4x4 const &view = c.view_;
    Matrix4x4 const &viewProj = c.viewProj_;
    float const &deltatime = c.deltaTime_;
    Matrix4x4 worldToLocal{};

    while (loop) {
        {
            // Note: operator block is needed because of std::unique_lock.
            std::unique_lock<std::mutex> lock(mutex);

            cond.wait(lock, [&]() noexcept -> bool { return ready; });

            size_t idx = 0U;
            ProjectionClipPlanes frustum_{};
            frustum_.From(viewProj);

            for (auto &instance : instances) {
                GPUInstance &v = visible[idx];
                instance.UpdateTransform(v, view, viewProj, deltatime);

                AABB boundWorld{};
                bounds.Transform(boundWorld, instance.transform_);

                if (!frustum_.IsVisible(boundWorld)) {
                    continue;
                }

                worldToLocal.Invert(instance.transform_);
                ++idx;
            }

            insts = idx;
            proceed = true;
            ready = false;
        }

        cond.notify_one();
    }
}

bool OpaqueLayer::Init() noexcept
{
    AABB bounds{};

    if (!OpaqueLayer::InitBase(bounds)) {
        return false;
    }

    size_t index = 0U;

    for (auto &instance : instances_) {
        auto const a = static_cast<float>(index % INSTANCE_SQRT);

        // NOLINTNEXTLINE - lost precision because float cast.
        auto const b = static_cast<float>(index / INSTANCE_SQRT);

        constexpr float distance = DENSITY * DEFAULT_DISTANCE;
        constexpr float offset = -0.5F * distance * static_cast<float>(INSTANCE_SQRT);

        instance.angle_ = static_cast<float>(index);
        instance.location_ = Vector3D(offset + distance * a, 0.0F, offset + distance * b);
        ++index;
    }

    size_t batch = INSTANCE_COUNT / CULLERS;
    size_t offset = 0U;
    constexpr size_t limit = CULLERS - 1U;

    for (size_t i = 0U; i < limit; ++i) {
        Culler &culler = cullers_[i];
        culler.loop_ = true;

        culler.thread_ = std::thread([this, &culler, bounds, offset, batch]() {
            this->CullBody(std::ref(culler), bounds, std::span<Instance>(instances_ + offset, batch));
        });

        offset += batch;
    }

    Culler &culler = cullers_[limit];
    culler.loop_ = true;

    culler.thread_ = std::thread([this, &culler, bounds, offset]() {
        this->CullBody(std::ref(culler), bounds, std::span<Instance>(instances_ + offset, INSTANCE_COUNT - offset));
    });

    return true;
}

void OpaqueLayer::Render(float deltaTime, Matrix4x4 const &view, Matrix4x4 const &viewProj) noexcept
{
    for (auto &culler : cullers_) {
        culler.Execute(view, viewProj, deltaTime);
    }

    SetCommonRenderState(view);
    std::span<GPUInstance> instances(gpuInstances_, INSTANCE_COUNT);

    for (auto &culler : cullers_) {
        culler.FillResult(instances);
    }

    size_t const cases[] = {
        static_cast<size_t>(instances.data() - gpuInstances_),
        INSTANCE_COUNT
    };

    size_t const insts = cases[static_cast<size_t>(instances.empty())];

    for (auto const &asset : assets_) {
        glBindVertexArray(asset.vao_);
        CheckOpenGLError();

        Renderer::BindTexture(asset.diffuse_, DIFFUSE_UNIT);
        Renderer::BindTexture(asset.normal_, NORMAL_UNIT);

        for (size_t i = 0U; i < insts; ++i) {
            GPUInstance const &gpuInstance = gpuInstances_[i];

            glStencilFunc(GL_ALWAYS, gpuInstance.stencil_, std::numeric_limits<GLuint>::max());
            CheckOpenGLError();

            glUniformMatrix4fv(TRANSFORM, 1U, GL_FALSE, gpuInstance.transform_.Data());
            CheckOpenGLError();

            glUniformMatrix4fv(NORMAL_TRANSFORM, 1U, GL_FALSE, gpuInstance.normalTransform_.Data());
            CheckOpenGLError();

            glDrawArrays(GL_TRIANGLES, 0, asset.vertices_);
            CheckOpenGLError();
        }
    }
}

bool OpaqueLayer::CreateProgram(GLuint &program) const noexcept
{
    program = Renderer::CreateGraphicProgram(g_vs, g_fs);
    return program != Renderer::INVALID_VALUE;
}

void OpaqueLayer::Instance::FromAxisAngle(Vector3D const &axis, float angle) noexcept
{
    float const halfAngle = 0.5F * angle;
    float const sinom = std::sin(halfAngle);

    data_[0U] = axis.x_ * sinom;
    data_[1U] = axis.y_ * sinom;
    data_[2U] = axis.z_ * sinom;
    data_[3U] = std::cos(halfAngle);
}
} // namespace AdaptiveBufferResolution
