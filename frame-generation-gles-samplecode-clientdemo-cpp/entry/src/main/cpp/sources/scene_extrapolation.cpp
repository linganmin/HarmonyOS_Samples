/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "log.hpp"
#include <scene_extrapolation.hpp>
#include <stencil_ids.hpp>

namespace FrameGeneration {
bool SceneExtrapolation::OnContextCreated(Renderer &renderer) noexcept
{
    return SceneBase::OnContextCreated(renderer) && opaqueLayer_.Init();
}

void SceneExtrapolation::OnContextDestroyed() noexcept
{
    opaqueLayer_.Destroy();
    SceneBase::OnContextDestroyed();
}

bool SceneExtrapolation::OnDisablePrediction() noexcept
{
    predictionEnabled_ = false;

    if (predictionPaused_) {
        return true;
    }
    // Deactivate Frame Generation instance
    FG_ErrorCode errorCode = HMS_FG_Deactivate_GLES(context_);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_Deactivate_GLES execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode == FG_SUCCESS);
    return predictionPaused_;
}

bool SceneExtrapolation::OnEnablePrediction() noexcept
{
    predictionEnabled_ = true;

    if (!predictionPaused_) {
        return true;
    }
    // Activate Frame Generation instance
    FG_ErrorCode errorCode = HMS_FG_Activate_GLES(context_);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_Activate_GLES execution failed, error code: %d.", errorCode);
    }
    predictionPaused_ = (errorCode != FG_SUCCESS);

    return !predictionPaused_;
}

bool SceneExtrapolation::OnFrame() noexcept
{
    // Showing real frame...
    UpdateAndRenderOpaqueScene(scene_);
    BlitToDisplay(scene_.texture_);

    float guiDelta = guiTimer_.DiffTime();
    guiTimer_.RestartTimer();
    gui_.Draw(*renderer_, guiDelta);

    renderer_->Present();

    if (!predictionEnabled_ || predictionPaused_) {
        return true;
    }

    SetExtendedCameraInfo();
    /*
     * Provide the extended camera information in cases where the translation component of
     * view-projection matrices may be very large, in order to get more precise predicted effects.
     * Small scenario or small distance between camera and origin, don't need to call this API.
     */
    FG_ErrorCode errorCode = HMS_FG_SetExtendedCameraInfo_GLES(context_, &perFrameExtendedCameraInfo_);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetExtendedCameraInfo_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    dispatchDescriptionData_.viewProj = *reinterpret_cast<FG_Mat4x4 const *>(&lastViewProj_);
    Matrix4x4 invViewProj{};
    dispatchDescriptionData_.invViewProj =
        *reinterpret_cast<FG_Mat4x4 const *>(invViewProj.Invert(lastViewProj_).data_);

    // Defines Frame Generation dispatch info struct which specifies the required attributes to predict frames
    errorCode = HMS_FG_Dispatch_GLES(context_, &dispatchDescriptionData_);

    switch (errorCode) {
        case FG_SUCCESS: {
            BlitToDisplay(predictedFrame_);

            guiDelta = guiTimer_.DiffTime();
            guiTimer_.RestartTimer();
            gui_.Draw(*renderer_, guiDelta);

            renderer_->Present();
            break;
        }

        case FG_COLLECTING_PREVIOUS_FRAMES:
            //  Expected frame data has not been collected yet, it should not be used for display.
            break;

        default:
            GOLOGE("HMS_FG_Dispatch_GLES execution failed, error code: %d.", errorCode);
            return false;
    }

    return true;
}

bool SceneExtrapolation::OnSwapchainCreated() noexcept
{
    if (!SceneBase::OnSwapchainCreated()) {
        return false;
    }

    auto const & si = renderer_->GetSurfaceInfo();

    if ((canvasW_ == si.width) && (canvasH_ == si.height)) {
        if ((context_ == nullptr) || !predictionPaused_) {
            return true;
        }
        // Activate Frame Generation instance
        FG_ErrorCode errorCode = HMS_FG_Activate_GLES(context_);
        if (errorCode != FG_SUCCESS) {
            GOLOGE("HMS_FG_Activate_GLES execution failed, error code: %d.", errorCode);
        }
        predictionPaused_ = (errorCode != FG_SUCCESS);

        return !predictionPaused_;
    }

    if (context_ == nullptr) {
        // Creates a frame generation context instance
        context_ = HMS_FG_CreateContext_GLES();
    }

    dispatchDescriptionData_.inputColor = scene_.texture_;
    dispatchDescriptionData_.inputDepthStencil = scene_.depthTexture_;
    dispatchDescriptionData_.outputColor = predictedFrame_;

    FG_AlgorithmModeInfo aInfo{};
    aInfo.predictionMode = FG_PREDICTION_MODE_EXTRAPOLATION;
    aInfo.meMode = FG_ME_MODE_BASIC;
    FG_ErrorCode errorCode = HMS_FG_SetAlgorithmMode_GLES(context_, &aInfo);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetAlgorithmMode_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    FG_ResolutionInfo rInfo = GetResolutionInfo();
    predictionPaused_ = (DefaultCall(rInfo) != FG_SUCCESS);
    if (predictionPaused_) {
        return false;
    }

    if (!opaqueLayer_.InitGLProgram()) {
        return false;
    }

    canvasW_ = si.width;
    canvasH_ = si.height;
    return true;
}

bool SceneExtrapolation::OnSwapchainDestroyed() noexcept
{
    if (predictionPaused_) {
        return true;
    }
    // Destroy Frame Generation instance and memory resource reclamation
    FG_ErrorCode errorCode = HMS_FG_DestroyContext_GLES(&context_);
    predictionPaused_ = (errorCode == FG_SUCCESS);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_DestroyContext_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    return predictionPaused_;
}

void SceneExtrapolation::UpdateAndRenderOpaqueScene(FBO const & fbo) noexcept
{
    float const sceneDelta = sceneTimer_.DiffTime();
    sceneTimer_.RestartTimer();

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
    lastPosition_ = camera_.GetWorldPosition();
    lastTranslatedView_ = camera_.GetTranslatedViewMatrix();

    renderer_->BeginRenderTarget(fbo, BACKGROUND.x_, BACKGROUND.y_, BACKGROUND.z_, 1.0F);
    opaqueLayer_.Render(sceneDelta, camera_.GetViewMatrix(), lastViewProj_);
    renderer_->EndRenderTarget();
}
} // namespace FrameGeneration
