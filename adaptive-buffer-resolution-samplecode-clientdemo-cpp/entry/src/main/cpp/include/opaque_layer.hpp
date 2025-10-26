/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef OPAQUE_LAYER_HPP
#define OPAQUE_LAYER_HPP

#include "opaque_layer_base.hpp"
#include "stencil_ids.hpp"
#include <thread>

namespace AdaptiveBufferResolution {
class OpaqueLayer final : public OpaqueLayerBase {
public:
    OpaqueLayer() = default;

    OpaqueLayer(OpaqueLayer const &) = delete;
    OpaqueLayer &operator = (OpaqueLayer const &) = delete;

    OpaqueLayer(OpaqueLayer &&) = delete;
    OpaqueLayer &operator = (OpaqueLayer &&) = delete;

    ~OpaqueLayer() = default;

    void Destroy() noexcept override;

    [[nodiscard]] bool Init() noexcept;

    void Render(float deltaTime, Matrix4x4 const &view, Matrix4x4 const &viewProj) noexcept;

private:
    struct GPUInstance final {
        Matrix4x4 normalTransform_{};
        Matrix4x4 transform_{};
        GLint stencil_ = STENCIL_DYNAMIC_OBJECT;
    };

    class Instance final {
    public:
        Instance() = default;

        Instance(Instance const &) = delete;
        Instance &operator = (Instance const &) = delete;

        Instance(Instance &&) = delete;
        Instance &operator = (Instance &&) = delete;

        ~Instance() = default;

        void UpdateTransform(GPUInstance &gpuInstance, Matrix4x4 const &view, Matrix4x4 const &viewProj,
            float deltaTime) noexcept;
        void FromAxisAngle(Vector3D const &axis, float angle) noexcept;

        float angle_ = 0.0F;
        Vector3D location_{};
        Matrix4x4 transform_{};
        float data_[4U]{};
    };

    class Culler final {
    public:
        Culler() = default;

        Culler(Culler const &) = delete;
        Culler &operator = (Culler const &) = delete;

        Culler(Culler &&) = delete;
        Culler &operator = (Culler &&) = delete;

        ~Culler() = default;

        void Execute(Matrix4x4 const &view, Matrix4x4 const &viewProj, float deltaTime) noexcept;
        void FillResult(std::span<GPUInstance> &instances) noexcept;
        void Join() noexcept;

        float deltaTime_ = 0.0F;
        Matrix4x4 view_{};
        Matrix4x4 viewProj_{};
        size_t instances_ = 0U;
        std::array<GPUInstance, INSTANCE_COUNT / CULLERS + CULLERS> visible_{};

        bool loop_ = true;
        bool proceed_ = false;
        bool ready_ = false;

        std::condition_variable cond_{};
        std::mutex mutex_{};
        std::thread thread_{};
    };

    constexpr static GLint TRANSFORM = 0;
    constexpr static GLint NORMAL_TRANSFORM = 1;

    [[nodiscard]] bool CreateProgram(GLuint &program) const noexcept override;

    auto CullBody(std::reference_wrapper<Culler> culler, AABB const &bounds, std::span<Instance> &&instances) noexcept;

    Culler cullers_[CULLERS] = {};
    GPUInstance gpuInstances_[INSTANCE_COUNT] = {};
    Instance instances_[INSTANCE_COUNT] = {};
};
} // namespace AdaptiveBufferResolution

#endif // OPAQUE_LAYER_HPP
