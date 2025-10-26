/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef SCENE_BASE_HPP
#define SCENE_BASE_HPP

#include "camera.hpp"
#include "gui.hpp"
#include "timer.hpp"
#include "renderer.hpp"
#include <graphics_game_sdk/frame_generation_gles.h>

namespace FrameGeneration {
class SceneBase {
public:
    SceneBase() = default;

    SceneBase(SceneBase const &) = delete;
    SceneBase &operator = (SceneBase const &) = delete;

    SceneBase(SceneBase &&) = delete;
    SceneBase &operator = (SceneBase &&) = delete;

    virtual ~SceneBase() = default;

    [[nodiscard]] virtual bool OnContextCreated(Renderer &renderer) noexcept;
    virtual void OnContextDestroyed() noexcept;

    [[nodiscard]] virtual bool OnDisablePrediction() noexcept = 0;
    [[nodiscard]] virtual bool OnEnablePrediction() noexcept = 0;
    [[nodiscard]] virtual bool OnFrame() noexcept = 0;
    [[nodiscard]] virtual bool OnSwapchainCreated() noexcept;
    [[nodiscard]] virtual bool OnSwapchainDestroyed() noexcept = 0;

    [[nodiscard]] FG_ResolutionInfo GetResolutionInfo() noexcept;
    [[nodiscard]] bool DefaultCall(FG_ResolutionInfo &rInfo) noexcept;
    [[maybe_unused]] void SetExtendedCameraInfo() noexcept;

protected:
    constexpr static Vector3D BACKGROUND{};
    constexpr static float FPS_PERIOD = 3.0F;
    constexpr static GLuint TEXTURE_UNIT = 0U;

    void HandleFPS(float deltaTime) noexcept;
    void BlitToDisplay(GLuint scene) const noexcept;
    void DeleteTexturesAndFramebuffers() noexcept;
    // Main switch to enable/disable prediction.
    bool predictionEnabled_ = true;

    // Last known prediction state.
    bool predictionPaused_ = true;

    size_t frameCount_ = 0U;
    float fpsTick_ = 0.0F;

    Camera camera_{};
    Timer testTimer_{};
    uint32_t canvasW_ = 0U;
    uint32_t canvasH_ = 0U;

    GUI gui_{};
    Timer guiTimer_{};

    FG_Context_GLES *context_ = nullptr;

    GLuint program_ = 0U;
    Renderer *renderer_ = nullptr;
    GLuint sampler_ = 0U;

    FBO scene_{};
    Timer sceneTimer_{};

    Matrix4x4 lastViewProj_{};
    Matrix4x4 lastView_{};
    Matrix4x4 lastProj_{};
    Matrix4x4 lastTranslatedView_{};
    Vector3D lastPosition_{};

    GLuint predictedFrame_ = 0U;

    FG_DispatchDescription_GLES dispatchDescriptionData_{
        .inputColor = 0U,
        .inputDepthStencil = 0U,
        .viewProj{},
        .invViewProj{},
        .outputColor = 0U
    };

    FG_PerFrameExtendedCameraInfo perFrameExtendedCameraInfo_{
        .proj{},
        .translatedInvViewProj{},
        .translatedView{},
        .translatedViewProj{},
        .worldPosition{}
    };
};
} // namespace FrameGeneration

#endif // SCENE_BASE_HPP
