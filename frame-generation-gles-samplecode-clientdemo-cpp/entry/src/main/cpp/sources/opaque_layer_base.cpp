/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <opaque_layer_base.hpp>
#include <native_mesh.hpp>
#include <texture_loader.hpp>

namespace FrameGeneration {
namespace {
constexpr OpaqueLayerBase::AssetDesc const ASSETS[] = {
    {
        .diffuse_ = "sp_Material.002_BaseColor.png",
        .mesh_ = "pirate_without_beard.mesh",
        .normal_ = "sp_Material.002_Normal.png"
    }
};

constexpr Vector3D AMBIENT(47.0F / 255.0F, 45.0F / 255.0F, 45.0F / 255.0F);
} // end of anomynous namespace

Asset::Content OpaqueLayerBase::AssetInfo::GetContent(AssetDesc const &desc) noexcept
{
    if (diffuse_ = TextureLoader::Load(desc.diffuse_); !diffuse_) {
        return std::nullopt;
    }

    if (normal_ = TextureLoader::Load(desc.normal_); !normal_) {
        return std::nullopt;
    }

    Asset::Content const content = Asset::Load(desc.mesh_);
    if (!content) {
        return std::nullopt;
    }

    return content;
}

bool OpaqueLayerBase::AssetInfo::Init(AssetDesc const &desc) noexcept
{
    Asset::Content const content = GetContent(desc);
    if (!content) {
        return false;
    }

    uint8_t const * data = content->data();
    auto const &header = *reinterpret_cast<NativeMeshHeader const *>(data);
    vertices_ = static_cast<GLsizei>(header.totalVertices_);

    glGenVertexArrays(1, &vao_);
    CheckOpenGLError();

    glBindVertexArray(vao_);
    CheckOpenGLError();

    glGenBuffers(1, &vbo_);
    CheckOpenGLError();

    glBindBuffer(GL_ARRAY_BUFFER, vbo_);
    CheckOpenGLError();

    auto const *verts = reinterpret_cast<VertexInfo const *>(data + header.vboOffset_);

    glBufferData(GL_ARRAY_BUFFER, static_cast<GLsizeiptr>(header.totalVertices_ * sizeof(VertexInfo)), verts,
        GL_STATIC_DRAW);

    CheckOpenGLError();

#define FRAMEGENERATION_BIND(slot, count, field)                                                     \
    glEnableVertexAttribArray(slot);                                                                 \
    CheckOpenGLError();                                                                              \
                                                                                                     \
    glVertexAttribPointer(slot, count, GL_FLOAT, GL_FALSE, static_cast<GLsizei>(sizeof(VertexInfo)), \
        reinterpret_cast<void *>(offsetof(VertexInfo, field)));                                      \
                                                                                                     \
    CheckOpenGLError()

    FRAMEGENERATION_BIND(VERTICES, 3, vertex_);
    FRAMEGENERATION_BIND(UVS, 2, uv_);
    FRAMEGENERATION_BIND(NORMALS, 3, normal_);
    FRAMEGENERATION_BIND(TANGENTS, 3, tangent_);
    FRAMEGENERATION_BIND(BITANGENTS, 3, bitangent_);

#undef FRAMEGENERATION_BIND

    glBindVertexArray(0U);
    CheckOpenGLError();

    glBindBuffer(GL_ARRAY_BUFFER, 0U);
    CheckOpenGLError();

    bounds_.Empty();

    for (uint32_t i = 0U; i < header.totalVertices_; ++i) {
        VertexInfo const &v = verts[i];
        bounds_.AddVertex(v.vertex_);
    }

    return true;
}

void OpaqueLayerBase::AssetInfo::AppendDestroyResources(std::span<GLuint> &textures, size_t &pushTexIdx,
    std::span<GLuint> &vaos, size_t &pushVAOIdx, std::span<GLuint> &vbos, size_t &pushVBOIdx) noexcept
{
    if (diffuse_) {
        textures[pushTexIdx++] = diffuse_;
    }

    if (normal_) {
        textures[pushTexIdx++] = normal_;
    }

    if (vao_) {
        vaos[pushVAOIdx++] = vao_;
    }

    if (vbo_) {
        vbos[pushVBOIdx++] = vbo_;
    }

    diffuse_ = 0U;
    normal_ = 0U;
    vao_ = 0U;
    vbo_ = 0U;
}

void OpaqueLayerBase::Destroy() noexcept
{
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

    GLuint textureStorage[ASSET_COUNT * 2U];
    size_t pushTexIdx = 0U;
    std::span<GLuint> textures = textureStorage;

    GLuint vaoStorage[ASSET_COUNT];
    size_t pushVAOIdx = 0U;
    std::span<GLuint> vaos = vaoStorage;

    GLuint bufferStorage[ASSET_COUNT + 1U];
    size_t pushBufferIdx = 0U;
    std::span<GLuint> buffers = bufferStorage;

    for (auto &asset : assets_) {
        asset.AppendDestroyResources(textures, pushTexIdx, vaos, pushVAOIdx, buffers, pushBufferIdx);
    }

    if (pushTexIdx) {
        glDeleteTextures(static_cast<GLsizei>(pushTexIdx), textureStorage);
        CheckOpenGLError();
    }

    if (pushVAOIdx) {
        glDeleteVertexArrays(static_cast<GLsizei>(pushVAOIdx), vaoStorage);
        CheckOpenGLError();
    }

    if (pushBufferIdx) {
        glDeleteBuffers(static_cast<GLsizei>(pushBufferIdx), bufferStorage);
        CheckOpenGLError();
    }
}

bool OpaqueLayerBase::InitBase(AABB &geometryBounds) noexcept
{
    geometryBounds.Empty();

    for (size_t i = 0U; i < ASSET_COUNT; ++i) {
        AssetInfo &asset = assets_[i];

        if (!asset.Init(ASSETS[i])) {
            return false;
        }

        geometryBounds.AddVertex(asset.bounds_.min_);
        geometryBounds.AddVertex(asset.bounds_.max_);
    }

    geometryBounds.min_ *= SCALE;
    geometryBounds.max_ *= SCALE;

    return true;
}

bool OpaqueLayerBase::InitGLProgram() noexcept
{
    if (program_ != 0) {
        return true;
    }

    glGenSamplers(1, &sampler_);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_S, GL_REPEAT);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_R, GL_REPEAT);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_WRAP_T, GL_REPEAT);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_COMPARE_MODE, GL_NONE);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_COMPARE_FUNC, GL_NEVER);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    CheckOpenGLError();

    glSamplerParameteri(sampler_, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    CheckOpenGLError();

    if (!CreateProgram(program_)) {
        return false;
    }

    glUseProgram(program_);
    CheckOpenGLError();

    glUniform3fv(AMBIENT_LIGHT_COLOR, 1, reinterpret_cast<float const *>(&AMBIENT));
    CheckOpenGLError();

    glUniform3f(SPOT_LIGHT_COLOR, 1.0F, 1.0F, 1.0F);
    CheckOpenGLError();

    glUseProgram(0U);
    CheckOpenGLError();
    return true;
}

void OpaqueLayerBase::SetCommonRenderState(Matrix4x4 const &view) const noexcept
{
    glEnable(GL_DEPTH_TEST);
    CheckOpenGLError();

    glEnable(GL_STENCIL_TEST);
    CheckOpenGLError();

    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
    CheckOpenGLError();

    glEnable(GL_CULL_FACE);
    CheckOpenGLError();

    glDisable(GL_BLEND);
    CheckOpenGLError();

    glUseProgram(program_);
    CheckOpenGLError();

    glBindSampler(DIFFUSE_UNIT, sampler_);
    CheckOpenGLError();

    glBindSampler(NORMAL_UNIT, sampler_);
    CheckOpenGLError();

    Vector3D const spotLightLocationView = view.TransformAsPoint(SPOT_LIGHT_LOCATION_WORLD);
    glUniform3fv(SPOT_LIGHT_LOCATION, 1, reinterpret_cast<float const *>(&spotLightLocationView));
    CheckOpenGLError();
}
} // namespace FrameGeneration
