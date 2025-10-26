/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef SCENE_EXTRAPOLATION_HPP
#define SCENE_EXTRAPOLATION_HPP

#include "opaque_layer.hpp"
#include "scene_base.hpp"

namespace FrameGeneration {
class SceneExtrapolation : public SceneBase {
public:
    SceneExtrapolation() = default;

    SceneExtrapolation(SceneExtrapolation const &) = delete;
    SceneExtrapolation &operator = (SceneExtrapolation const &) = delete;

    SceneExtrapolation(SceneExtrapolation &&) = delete;
    SceneExtrapolation &operator = (SceneExtrapolation &&) = delete;

    ~SceneExtrapolation() override = default;

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
};
} // namespace FrameGeneration

#endif // SCENE__EXTRAPOLATION_HPP
