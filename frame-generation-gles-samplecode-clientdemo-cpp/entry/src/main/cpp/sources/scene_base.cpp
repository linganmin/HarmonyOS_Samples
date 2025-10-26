/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <scene_base.hpp>
#include <log.hpp>
#include <utility>

namespace FrameGeneration {
namespace {
constexpr GLsizei BIG = 1560;
constexpr GLsizei LITTLE = 720;
constexpr uint32_t NUMBER_THREE = 3;

constexpr char const g_vs[] =
    R"__(#version 320 es

const highp vec2            g_NDC[3U] = vec2[3U](
    vec2(-1.0F, -1.0F),
    vec2(3.0F, -1.0F),
    vec2(-1.0F, 3.0F)
);

out smooth highp vec2       a_UV;

void main()
{
    highp vec2 ndc = g_NDC[gl_VertexID];
    gl_Position = vec4(ndc, 0.0F, 1.0F);

    const highp vec2 factor = vec2(0.5F, 0.5F);
    a_UV = fma(ndc, factor, factor);
}
)__";

constexpr char const g_fs[] =
    R"__(#version 320 es

#define TEXTURE_UNIT    0

in smooth highp vec2                                a_UV;
layout(binding = TEXTURE_UNIT) uniform sampler2D    g_Image;
layout(location = 0) out lowp vec4                  o_Color;

void main()
{
    o_Color = vec4(texture(g_Image, a_UV).xyz, 1.0F);
}
)__";
} // end of anonymous namespace

bool SceneBase::OnContextCreated(Renderer &renderer) noexcept
{
    predictionEnabled_ = true;
    predictionPaused_ = true;

    guiTimer_.RestartTimer();
    sceneTimer_.RestartTimer();

    frameCount_ = 0U;
    fpsTick_ = 0.0F;

    renderer_ = &renderer;

    if (program_ = Renderer::CreateGraphicProgram(g_vs, g_fs); program_ == Renderer::INVALID_VALUE) {
        return false;
    }

    glDepthFunc(GL_LESS);
    CheckOpenGLError();

    glFrontFace(GL_CW);
    CheckOpenGLError();

    glCullFace(GL_BACK);
    CheckOpenGLError();

    glDisable(GL_SCISSOR_TEST);
    CheckOpenGLError();

    glDisable(GL_STENCIL_TEST);
    CheckOpenGLError();

    glClearDepthf(1.0F);
    CheckOpenGLError();

    glGenSamplers(1, &sampler_);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_COMPARE_MODE, GL_NONE);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_COMPARE_FUNC, GL_NEVER);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    CheckOpenGLError();

    return gui_.Init();
}

void SceneBase::DeleteTexturesAndFramebuffers() noexcept
{
    GLuint const t[] = {
        scene_.texture_,
        scene_.depthTexture_,
        predictedFrame_
    };

    glDeleteTextures(static_cast<GLsizei>(std::size(t)), t);
    CheckOpenGLError();

    glDeleteFramebuffers(1, &scene_.fbo_);
    CheckOpenGLError();
}

void SceneBase::OnContextDestroyed() noexcept
{
    gui_.Destroy();

    if (program_) {
        glDeleteProgram(program_);
        CheckOpenGLError();
        program_ = 0U;
    }

    if (sampler_) {
        glDeleteSamplers(1, &sampler_);
        CheckOpenGLError();
        sampler_ = 0U;
    }

    if (!scene_.fbo_) {
        return;
    }

    DeleteTexturesAndFramebuffers();
}

bool SceneBase::OnSwapchainCreated() noexcept
{
    auto const & si = renderer_->GetSurfaceInfo();

    if ((canvasW_ == si.width) & (canvasH_ == si.height)) {
        return true;
    }

    if (scene_.fbo_) {
        DeleteTexturesAndFramebuffers();
    }

    constexpr std::pair<GLsizei, GLsizei> const cases[] = {
        std::make_pair(LITTLE, BIG),
        std::make_pair(BIG, LITTLE)
    };

    auto const [w, h] = cases[static_cast<size_t>(si.width > si.height)];
    scene_ = Renderer::CreateFBO(GL_RGBA8, w, h);
    predictedFrame_ = Renderer::CreateTexture(GL_RGBA8, w, h, 1U);

    camera_.Init(si.fAspectRatio);
    gui_.OnSwapchainChanged(si.width, si.height);
    return true;
}

void SceneBase::HandleFPS(float deltaTime) noexcept
{
    fpsTick_ += deltaTime;
    ++frameCount_;

    if (fpsTick_ < FPS_PERIOD) {
        return;
    }

    float const realFPS = static_cast<float>(frameCount_) / FPS_PERIOD;

    if (predictionEnabled_ & !predictionPaused_) {
        GOLOGI("SceneBase::HandleFPS - Real FPS is %g, Full FPS is %g", realFPS, 2.0F * realFPS);
    } else {
        GOLOGI("SceneBase::HandleFPS - No prediction. Full FPS is %g", realFPS);
    }

    frameCount_ = 0U;
    fpsTick_ = 0.0F;
}

void SceneBase::BlitToDisplay(GLuint scene) const noexcept
{
    glUseProgram(program_);
    CheckOpenGLError();

    glDisable(GL_DEPTH_TEST);
    CheckOpenGLError();

    glDisable(GL_STENCIL_TEST);
    CheckOpenGLError();

    glDisable(GL_CULL_FACE);
    CheckOpenGLError();

    glDepthMask(GL_FALSE);
    CheckOpenGLError();

    glStencilMask(0U);
    CheckOpenGLError();

    renderer_->BindEmptyVAO();

    Renderer::BindTexture(scene);
    glBindSampler(TEXTURE_UNIT, sampler_);
    CheckOpenGLError();

    glDrawArrays(GL_TRIANGLES, 0, NUMBER_THREE);
    CheckOpenGLError();
}

FG_ResolutionInfo SceneBase::GetResolutionInfo() noexcept
{
    FG_Dimension2D inputColorResolution{};
    inputColorResolution.width = scene_.fboWidth_;
    inputColorResolution.height = scene_.fboHeight_;
    FG_Dimension2D inputDepthStencilResolution{};
    inputDepthStencilResolution.width = scene_.fboWidth_;
    inputDepthStencilResolution.height = scene_.fboHeight_;
    FG_Dimension2D outputColorResolution{};
    outputColorResolution.width = scene_.fboWidth_;
    outputColorResolution.height = scene_.fboHeight_;
    FG_ResolutionInfo rInfo{};
    rInfo.inputColorResolution = inputColorResolution;
    rInfo.inputDepthStencilResolution = inputDepthStencilResolution;
    rInfo.outputColorResolution = outputColorResolution;

    return rInfo;
}

bool SceneBase::DefaultCall(FG_ResolutionInfo &rInfo) noexcept
{
    dispatchDescriptionData_.inputColor = scene_.texture_;
    dispatchDescriptionData_.inputDepthStencil = scene_.depthTexture_;
    dispatchDescriptionData_.outputColor = predictedFrame_;

    FG_ErrorCode errorCode = HMS_FG_SetResolution_GLES(context_, &rInfo);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetResolution_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    errorCode = HMS_FG_SetCvvZSemantic_GLES(context_, FG_CVV_Z_SEMANTIC_MINUS_ONE_TO_ONE_FORWARD_Z);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetCvvZSemantic_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    errorCode = HMS_FG_SetImageFormat_GLES(context_, FG_FORMAT_R8G8B8A8_UNORM);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_SetImageFormat_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    // Activate Frame Generation instance
    errorCode = HMS_FG_Activate_GLES(context_);
    if (errorCode != FG_SUCCESS) {
        GOLOGE("HMS_FG_Activate_GLES execution failed, error code: %d.", errorCode);
        return false;
    }

    return FG_SUCCESS;
}

void SceneBase::SetExtendedCameraInfo() noexcept
{
    perFrameExtendedCameraInfo_.proj = *reinterpret_cast<FG_Mat4x4 const *>(&lastProj_);
    perFrameExtendedCameraInfo_.translatedView = *reinterpret_cast<FG_Mat4x4 const *>(&lastTranslatedView_);
    Matrix4x4 translatedViewProj = lastProj_ * lastTranslatedView_;
    perFrameExtendedCameraInfo_.translatedViewProj = *reinterpret_cast<FG_Mat4x4 const *>(&translatedViewProj);
    Matrix4x4 translatedInvViewProj;
    Matrix4x4 invView{};
    translatedInvViewProj = invView.Invert(translatedViewProj);
    perFrameExtendedCameraInfo_.translatedInvViewProj = *reinterpret_cast<FG_Mat4x4 const *>(&translatedInvViewProj);
    perFrameExtendedCameraInfo_.worldPosition = *reinterpret_cast<FG_Vec3D const *>(&lastPosition_);
}
} // namespace FrameGeneration
