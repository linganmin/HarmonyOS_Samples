/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <scene_abr.hpp>
#include <stencil_ids.hpp>
#include "log.hpp"

namespace AdaptiveBufferResolution {
bool SceneAdaptiveBufferResolution::OnContextCreated(Renderer &renderer) noexcept
{
    return SceneBase::OnContextCreated(renderer) && opaqueLayer_.Init();
}

void SceneAdaptiveBufferResolution::OnContextDestroyed() noexcept
{
    opaqueLayer_.Destroy();
    SceneBase::OnContextDestroyed();
}

bool SceneAdaptiveBufferResolution::OnDisablePrediction() noexcept
{
    predictionEnabled_ = false;

    if (predictionPaused_) {
        return true;
    }
    // Deactivate AdaptiveBufferResolution instance
    ABR_ErrorCode errorCode = HMS_ABR_Deactivate(context_);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_Deactivate execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode == ABR_SUCCESS);

    return predictionPaused_;
}

bool SceneAdaptiveBufferResolution::OnEnablePrediction() noexcept
{
    predictionEnabled_ = true;

    if (!predictionPaused_) {
        return true;
    }
    // Activate AdaptiveBufferResolution instance
    ABR_ErrorCode errorCode = HMS_ABR_Activate(context_);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_FG_Activate execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode != ABR_SUCCESS);

    return !predictionPaused_;
}

bool SceneAdaptiveBufferResolution::OnFrame() noexcept
{
    // Showing real frame...
    UpdateAndRenderOpaqueScene(scene_);
    BlitToDisplay(scene_.texture_);

    float guiDelta = guiTimer_.DiffTime();
    guiTimer_.RestartTimer();
    gui_.Draw(*renderer_, guiDelta);

    renderer_->Present();

    if (!predictionEnabled_ || predictionPaused_) {
        return false;
    }

    return true;
}

bool SceneAdaptiveBufferResolution::OnSwapchainCreated() noexcept
{
    if (!SceneBase::OnSwapchainCreated()) {
        return false;
    }

    auto const & si = renderer_->GetSurfaceInfo();

    if ((canvasW_ == si.width) && (canvasH_ == si.height)) {
        if ((context_ == nullptr) || !predictionPaused_) {
            return true;
        }
        // Activate AdaptiveBufferResolution instance
        ABR_ErrorCode errorCode = HMS_ABR_Activate(context_);
        if (errorCode != ABR_SUCCESS) {
            GOLOGE("HMS_ABR_Activate execution failed, error code: %d.", errorCode);
        }
        predictionPaused_ = (errorCode != ABR_SUCCESS);

        return !predictionPaused_;
    }

    // It's needed to invalidate image dataset if swapchain has been recreated.
    realFrameCollected_ = false;

    if (context_ == nullptr) {
        // Creates a AdaptiveBufferResolution context instance
        context_ = HMS_ABR_CreateContext(RENDER_API_GLES);
    }

    // Configure AdaptiveBufferResolution context instance for initialing
    ABR_ErrorCode errorCode = HMS_ABR_SetTargetFps(context_, 120);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_SetTargetFps execution failed, error code: %d.", errorCode);
        return false;
    }
    errorCode = HMS_ABR_SetScaleRange(context_, 0.5f, 1.0f);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_SetScaleRange execution failed, error code: %d.", errorCode);
        return false;
    }

    // Activate AdaptiveBufferResolution instance
    errorCode = HMS_ABR_Activate(context_);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_Activate execution failed, error code: %d.", errorCode);
        return false;
    }
    predictionPaused_ = (errorCode != ABR_SUCCESS);

    if (predictionPaused_) {
        return false;
    }

    canvasW_ = si.width;
    canvasH_ = si.height;
    return true;
}

bool SceneAdaptiveBufferResolution::OnSwapchainDestroyed() noexcept
{
    if (predictionPaused_) {
        return true;
    }
    // Destroy AdaptiveBufferResolution instance and memory resource reclamation
    ABR_ErrorCode errorCode = HMS_ABR_DestroyContext(&context_);
    predictionPaused_ = (errorCode == ABR_SUCCESS);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_ContextDestroy execution failed, error code: %d.", errorCode);
        return false;
    }

    return predictionPaused_;
}

void SceneAdaptiveBufferResolution::PreSetting(float sceneDelta)
{
    camera_.Update(sceneDelta);
    HandleFPS(sceneDelta);

    glDepthMask(GL_TRUE);
    CheckOpenGLError();

    glStencilMask(std::numeric_limits<GLuint>::max());
    CheckOpenGLError();

    glClearStencil(STENCIL_SKYBOX);
    CheckOpenGLError();

    lastViewProj_ = camera_.GetViewProjectionMatrix();
    lastView_ = camera_.GetViewMatrix();
    lastProj_ = camera_.GetProjectionMatrix();
}

void SceneAdaptiveBufferResolution::UpdateAndRenderOpaqueScene(FBO const &fbo) noexcept
{
    float const sceneDelta = sceneTimer_.DiffTime();
    sceneTimer_.RestartTimer();
    
    PreSetting(sceneDelta);

    bool isActive;
    ABR_ErrorCode errorCode = HMS_ABR_IsActive(context_, &isActive);
    if (errorCode != ABR_SUCCESS) {
        GOLOGE("HMS_ABR_IsActive execution failed, error code: %d.", errorCode);
        return;
    }
    if (isActive) {
        ABR_CameraData cameraData;
        cameraData.position = static_cast<ABR_Vector3>(camera_.GetPosition());
        cameraData.rotation = static_cast<ABR_Vector3>(camera_.GetRotation());
        errorCode = HMS_ABR_UpdateCameraData(context_, &cameraData);
        if (errorCode != ABR_SUCCESS) {
            GOLOGE("HMS_ABR_UpdateCameraData execution failed, error code: %d.", errorCode);
            return;
        }

        float scale = 1.0f;
        errorCode = HMS_ABR_GetScale(context_, &scale);
        if (errorCode != ABR_SUCCESS) {
            GOLOGE("HMS_ABR_GetScale execution failed, error code: %d.", errorCode);
            return;
        }
        if (currentScale_ != scale) {
            GOLOGI("Scale from %f to %f.", currentScale_, scale);
            currentScale_ = scale;
        }
    }

    renderer_->BeginRenderTarget(fbo, BACKGROUND.x_, BACKGROUND.y_, BACKGROUND.z_, 1.0F);

    if (isActive) {
        errorCode = HMS_ABR_MarkFrameBuffer_GLES(context_);
        if (errorCode != ABR_SUCCESS) {
            GOLOGE("HMS_ABR_MarkFrameBuffer_GLES execution failed, error code: %d.", errorCode);
            return;
        }
    }

    // use 'scale' variable to update render parameters if necessary
    opaqueLayer_.Render(sceneDelta, camera_.GetViewMatrix(), lastViewProj_);

    renderer_->EndRenderTarget();
}
} // namespace AdaptiveBufferResolution
