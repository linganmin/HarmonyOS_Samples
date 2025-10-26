#include <gui.hpp>
#include <core.hpp>

namespace OpenGTX {

namespace {

constexpr float LOGO_TRANSPARENCY = 0.9F;
constexpr float LOGO_WIDTH = 2.4F;

constexpr float ZNEAR = -1.0F;
constexpr float ZFAR = 1.0F;

constexpr float PADDING_BOTTOM = 3.0e-1F;
constexpr float PADDING_LEFT = 3.0e-1F;
constexpr float PADDING_RIGHT = 3.0e-1F;

constexpr float SAVING_TEXT_WIDTH = 1.25F;

constexpr float SPINNER_PADDING_BOTTOM = 5.0e-2F;
constexpr float SPINNER_PADDING_RIGHT = 1.0e-1F;
constexpr float SPINNER_SPEED = 3.0F;
constexpr float SPINNER_WIDTH = 3.0e-1F;

constexpr char const g_vs[] =
R"__(#version 320 es

#define TRANSFORM       0

layout(location = TRANSFORM) uniform highp mat4     g_Transform;

const highp vec4 VERTS[4U] = vec4[](
    vec4(-0.5F, -0.5F, 0.0F, 0.0F),
    vec4(0.5F, -0.5F, 1.0F, 0.0F),
    vec4(-0.5F, 0.5F, 0.0F, 1.0F),
    vec4(0.5F, 0.5F, 1.0F, 1.0F)
);

out smooth highp vec2                               a_UV;

void main()
{
    highp vec4 v = VERTS[gl_VertexID];

    a_UV = v.zw;
    gl_Position = g_Transform * vec4(v.xy, 0.0F, 1.0F);
}
)__";

constexpr char const g_fs[] =
R"__(#version 320 es

#define TEXTURE_UNIT    0
#define TRANSPARENCY    1

in smooth highp vec2                                        a_UV;

layout(binding = TEXTURE_UNIT) uniform lowp sampler2D       g_Radar;
layout(location = TRANSPARENCY) uniform highp float         g_Transparency;

layout(location = 0) out lowp vec4                          o_Color;

void main()
{
    highp vec2 flippedUV = vec2(a_UV.x, 1.0 - a_UV.y);
    highp vec4 s = texture(g_Radar, flippedUV);
    s.w *= g_Transparency;
    o_Color = s;
}
)__";

} // end of anonymous namespace

bool GUI::Init() noexcept
{
    program_ = Renderer::CreateGraphicProgram(g_vs, g_fs);

    if (program_ == Renderer::INVALID_VALUE) {
        return false;
    }

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

    return logo_.Init("logo.png") && saving_.Init("gui-saving.png") && spinner_.Init("spinner.png") &&
        wantedLevel_.Init();
}

void GUI::Destroy() noexcept
{
    if (sampler_) {
        glDeleteSamplers(1, &sampler_);
        CheckOpenGLError();
        sampler_ = 0U;
    }

    if (program_) {
        glDeleteProgram(program_);
        CheckOpenGLError();
        program_ = 0U;
    }

    spinner_.Destroy();
    saving_.Destroy();
    logo_.Destroy();
    wantedLevel_.Destroy();
}

void GUI::Draw(Renderer &renderer, float deltaTime) noexcept
{
    spinnerOrientation_ += deltaTime * SPINNER_SPEED;
    constexpr float twoPI = 2.0F * static_cast<float>(M_PI);

    while (spinnerOrientation_ > twoPI) {
        spinnerOrientation_ -= twoPI;
    }

    spinner_.SetOrientation(spinnerOrientation_, proj_);

    glEnable(GL_BLEND);
    CheckOpenGLError();

    glBlendEquation(GL_FUNC_ADD);
    CheckOpenGLError();

    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ZERO, GL_ONE);
    CheckOpenGLError();

    glDisable(GL_DEPTH_TEST);
    CheckOpenGLError();

    glDisable(GL_SCISSOR_TEST);
    CheckOpenGLError();

    glDepthMask(GL_FALSE);
    CheckOpenGLError();

    glDisable(GL_CULL_FACE);
    CheckOpenGLError();

    renderer.BindEmptyVAO();

    wantedLevel_.Draw(deltaTime, sampler_);

    glUseProgram(program_);
    CheckOpenGLError();

    glBindSampler(TEXTURE_UNIT, sampler_);
    CheckOpenGLError();

    logo_.Draw();
    saving_.Draw();
    spinner_.Draw();
}

void GUI::OnSwapchainChanged(uint32_t width, uint32_t height) noexcept
{
    auto const canvasWidth = static_cast<float>(width);
    auto const canvasHeight = static_cast<float>(height);

    proj_.OrthoOpenGL(canvasWidth, canvasHeight, ZNEAR, ZFAR);
    float const pixelsPerCentimeter = Core::GetInstance()->PixelsPerCentimeter();

    logo_.SetWidth(static_cast<uint32_t>(pixelsPerCentimeter * LOGO_WIDTH));
    float h = logo_.GetHeight();

    logo_.SetLocation(-0.5F * canvasWidth + pixelsPerCentimeter * (PADDING_LEFT + LOGO_WIDTH * 0.5F),
        -0.5F * canvasHeight + h * 0.5F + pixelsPerCentimeter * PADDING_BOTTOM, proj_);

    logo_.SetTransparency(LOGO_TRANSPARENCY);

    saving_.SetWidth(static_cast<uint32_t>(pixelsPerCentimeter * SAVING_TEXT_WIDTH));
    h = saving_.GetHeight();

    float const savingAnchorX = 0.5F * canvasWidth - pixelsPerCentimeter * PADDING_RIGHT;
    float const savingAnchorY = -0.5F * canvasHeight + pixelsPerCentimeter * PADDING_BOTTOM;

    saving_.SetLocation(savingAnchorX - 0.5F * pixelsPerCentimeter * SAVING_TEXT_WIDTH,
        savingAnchorY + 0.5F * h, proj_);

    spinner_.SetWidth(static_cast<uint32_t>(pixelsPerCentimeter * SPINNER_WIDTH));
    h = spinner_.GetHeight();

    spinner_.SetLocation(savingAnchorX - pixelsPerCentimeter * (0.5F * SPINNER_WIDTH + SPINNER_PADDING_RIGHT),
        savingAnchorY + 0.5F * h + pixelsPerCentimeter * SPINNER_PADDING_BOTTOM, proj_);

    wantedLevel_.OnSwapchainChanged(pixelsPerCentimeter, proj_, width, height);
}

} // namespace OpenGTX
