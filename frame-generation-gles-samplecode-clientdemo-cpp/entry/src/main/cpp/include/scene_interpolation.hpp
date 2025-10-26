/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef SCENE_INTERPOLATION_HPP
#define SCENE_INTERPOLATION_HPP

#include "opaque_layer.hpp"
#include "scene_base.hpp"

namespace FrameGeneration {
class SceneInterpolation : public SceneBase {
public:
    SceneInterpolation() = default;

    SceneInterpolation(SceneInterpolation const &) = delete;
    SceneInterpolation &operator = (SceneInterpolation const &) = delete;

    SceneInterpolation(SceneInterpolation &&) = delete;
    SceneInterpolation &operator = (SceneInterpolation &&) = delete;

    ~SceneInterpolation() override = default;

private:
    [[nodiscard]] bool OnContextCreated(Renderer &renderer) noexcept override;
    void OnContextDestroyed() noexcept override;
    [[nodiscard]] bool OnDisablePrediction() noexcept override;
    [[nodiscard]] bool OnEnablePrediction() noexcept override;
    [[nodiscard]] bool OnFrame() noexcept override;
    [[nodiscard]] bool OnSwapchainCreated() noexcept override;
    [[nodiscard]] bool OnSwapchainDestroyed() noexcept override;

    void UpdateAndRenderOpaqueScene(FBO const & fbo) noexcept;

    OpaqueLayer opaqueLayer_{};
    bool realFrameCollected_ = false;
};
} // namespace FrameGeneration

#endif // SCENE__INTERPOLATION_HPP
