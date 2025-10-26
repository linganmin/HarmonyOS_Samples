/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef SCENE_INTERPOLATION_HPP
#define SCENE_INTERPOLATION_HPP

#include "opaque_layer.hpp"
#include "scene_base.hpp"

namespace AdaptiveBufferResolution {
class SceneAdaptiveBufferResolution final : public SceneBase {
public:
    SceneAdaptiveBufferResolution() = default;

    SceneAdaptiveBufferResolution(SceneAdaptiveBufferResolution const &) = delete;
    SceneAdaptiveBufferResolution &operator = (SceneAdaptiveBufferResolution const &) = delete;

    SceneAdaptiveBufferResolution(SceneAdaptiveBufferResolution &&) = delete;
    SceneAdaptiveBufferResolution &operator = (SceneAdaptiveBufferResolution &&) = delete;

    ~SceneAdaptiveBufferResolution() override = default;

private:
    [[nodiscard]] bool OnContextCreated(Renderer &renderer) noexcept override;
    void OnContextDestroyed() noexcept override;
    [[nodiscard]] bool OnDisablePrediction() noexcept override;
    [[nodiscard]] bool OnEnablePrediction() noexcept override;
    [[nodiscard]] bool OnFrame() noexcept override;
    [[nodiscard]] bool OnSwapchainCreated() noexcept override;
    [[nodiscard]] bool OnSwapchainDestroyed() noexcept override;

    void UpdateAndRenderOpaqueScene(FBO const & fbo) noexcept;
    void PreSetting(float sceneDelta);

    OpaqueLayer opaqueLayer_{};
    bool realFrameCollected_ = false;
};
} // namespace AdaptiveBufferResolution

#endif // SCENE_INTERPOLATION_HPP
