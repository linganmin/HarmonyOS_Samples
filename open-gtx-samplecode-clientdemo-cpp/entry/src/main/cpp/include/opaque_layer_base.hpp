#ifndef OPAQUE_LAYER_BASE_HPP
#define OPAQUE_LAYER_BASE_HPP

#include "aabb.hpp"
#include "renderer.hpp"
#include <span>

namespace OpenGTX {

class OpaqueLayerBase {
public:
    struct AssetDesc final {
        char const *diffuse_ = nullptr;
        char const *mesh_ = nullptr;
        char const *normal_ = nullptr;
    };

    OpaqueLayerBase(OpaqueLayerBase const &) = delete;
    OpaqueLayerBase &operator= (OpaqueLayerBase const &) = delete;
    OpaqueLayerBase(OpaqueLayerBase &&) = delete;
    OpaqueLayerBase &operator= (OpaqueLayerBase &&) = delete;

protected:
    class AssetInfo final {
    public:
        constexpr static GLuint VERTICES = 0U;
        constexpr static GLuint UVS = 1U;
        constexpr static GLuint NORMALS = 2U;
        constexpr static GLuint TANGENTS = 3U;
        constexpr static GLuint BITANGENTS = 4U;

        AssetInfo() = default;

        AssetInfo(AssetInfo const &) = delete;
        AssetInfo &operator= (AssetInfo const &) = delete;

        AssetInfo(AssetInfo &&) = delete;
        AssetInfo &operator= (AssetInfo &&) = delete;

        ~AssetInfo() = default;

        [[nodiscard]] bool Init(AssetDesc const &desc) noexcept;

        void AppendDestroyResources(std::span<GLuint> &textures, size_t &pushTexIdx, std::span<GLuint> &vaos,
            size_t &pushVAOIdx, std::span<GLuint> &vbos, size_t &pushVBOIdx) noexcept;

        GLuint diffuse_ = 0U;
        GLuint normal_ = 0U;
        GLuint vao_ = 0U;
        GLuint vbo_ = 0U;
        GLsizei vertices_ = 0;
        AABB bounds_{};
    };

    constexpr static size_t INSTANCE_SQRT = 18U;
    constexpr static size_t INSTANCE_COUNT = INSTANCE_SQRT * INSTANCE_SQRT;

    constexpr static float DEFAULT_INSTANCE_PER_SIDE = 32.0F;
    constexpr static float DEFAULT_DISTANCE = 3.0F;

    constexpr static float DENSITY = DEFAULT_INSTANCE_PER_SIDE / static_cast<float>(INSTANCE_SQRT);
    constexpr static float SCALE = 0.75F * DENSITY;
    constexpr static Vector3D ROTATION_AXIS{0.0F, 1.0F, 0.0F};
    constexpr static float ROTATION_SPEED = 1.0F;

    constexpr static float WAVE_HEIGHT = 0.4F * DENSITY;

    constexpr static size_t CULLERS = 4U;

    constexpr static GLuint DIFFUSE_UNIT = 0U;
    constexpr static GLuint NORMAL_UNIT = 1U;

    constexpr static GLint AMBIENT_LIGHT_COLOR = 2;
    constexpr static GLint SPOT_LIGHT_COLOR = 3;
    constexpr static GLint SPOT_LIGHT_LOCATION = 4;

    constexpr static size_t ASSET_COUNT = 1U;
    constexpr static Vector3D SPOT_LIGHT_LOCATION_WORLD{0.1F, 1.0F, -0.1F};

    OpaqueLayerBase() = default;
    virtual ~OpaqueLayerBase() = default;

    [[nodiscard]] virtual bool CreateProgram(GLuint &program) const noexcept = 0;
    virtual void Destroy() noexcept;

    [[nodiscard]] bool InitBase(AABB &geometryBounds) noexcept;
    void SetCommonRenderState(Matrix4x4 const &view) const noexcept;

    AssetInfo assets_[ASSET_COUNT] = {};

private:
    GLuint sampler_ = 0U;
    GLuint program_ = 0U;
};

} // namespace OpenGTX

#endif // OPAQUE_LAYER_BASE_HPP
