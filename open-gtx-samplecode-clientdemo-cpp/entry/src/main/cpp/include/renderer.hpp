#ifndef RENDERER_H
#define RENDERER_H

#include <string_view>
#include <unordered_set>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>

namespace OpenGTX {

struct FBO final {
    operator GLuint() const
    {
        return fbo_;
    }

    GLuint texture_ = 0U;

    GLuint depthTexture_ = 0U;
    GLuint fbo_ = 0U;
    GLuint renderBuffer_ = 0U;

    uint16_t fboWidth_ = 0U;
    uint16_t fboHeight_ = 0U;
};

struct TextureBuffer final {
    operator GLuint () const
    {
        return buffer_;
    }

    // Texture handle
    GLuint texture_ = 0U;

    // buffer handle
    GLuint buffer_ = 0U;
};

class Renderer final {
public:
    constexpr static uint32_t INVALID_VALUE = std::numeric_limits<uint32_t>::max();

    using Window = void *;

    enum class Attribute : GLint
    {
        POSITION [[maybe_unused]] = 0,
        WEIGHT [[maybe_unused]] = 1,
        NORMAL [[maybe_unused]] = 2,
        COLOR [[maybe_unused]] = 3,
        TANGENT [[maybe_unused]] = 4,
        BLENDINDICES [[maybe_unused]] = 5,
        TEXCOORD0 [[maybe_unused]] = 6,
        TRANSFORM0 [[maybe_unused]] = 7,
        TRANSFORM1 [[maybe_unused]] = 8,
        TRANSFORM2 [[maybe_unused]] = 9,
        TOTAL_ATTRIBUTES [[maybe_unused]] = 10
    };

    // For BeginRenderTarget
    enum Flags : uint32_t {
        NO_CLEAR_COLOR = 1U << 0U,
        NO_CLEAR_DEPTH = 1U << 1U,
    };

    enum FBOFlags : uint32_t {
        USE_IMMUTABLE_TEXTURE = 1U << 0U,
        USE_DEPTH_TEXTURE = 1U << 1U,
    };

    struct SurfaceInfo final {
        float fAspectRatio = 1.0F;
        uint32_t width = 0U;
        uint32_t height = 0U;
    };

    constexpr static uint32_t DEFAULT_FBO_FLAGS = USE_IMMUTABLE_TEXTURE | USE_DEPTH_TEXTURE;

    Renderer() = default;

    Renderer(Renderer const &) = delete;
    Renderer &operator= (Renderer const &) = delete;

    Renderer(Renderer &&) = delete;
    Renderer &operator= (Renderer &&) = delete;

    ~Renderer() = default;

    EGLDisplay GetDisplay() { return display_; }

    // "flags" is a bit field of OpenGLBase::Flags.
    void BeginRenderTarget(FBO const &fbo, float r, float g, float b, float a, uint32_t flags = 0U) const noexcept;
    void EndRenderTarget() const noexcept;

    void BindEmptyVAO() const noexcept;
    SurfaceInfo const &GetSurfaceInfo() const noexcept;

    [[nodiscard]] bool InitRender() noexcept;
    [[maybe_unused]] void ShutDownRender() noexcept;

    [[nodiscard]] bool InitSwapchain(Window wnd, bool vSync) noexcept;
    [[nodiscard]] bool HasSwapchain() const noexcept;
    void DestroySwapchain() noexcept;
    void SetSwapchainResolution(uint32_t width, uint32_t height) noexcept;

    [[maybe_unused]] void UpdateTextureUniform(GLuint program, char const *uniformName,
        GLuint index = 0) const noexcept;

    [[maybe_unused]] void CreateTextureBuffer(TextureBuffer &textureBuffer, const void *src, uint32_t size,
        GLenum internalFormat, GLuint buffer = 0U) const noexcept;

    void Present() const noexcept;

    static void BindTexture(GLuint texture, GLuint slot = 0U, GLenum target = GL_TEXTURE_2D) noexcept;

    static void CheckGLError(char const *file = NULL, uint32_t line = 0) noexcept;

    // Method returns INVALID_VALUE in case of error. Otherwise the method returns valid program handle.
    [[nodiscard, maybe_unused]] static uint32_t CreateComputeProgram(char const *scr) noexcept;

    [[nodiscard]] static FBO CreateFBO(GLenum internalFormat, GLuint width, GLuint height, GLuint nSamples = 1U,
        GLuint levels = 1U, GLenum depthFormat = GL_DEPTH_STENCIL, GLenum target = GL_TEXTURE_2D, GLuint texture = 0U,
        uint32_t flags = DEFAULT_FBO_FLAGS) noexcept;

    // Method returns INVALID_VALUE in case of error. Otherwise the method returns valid program handle.
    [[nodiscard]] static uint32_t CreateGraphicProgram(char const *vsShader, char const *psShader,
        char const *gsShader = nullptr, bool linkDefaultAttributes = false) noexcept;

    [[nodiscard, maybe_unused]] static GLuint CreateIndexBuffer(void const *src, GLsizeiptr size) noexcept;
    [[nodiscard]] static GLuint CreateSSBOBuffer(void const *src, GLsizeiptr size) noexcept;

    [[nodiscard]] static GLuint CreateTexture(GLenum internalFormat, GLuint width, GLuint height, GLsizei levels = 1,
        GLenum target = GL_TEXTURE_2D, bool immutable = true) noexcept;

    [[nodiscard, maybe_unused]] static GLuint CreateUniformBuffer(const void *src, GLsizeiptr size) noexcept;
    [[nodiscard]] static GLuint CreateVertexBuffer(void const *src, GLsizeiptr size) noexcept;

    [[nodiscard]] static GLsizei GetMipLevels(uint32_t width, uint32_t height) noexcept;
    [[nodiscard]] static void *GetOpenGLExtensionFunction(char const *extName) noexcept;

    // Useful for 3rd-party libraries which produce GLES error messages.
    [[maybe_unused]] static void DisableAssertOnDebugReport() noexcept;
    [[maybe_unused]] static void EnableAssertOnDebugReport() noexcept;

    static void SetUploadTextureAlignment(uint32_t width, GLenum internalFormat) noexcept;

    [[maybe_unused]] static void UpdateTexture(GLuint texture, GLsizei width, GLsizei height, GLenum format,
        GLenum type, void const *pixels, GLenum target = GL_TEXTURE_2D, GLint level = 0, GLint xoffset = 0,
        GLint yoffset = 0) noexcept;

private:
    class IgnoreMessage final {
    public:
        struct Hasher final {
            [[nodiscard]] size_t operator()(IgnoreMessage const &m) const noexcept;

            std::hash<char32_t> enumHashServer_{};
            std::hash<std::string_view> stringViewHashServer_{};
        };

        IgnoreMessage() = default;

        IgnoreMessage(IgnoreMessage const &) = default;
        IgnoreMessage &operator= (IgnoreMessage const &) = delete;

        IgnoreMessage(IgnoreMessage &&) = delete;
        IgnoreMessage &operator= (IgnoreMessage &&) = delete;

        IgnoreMessage(GLenum type, GLenum severity, GLenum source, char const *message) noexcept;

        ~IgnoreMessage() = default;

        [[nodiscard]] bool operator== (IgnoreMessage const &) const noexcept = default;

    private:
        GLenum type_;
        GLenum severity_;
        GLenum source_;
        std::string_view message_;
    };

    static void AttachShader(uint32_t program, uint32_t shader) noexcept;
    [[nodiscard]] static bool CheckAttribute(uint32_t program, uint32_t location, char const *attribute) noexcept;
    [[nodiscard]] static GLenum CheckFBOStatus() noexcept;
    [[nodiscard]] static GLint ChoiceNumSamples(GLenum internalFormat, GLint nSamples) noexcept;
    [[nodiscard]] static GLuint CreateBuffer(GLenum target, void const *src, GLsizeiptr size) noexcept;
    [[nodiscard]] static uint32_t CreateGLSLProgram() noexcept;
    [[nodiscard]] static uint32_t CreateGLSLShader(char const *src, int shaderType) noexcept;

    static void GLESDebug(GLenum source, GLenum type, GLuint /*id*/, GLenum severity, GLsizei length,
        GLchar const *message, void const */*userParam*/);

    [[nodiscard]] static GLenum GetFormat(GLenum internalFormat) noexcept;
    [[nodiscard]] static GLenum GetType(GLenum internalFormat) noexcept;
    [[nodiscard]] static char const **GetVertexAttributeNames() noexcept;

    [[nodiscard]] static uint32_t LinkProgram(uint32_t vertexShader, uint32_t pixelShader,
        uint32_t geometryShader = INVALID_VALUE, bool linkDefaultAttributes = false) noexcept;

    [[nodiscard]] static FBO InitFBO(GLenum internalFormat, GLuint width, GLuint height, GLenum depthFormat,
        GLuint levels, GLenum target, GLuint texture, bool immutable) noexcept;

    [[nodiscard]] static bool IsExtensionSupport(char const *extensions, char const *extName) noexcept;

    [[nodiscard]] static bool LinkProgram(uint32_t program) noexcept;

    static void LoadProgramLog(uint32_t object) noexcept;
    static void LoadLog(uint32_t object, GLenum type) noexcept;
    static void OutEGLError(char const *message) noexcept;

    GLuint emptyVAO_ = 0U;

    EGLSurface surface_ = EGL_NO_SURFACE;
    EGLDisplay display_ = EGL_NO_DISPLAY;
    EGLContext context_ = EGL_NO_CONTEXT;
    EGLConfig config_{};

    SurfaceInfo surfaceInfo_{};

    static PFNGLDISCARDFRAMEBUFFEREXTPROC glDiscardFramebufferEXT_;
    static PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEEXTPROC glFramebufferTexture2DMultisampleEXT_;
    static PFNGLRENDERBUFFERSTORAGEMULTISAMPLEEXTPROC glRenderbufferStorageMultisampleEXT_;
    static PFNGLTEXSTORAGE2DPROC glTexStorage2D_;

    static bool assertOnDebugReport_;

    // Used inside GLES debug output handler.
    static std::unordered_set<IgnoreMessage, IgnoreMessage::Hasher> ignoreMessages_;
};

#define CheckOpenGLError() OpenGTX::Renderer::CheckGLError(__FILE__, __LINE__)

} // namespace OpenGTX

#endif // RENDERER_H
