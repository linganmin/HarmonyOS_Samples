/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <scene_interpolation.hpp>
#include <stencil_ids.hpp>
#include "log.hpp"

namespace FrameGeneration {
bool SceneInterpolation::OnContextCreated(Renderer &renderer) noexcept
{
    return SceneBase::OnContextCreated(renderer) && opaqueLayer_.Init();
}

void SceneInterpolation::OnContextDestroyed() noexcept
{
    opaqueLayer_.Destroy();
    SceneBase::OnContextDestroyed();
}

bool SceneInterpolation::OnDisablePrediction() noexcept
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

bool SceneInterpolation::OnEnablePrediction() noexcept
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

bool SceneInterpolation::OnFrame() noexcept
{
    if (!realFrameCollected_) {
        // Rendering real frame and save result to image.
        UpdateAndRenderOpaqueScene(scene_);
    } else {
        realFrameCollected_ = false;
    }

    bool const runPrediction = predictionEnabled_ && !predictionPaused_;

    if (runPrediction) {
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
                // FrameGeneration SDK collect enough data and successfully predicted frame.
                // Presenting frame and GUI...
                BlitToDisplay(predictedFrame_);

                float const guiDelta = guiTimer_.DiffTime();
                guiTimer_.RestartTimer();
                gui_.Draw(*renderer_, guiDelta);

                renderer_->Present();
                break;
            }

            case FG_COLLECTING_PREVIOUS_FRAMES:
                // Expected frame data has not been collected yet, it should not be used for display.
                break;

            default:
                GOLOGE("HMS_FG_Dispatch_GLES execution failed, error code: %d.", errorCode);
                return false;
        }
    }

    // Presenting real frame...
    BlitToDisplay(scene_.texture_);

    float const guiDelta = guiTimer_.DiffTime();
    guiTimer_.RestartTimer();
    gui_.Draw(*renderer_, guiDelta);

    if (runPrediction) {
        UpdateAndRenderOpaqueScene(scene_);
        realFrameCollected_ = true;
    }

    renderer_->Present();
    return true;
}

bool SceneInterpolation::OnSwapchainCreated() noexcept
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

    // It's needed to invalidate image dataset if swapchain has been recreated.
    realFrameCollected_ = false;

    if (context_ == nullptr) {
        // Creates a frame generation context instance
        context_ = HMS_FG_CreateContext_GLES();
    }

    FG_AlgorithmModeInfo aInfo{};
    aInfo.predictionMode = FG_PREDICTION_MODE_INTERPOLATION;
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

bool SceneInterpolation::OnSwapchainDestroyed() noexcept
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

void SceneInterpolation::UpdateAndRenderOpaqueScene(FBO const & fbo) noexcept
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
