#include <scene_base.hpp>
#include <log.hpp>
#include <utility>


namespace OpenGTX {

namespace {

constexpr GLsizei BIG = 1920;
constexpr GLsizei LITTLE = 1080;

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

    // clang-format off
    GLuint const t[] =
    {
        scene_.texture_,
        scene_.depthTexture_,
        predictedFrame_
    };
    // clang-format on

    glDeleteTextures(static_cast<GLsizei>(std::size(t)), t);
    CheckOpenGLError();

    glDeleteFramebuffers(1, &scene_.fbo_);
    CheckOpenGLError();
}

bool SceneBase::OnSwapchainCreated() noexcept
{
    auto const &si = renderer_->GetSurfaceInfo();

    if ((canvasW_ == si.width) & (canvasH_ == si.height)) {
        return true;
    }

    if (scene_.fbo_) {
        // clang-format off
        GLuint const t[] =
        {
            scene_.texture_,
            scene_.depthTexture_,
            predictedFrame_
        };
        // clang-format on

        glDeleteTextures(static_cast<GLsizei>(std::size(t)), t);
        CheckOpenGLError();

        glDeleteFramebuffers(1, &scene_.fbo_);
        CheckOpenGLError();
    }

    // clang-format off
    constexpr std::pair<GLsizei, GLsizei> const cases[] =
    {
        std::make_pair(LITTLE, BIG),
        std::make_pair(BIG, LITTLE)
    };
    // clang-format on

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
	GOLOGI("SceneBase::HandleFPS - FPS is %g", realFPS);
	
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

    glDrawArrays(GL_TRIANGLES, 0, 3);
    CheckOpenGLError();
}

} // namespace OpenGTX
