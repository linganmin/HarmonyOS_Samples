/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <wanted_level.hpp>
#include <renderer.hpp>
#include <texture_loader.hpp>
#include <array>

namespace AdaptiveBufferResolution {
namespace {
constexpr float STAR_SIZE = 4.0e-1F;
constexpr float RIGHT_PADDING = 5.0e-1F;
constexpr float TOP_PADDING = 4.0e-1F;
constexpr float SPACING = 2.5e-2F;

constexpr float BLINK_TIMEOUT = 0.777F;
constexpr uint32_t NUMBER_FOUR = 4;

constexpr char const g_vs[] =
    R"__(#version 320 es

#define TRANSFORMS      0
#define STATES          5

layout(location = TRANSFORMS) uniform highp mat4    g_Transforms[5U];
layout(location = STATES) uniform highp ivec4       g_States[5U];

const highp vec4 VERTS[4U] = vec4[](
    vec4(-0.5F, -0.5F, 0.0F, 0.0F),
    vec4(0.5F, -0.5F, 1.0F, 0.0F),
    vec4(-0.5F, 0.5F, 0.0F, 1.0F),
    vec4(0.5F, 0.5F, 1.0F, 1.0F)
);

out smooth highp vec2                               a_UV;
out flat highp int                                  a_State;

void main()
{
    highp vec4 v = VERTS[gl_VertexID];

    a_State = g_States[gl_InstanceID].x;
    a_UV = v.zw;
    gl_Position = g_Transforms[gl_InstanceID] * vec4(v.xy, 0.0F, 1.0F);
}
)__";

constexpr char const g_fs[] =
    R"__(#version 320 es

#define ACTIVE_UNIT     0
#define PASSIVE_UNIT    1

in smooth highp vec2                                        a_UV;
in flat highp int                                           a_State;

layout(binding = ACTIVE_UNIT) uniform lowp sampler2D        g_Active;
layout(binding = PASSIVE_UNIT) uniform lowp sampler2D       g_Passive;

layout(location = 0) out lowp vec4                          o_Color;

void main()
{
    lowp vec4 s;
    highp vec2 flippedUV = vec2(a_UV.x, 1.0 - a_UV.y);
    if (a_State == ACTIVE_UNIT) {
        s = texture(g_Active, flippedUV);
    } else {
        s = texture(g_Passive, flippedUV);
    }

    o_Color = s;
}
)__";
} // end of anonymous namespace

void WantedLevel::State::Toggle() noexcept
{
    constexpr int32_t const cases[] = {1, 0};
    data_[0U] = cases[data_[0U]];
}

bool WantedLevel::Init() noexcept
{
    if (activeStar_ = TextureLoader::Load("active-star.png"); !activeStar_) {
        return false;
    }

    if (passiveStar_ = TextureLoader::Load("passive-star.png"); !passiveStar_) {
        return false;
    }

    if (program_ = Renderer::CreateGraphicProgram(g_vs, g_fs); program_ == Renderer::INVALID_VALUE) {
        return false;
    }

    return true;
}

void WantedLevel::Draw(float deltaTime, GLuint sampler) noexcept
{
    blink_ += deltaTime;

    glUseProgram(program_);
    CheckOpenGLError();

    if (blink_ > BLINK_TIMEOUT) {
        states_[0U].Toggle();
        states_[1U].Toggle();

        glUniform4iv(STATES, static_cast<GLsizei>(STARS), states_->data_);
        CheckOpenGLError();

        blink_ = 0.0F;
    }

    glBindSampler(ACTIVE_UNIT, sampler);
    CheckOpenGLError();

    glBindSampler(PASSIVE_UNIT, sampler);
    CheckOpenGLError();

    Renderer::BindTexture(activeStar_, ACTIVE_UNIT);
    Renderer::BindTexture(passiveStar_, PASSIVE_UNIT);

    glDrawArraysInstanced(GL_TRIANGLE_STRIP, 0, NUMBER_FOUR, static_cast<GLsizei>(STARS));
    CheckOpenGLError();
}

void WantedLevel::Destroy() noexcept
{
    GLsizei texCount = 0U;
    GLuint textures[2U];

    if (activeStar_) {
        textures[texCount++] = activeStar_;
        activeStar_ = 0U;
    }

    if (passiveStar_) {
        textures[texCount++] = passiveStar_;
        passiveStar_ = 0U;
    }

    if (texCount) {
        glDeleteTextures(texCount, textures);
        CheckOpenGLError();
    }

    if (program_) {
        glDeleteProgram(program_);
        CheckOpenGLError();
        program_ = 0U;
    }
}

void WantedLevel::OnSwapchainChanged(float pixelsInCentimeter, Matrix4x4 const & proj, uint32_t width,
    uint32_t height) noexcept
{
    constexpr float halfSize = STAR_SIZE * 0.5F;
    float const starSize = pixelsInCentimeter * STAR_SIZE;
    float const rightAnchor = 0.5F * static_cast<float>(width) - pixelsInCentimeter * (RIGHT_PADDING + halfSize);
    float const topAnchor = 0.5F * static_cast<float>(height) - pixelsInCentimeter * (TOP_PADDING + halfSize);
    float const offset = pixelsInCentimeter * (STAR_SIZE + SPACING);

    Matrix4x4 starLocal{};
    starLocal.Scale(starSize, starSize, 1.0F);

    Matrix4x4 transforms[STARS];

    for (size_t i = 0U; i < STARS; ++i) {
        starLocal.data_[3U] = Vector4D(rightAnchor - static_cast<float>(i) * offset, topAnchor, 0.0F, 1.0F);
        transforms[i] = proj * starLocal;
    }

    glUseProgram(program_);
    CheckOpenGLError();

    glUniformMatrix4fv(TRANSFORMS, static_cast<GLsizei>(std::size(transforms)), GL_FALSE,
        reinterpret_cast<float const *>(transforms));

    CheckOpenGLError();

    states_[0U].data_[0U] = 0;
    states_[1U].data_[0U] = 0;
    glUniform4iv(STATES, static_cast<GLsizei>(STARS), states_->data_);
    CheckOpenGLError();

    glUseProgram(0U);
    CheckOpenGLError();

    blink_ = 0.0F;
}
} // namespace AdaptiveBufferResolution
