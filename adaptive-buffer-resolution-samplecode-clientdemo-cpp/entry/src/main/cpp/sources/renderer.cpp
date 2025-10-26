/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <renderer.hpp>
#include <log.hpp>

#include <cstdio>
#include <dlfcn.h>
#include <string>
#include <string_view>
#include <vector>
#include <EGL/eglext.h>

namespace AdaptiveBufferResolution {
constexpr uint32_t NUMBER_TWO = 2;
constexpr uint32_t NUMBER_FOUR = 4;
constexpr uint32_t NUMBER_EIGHT = 8;

EGLint attribs[] = {
    EGL_RENDERABLE_TYPE, EGL_OPENGL_ES3_BIT,
    EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
    EGL_BLUE_SIZE, 8,
    EGL_GREEN_SIZE, 8,
    EGL_RED_SIZE, 8,
    EGL_ALPHA_SIZE, 8,
    EGL_DEPTH_SIZE, 24,
    EGL_SAMPLES, 0,
    EGL_SAMPLE_BUFFERS, 0,
    EGL_MIN_SWAP_INTERVAL, 0,
    EGL_MAX_SWAP_INTERVAL, 1,
    EGL_NONE
};

size_t Renderer::IgnoreMessage::Hasher::operator()(IgnoreMessage const &m) const noexcept
{
    size_t hash = 0U;

    auto hashCombine = [&](size_t h) noexcept {
        constexpr size_t magic = 0x9E3779B9U;
        hash ^= h + magic + (hash << 6U) + (hash >> 2U);
    };

    hashCombine(enumHashServer_(static_cast<char32_t>(m.type_)));
    hashCombine(enumHashServer_(static_cast<char32_t>(m.severity_)));
    hashCombine(enumHashServer_(static_cast<char32_t>(m.source_)));
    hashCombine(stringViewHashServer_(m.message_));

    return hash;
}

Renderer::IgnoreMessage::IgnoreMessage(GLenum type, GLenum severity, GLenum source, char const *message) noexcept
    : type_(type), severity_(severity), source_(source), message_(message)
{}

PFNGLDISCARDFRAMEBUFFEREXTPROC Renderer::glDiscardFramebufferEXT_ = nullptr;
PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEEXTPROC Renderer::glFramebufferTexture2DMultisampleEXT_ = nullptr;
PFNGLRENDERBUFFERSTORAGEMULTISAMPLEEXTPROC Renderer::glRenderbufferStorageMultisampleEXT_ = nullptr;
PFNGLTEXSTORAGE2DPROC Renderer::glTexStorage2D_ = nullptr;

bool Renderer::assertOnDebugReport_ = true;

std::unordered_set<Renderer::IgnoreMessage, Renderer::IgnoreMessage::Hasher> Renderer::ignoreMessages_ = {
    // See https://origin-developer.qualcomm.com/comment/11823
    Renderer::IgnoreMessage(GL_DEBUG_TYPE_PERFORMANCE, GL_DEBUG_SEVERITY_HIGH, GL_DEBUG_SOURCE_OTHER,
        "Packing allocations for resource %p"),

    // glDeleteProgram with 0U handle which is correct according to GLES 3.2 spec.
    Renderer::IgnoreMessage(GL_DEBUG_TYPE_ERROR, GL_DEBUG_SEVERITY_HIGH, GL_DEBUG_SOURCE_API,
        "unable to delete program %d")
};

// NOLINTNEXTLINE - can be made static
void Renderer::BeginRenderTarget(FBO const & fbo, float r, float g, float b, float a, uint32_t flags) const noexcept
{
    glBindFramebuffer(GL_FRAMEBUFFER, fbo);
    CheckOpenGLError();

    bool const clearDepth = !(flags & NO_CLEAR_DEPTH);
    bool const clearColor = !(flags & NO_CLEAR_COLOR);

    if (clearColor || (clearDepth && fbo.renderBuffer_)) {
        constexpr GLenum const attachments[] = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT};

        if (glDiscardFramebufferEXT_) {
            glDiscardFramebufferEXT_(GL_FRAMEBUFFER,
                fbo.renderBuffer_ ? static_cast<GLsizei>(std::size(attachments)) : static_cast<GLsizei>(1),
                attachments);

            CheckOpenGLError();
        }
    }

    glClearColor(r, g, b, a);
    CheckOpenGLError();

    // Clang-tidy fix (bitwise operation on signed valued).
    constexpr auto clearFlags = static_cast<GLbitfield>(GL_COLOR_BUFFER_BIT) |
        static_cast<GLbitfield>(GL_DEPTH_BUFFER_BIT) | static_cast<GLbitfield>(GL_STENCIL_BUFFER_BIT);

    glClear(clearFlags);
    CheckOpenGLError();

    glViewport(0, 0, static_cast<GLsizei>(fbo.fboWidth_), static_cast<GLsizei>(fbo.fboHeight_));
    CheckOpenGLError();
}

void Renderer::EndRenderTarget() const noexcept
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0U);
    CheckOpenGLError();

    glViewport(0, 0, static_cast<GLint>(surfaceInfo_.width), static_cast<GLint>(surfaceInfo_.height));
    CheckOpenGLError();
}

void Renderer::BindEmptyVAO() const noexcept
{
    glBindVertexArray(emptyVAO_);
    CheckOpenGLError();
}

Renderer::SurfaceInfo const &Renderer::GetSurfaceInfo() const noexcept
{
    return surfaceInfo_;
}

void PrintExtensions(const char *header, std::string extensions) noexcept
{
    GOLOGI("%s extensions:", header);
    // Replace spaces with null characters
    std::replace(extensions.begin(), extensions.end(), ' ', '\0');
    std::string_view view(extensions);

    while (true) {
        GOLOGI("    %s", view.data());

        // Find the next null character in the string
        auto const next = view.find('\0');
        if (next != std::string_view::npos) {
            // Move the view to the next character after '\0'
            view = view.substr(next + 1);
            continue;
        }

        break;
    }
}

bool Renderer::InitDisplay() noexcept
{
    EGLint major = 0;
    EGLint minor = 0;

    display_ = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    if (display_ == EGL_NO_DISPLAY) {
        GOLOGE("eglGetDisplay execution failed");
        return false;
    }

    if (!eglInitialize(display_, &major, &minor)) {
        OutEGLError("Can't Initialize EGL.");
        return false;
    }

    if (!eglBindAPI(EGL_OPENGL_ES_API)) {
        OutEGLError("eglBindAPI failed.");
        return false;
    }

    char const *str = eglQueryString(display_, EGL_VENDOR);
    if (!str) {
        GOLOGE("eglQueryString(EGL_VENDOR) execution failed");
        return false;
    }
    GOLOGI("EGL vendor: %s", str);

    str = eglQueryString(display_, EGL_VERSION);
    if (!str) {
        GOLOGE("eglQueryString(EGL_VERSION) execution failed");
        return false;
    }
    GOLOGI("EGL version: %s", str);

    str = eglQueryString(display_, EGL_EXTENSIONS);
    if (!str) {
        GOLOGE("eglQueryString(EGL_EXTENSIONS) execution failed");
        return false;
    }
    
    PrintExtensions("EGL", str);

    return true;
}

bool Renderer::CreateContext() noexcept
{
    constexpr EGLint contextMajor = 3;
    constexpr EGLint contextMinor = 2;

    constexpr EGLint const contextAttribsES[] = {
        EGL_CONTEXT_MAJOR_VERSION_KHR, contextMajor,
        EGL_CONTEXT_MINOR_VERSION_KHR, contextMinor,
        EGL_NONE
    };

    int numSamples = 0;

    EGLint numConfigs = 0;
    int i = numSamples;

    for (; i >= 0; --i) {
        attribs[15U] = i;

        if (eglChooseConfig(display_, attribs, &config_, 1, &numConfigs) && numConfigs) {
            break;
        }

        OutEGLError("eglChooseConfig failed.");
    }

    if (i < 0) {
        attribs[15U] = 0;
        attribs[17U] = 0;

        if (!eglChooseConfig(display_, attribs, &config_, 1, &numConfigs)) {
            OutEGLError("eglChooseConfig failed.");
            return false;
        }
    }

    if (!numConfigs) {
        // NVIDIA Tegra 3 doesn't support 24 depth size
        attribs[13U] = 16U;

        if (!eglChooseConfig(display_, attribs, &config_, 1, &numConfigs)) {
            OutEGLError("eglChooseConfig failed.");
            return false;
        }
    }

    context_ = eglCreateContext(display_, config_, EGL_NO_CONTEXT, contextAttribsES);
    if (!context_) {
        OutEGLError("Can't create an EGL context.");
        return false;
    }

    return true;
}

void Renderer::ConfigureProperties() noexcept
{
    glEnable(GL_DEPTH_TEST);
    CheckOpenGLError();

    glEnable(GL_CULL_FACE);
    CheckOpenGLError();

    glDisable(GL_DITHER);
    CheckOpenGLError();

    glActiveTexture(GL_TEXTURE0);
    CheckOpenGLError();

    glTexStorage2D_ = reinterpret_cast<PFNGLTEXSTORAGE2DPROC>(GetOpenGLExtensionFunction("glTexStorage2D"));
    if (!glTexStorage2D_) {
        glTexStorage2D_ = reinterpret_cast<PFNGLTEXSTORAGE2DPROC>(GetOpenGLExtensionFunction("glTexStorage2DEXT"));
    }

    glFramebufferTexture2DMultisampleEXT_ = reinterpret_cast<PFNGLFRAMEBUFFERTEXTURE2DMULTISAMPLEEXTPROC>(
        GetOpenGLExtensionFunction("glFramebufferTexture2DMultisampleEXT"));

    glRenderbufferStorageMultisampleEXT_ = reinterpret_cast<PFNGLRENDERBUFFERSTORAGEMULTISAMPLEEXTPROC>(
        GetOpenGLExtensionFunction("glRenderbufferStorageMultisampleEXT"));

    glDiscardFramebufferEXT_ =
        reinterpret_cast<PFNGLDISCARDFRAMEBUFFEREXTPROC>(GetOpenGLExtensionFunction("glDiscardFramebufferEXT"));

    glGenVertexArrays(1, &emptyVAO_);
    CheckOpenGLError();
}

bool Renderer::InitRender() noexcept
{
    if (!InitDisplay()) {
        GOLOGE("InitDisplay execution failed");
        return false;
    }

    char const *str = eglQueryString(display_, EGL_EXTENSIONS);
    bool const isKHRCreateContext = IsExtensionSupport(str, "EGL_KHR_create_context");
    if (isKHRCreateContext) {
        if (!CreateContext()) {
            GOLOGE("CreateContext execution failed");
            return false;
        }
    }

    if (eglMakeCurrent(display_, EGL_NO_SURFACE, EGL_NO_SURFACE, context_) == EGL_FALSE) {
        OutEGLError("Unable to eglMakeCurrent.");
        return false;
    }

    str = reinterpret_cast<char const *>(glGetString(GL_RENDERER));
    if (!str) {
        GOLOGE("glGetString(GL_RENDERER) execution failed");
        return false;
    }
    CheckOpenGLError();

    GOLOGI("GLES renderer: %s", str);

    str = reinterpret_cast<char const *>(glGetString(GL_VENDOR));
    if (!str) {
        GOLOGE("glGetString(GL_VENDOR) execution failed");
        return false;
    }
    CheckOpenGLError();
    GOLOGI("GLES vendor: %s", str);

    str = reinterpret_cast<char const *>(glGetString(GL_VERSION));
    if (!str) {
        GOLOGE("glGetString(GL_VERSION) execution failed");
        return false;
    }
    CheckOpenGLError();
    GOLOGI("GLES version: %s", str);

    str = reinterpret_cast<char const *>(glGetString(GL_EXTENSIONS));
    if (!str) {
        GOLOGE("glGetString(GL_EXTENSIONS) execution failed");
        return false;
    }
    CheckOpenGLError();
    PrintExtensions("GLES", str);

    return true;
}

void Renderer::ShutDownRender() noexcept
{
    if (emptyVAO_) {
        glDeleteVertexArrays(1, &emptyVAO_);
        CheckOpenGLError();
    }

    if (HasSwapchain()) {
        DestroySwapchain();
    }

    if (eglDestroyContext(display_, context_) == EGL_FALSE) {
        OutEGLError("eglDestroyContext failed");
    } else {
        context_ = EGL_NO_CONTEXT;
    }

    if (eglTerminate(display_) == EGL_FALSE) {
        OutEGLError("eglDestroyContext failed");
    } else {
        display_ = EGL_NO_DISPLAY;
    }
}

bool Renderer::InitSwapchain(Window wnd, bool vSync) noexcept
{
    if (!wnd) {
        GOLOGE("Window is nullptr");
        return false;
    }
    surface_ = eglCreateWindowSurface(display_, config_, reinterpret_cast<EGLNativeWindowType>(wnd), nullptr);
    if (!surface_) {
        OutEGLError("Can't create a window surface.");
        return false;
    }

    if (eglMakeCurrent(display_, surface_, surface_, context_) == EGL_FALSE) {
        OutEGLError("Unable to eglMakeCurrent.");
        return false;
    }

    bool const result = eglSwapInterval(display_, static_cast<EGLint>(vSync)) == EGL_TRUE;
    if (result == false) {
        GOLOGE("eglSwapInterval execution failed");
        return false;
    }

    return result;
}

bool Renderer::HasSwapchain() const noexcept
{
    return surface_ != EGL_NO_SURFACE;
}

void Renderer::DestroySwapchain() noexcept
{
    if (eglMakeCurrent(display_, EGL_NO_SURFACE, EGL_NO_SURFACE, context_) == EGL_FALSE) {
        OutEGLError("Unable to eglMakeCurrent.");
    }

    if (eglDestroySurface(display_, surface_) == EGL_FALSE) {
        OutEGLError("eglDestroySurface failed");
    } else {
        surface_ = EGL_NO_SURFACE;
    }
}

void Renderer::SetSwapchainResolution(uint32_t width, uint32_t height) noexcept
{
    glViewport(0, 0, static_cast<GLsizei>(width), static_cast<GLsizei>(height));
    CheckOpenGLError();

    surfaceInfo_.fAspectRatio = static_cast<float>(width) / static_cast<float>(height);
    surfaceInfo_.width = width;
    surfaceInfo_.height = height;
}

// NOLINTNEXTLINE - can be made static.
[[maybe_unused]] void Renderer::UpdateTextureUniform(GLuint program, char const *uniformName, GLuint index) const
    noexcept
{
    if (!uniformName) {
        GOLOGE("Renderer::UpdateTextureUniform uniformName is null");
        return;
    }
    if (!glIsProgram(program)) {
        GOLOGE("Renderer::UpdateTextureUniform execution failed");
        return;
    }

    GLint const tex2D = glGetUniformLocation(program, uniformName);
    CheckOpenGLError();

    if (tex2D == -1) {
        return;
    }

    glUseProgram(program);
    CheckOpenGLError();

    glUniform1i(tex2D, static_cast<GLint>(index));
    CheckOpenGLError();
}

// NOLINTNEXTLINE - can be made static.
[[maybe_unused]] void Renderer::CreateTextureBuffer(TextureBuffer &textureBuffer, void const *src, uint32_t size,
    GLenum internalFormat, GLuint buffer) const noexcept
{
    if (buffer) {
        textureBuffer.buffer_ = buffer;
    } else {
        textureBuffer.buffer_ = CreateVertexBuffer(src, size);
    }

    glGenTextures(1, &textureBuffer.texture_);
    CheckOpenGLError();

    glBindTexture(GL_TEXTURE_BUFFER, textureBuffer.texture_);
    CheckOpenGLError();

    glTexBuffer(GL_TEXTURE_BUFFER, internalFormat, textureBuffer.buffer_);
    CheckOpenGLError();
}

void Renderer::Present() const noexcept
{
    [[maybe_unused]] EGLBoolean const res = eglSwapBuffers(display_, surface_);
    if (res != EGL_TRUE) {
        GOLOGE("eglSwapBuffers execution failed");
        return;
    }
}

void Renderer::BindTexture(GLuint texture, GLuint slot, GLenum target) noexcept
{
    glActiveTexture(GL_TEXTURE0 + slot);
    CheckOpenGLError();

    glBindTexture(target, texture);
    CheckOpenGLError();
}

void Renderer::CheckGLError(char const *file, uint32_t line) noexcept
{
    GLenum const err = glGetError();
    if (GL_NO_ERROR == err) {
        return;
    }

    char const *errStr;

    switch (err) {
        case GL_INVALID_OPERATION:
            errStr = "Invalid operation";
            break;

        case GL_INVALID_VALUE:
            errStr = "Invalid value";
            break;

        case GL_INVALID_ENUM:
            errStr = "Invalid enum";
            break;

        case GL_OUT_OF_MEMORY:
            errStr = "Out of memory";
            break;

        case GL_INVALID_FRAMEBUFFER_OPERATION:
            errStr = "Invalid frame buffer operation";
            break;

        default:
            errStr = "Unknown error";
            break;
    }

    GOLOGE("[%s:%d] OpenGL Error: %s", file, line, errStr);
}

[[maybe_unused]] uint32_t Renderer::CreateComputeProgram(char const *src) noexcept
{
    uint32_t cs = CreateGLSLShader(src, GL_COMPUTE_SHADER);
    if (cs == INVALID_VALUE) {
        return cs;
    }

    uint32_t const program = CreateGLSLProgram();
    AttachShader(program, cs);

    uint32_t const cases[] = {INVALID_VALUE, program};
    return cases[static_cast<size_t>(LinkProgram(program))];
}

FBO Renderer::CreateFBO(GLenum internalFormat, GLuint width, GLuint height, GLuint nSamples, GLuint levels,
    GLenum depthFormat, GLenum target, GLuint texture, uint32_t flags) noexcept
{
    uint32_t immutable = flags & USE_IMMUTABLE_TEXTURE;
    uint32_t useDepthTexture = flags & USE_DEPTH_TEXTURE;

    FBO fbo = InitFBO(internalFormat, width, height, useDepthTexture ? depthFormat : GL_NONE, levels, target, texture,
        static_cast<bool>(immutable));

    bool const depth = depthFormat != GL_NONE;
    bool const depthTexture = depth && useDepthTexture;
    bool const depthRenderBuffer = depth && !useDepthTexture;

    if (!depthRenderBuffer) {
        fbo.renderBuffer_ = 0U;
    } else {
        // create render buffer
        glGenRenderbuffers(1, &fbo.renderBuffer_);
        CheckOpenGLError();

        glBindRenderbuffer(GL_RENDERBUFFER, fbo.renderBuffer_);
        CheckOpenGLError();
    }

    if (nSamples > 1) {
        if (depthRenderBuffer) {
            nSamples = static_cast<GLuint>(ChoiceNumSamples(depthFormat, static_cast<GLint>(nSamples)));

            glRenderbufferStorageMultisampleEXT_(GL_RENDERBUFFER, static_cast<GLsizei>(nSamples), depthFormat,
                static_cast<GLsizei>(width), static_cast<GLsizei>(height));

            CheckOpenGLError();
        }

        nSamples = static_cast<GLuint>(ChoiceNumSamples(internalFormat, static_cast<GLint>(nSamples)));

        glFramebufferTexture2DMultisampleEXT_(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, target, fbo.texture_, 0,
            static_cast<GLsizei>(nSamples));

        CheckOpenGLError();
    } else {
        if (depthTexture) {
            glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, target, fbo.depthTexture_, 0);
            CheckOpenGLError();

            if (GL_DEPTH_STENCIL == depthFormat) {
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, target, fbo.depthTexture_, 0);
                CheckOpenGLError();
            }
        } else if (depthRenderBuffer) {
            glRenderbufferStorage(GL_RENDERBUFFER, depthFormat, static_cast<GLsizei>(width),
                static_cast<GLsizei>(height));

            CheckOpenGLError();
        }

        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, target, fbo.texture_, 0);
        CheckOpenGLError();
    }

    [[maybe_unused]] GLenum status = CheckFBOStatus();
    glBindRenderbuffer(GL_RENDERBUFFER, 0U);
    CheckOpenGLError();

    glBindFramebuffer(GL_FRAMEBUFFER, 0U);
    CheckOpenGLError();

    return fbo;
}

uint32_t Renderer::CreateGraphicProgram(char const *vsShader, char const *psShader, char const *gsShader,
    bool linkDefaultAttributes) noexcept
{
    uint32_t const vs = CreateGLSLShader(vsShader, GL_VERTEX_SHADER);
    if (vs == INVALID_VALUE) {
        return vs;
    }

    uint32_t const ps = CreateGLSLShader(psShader, GL_FRAGMENT_SHADER);
    if (ps == INVALID_VALUE) {
        return ps;
    }

    uint32_t const gs = gsShader ? CreateGLSLShader(gsShader, GL_GEOMETRY_SHADER) : INVALID_VALUE;
    return LinkProgram(vs, ps, gs, linkDefaultAttributes);
}

[[maybe_unused]] GLuint Renderer::CreateIndexBuffer(void const * src, GLsizeiptr size) noexcept
{
    return CreateBuffer(GL_ELEMENT_ARRAY_BUFFER, src, size);
}

GLuint Renderer::CreateSSBOBuffer(void const *src, GLsizeiptr size) noexcept
{
    return CreateBuffer(GL_SHADER_STORAGE_BUFFER, src, size);
}

GLuint Renderer::CreateTexture(GLenum internalFormat, GLuint width, GLuint height, GLsizei levels, GLenum target,
    bool immutable) noexcept
{
    GLuint texture = 0;
    glGenTextures(1, &texture);
    CheckOpenGLError();

    glBindTexture(target, texture);
    CheckOpenGLError();

    GLenum const format = GetFormat(internalFormat);
    GLenum const dataType = GetType(internalFormat);

    if (immutable && internalFormat != GL_DEPTH_STENCIL) {
        glTexStorage2D_ = reinterpret_cast<PFNGLTEXSTORAGE2DPROC>(GetOpenGLExtensionFunction("glTexStorage2D"));
        if (!glTexStorage2D_) {
            glTexStorage2D_ = reinterpret_cast<PFNGLTEXSTORAGE2DPROC>(GetOpenGLExtensionFunction("glTexStorage2DEXT"));
        }

        if (glTexStorage2D_) {
            glTexStorage2D_(target, levels, internalFormat, static_cast<GLint>(width), static_cast<GLint>(height));
            CheckOpenGLError();
        }
    } else {
        glTexImage2D(target, 0, static_cast<GLint>(internalFormat), static_cast<GLint>(width),
            static_cast<GLint>(height), 0, format, dataType, nullptr);
        CheckOpenGLError();
    }

    glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    CheckOpenGLError();

    glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    CheckOpenGLError();

    glTexParameteri(target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    CheckOpenGLError();

    glTexParameteri(target, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
    CheckOpenGLError();

    return texture;
}

[[maybe_unused]] GLuint Renderer::CreateUniformBuffer(void const *src, GLsizeiptr size) noexcept
{
    return CreateBuffer(GL_UNIFORM_BUFFER, src, size);
}

GLuint Renderer::CreateVertexBuffer(void const * src, GLsizeiptr size) noexcept
{
    return CreateBuffer(GL_ARRAY_BUFFER, src, size);
}

GLsizei Renderer::GetMipLevels(uint32_t width, uint32_t height) noexcept
{
    // see https://en.cppreference.com/w/cpp/numeric/bit_width
    return static_cast<GLsizei>(std::numeric_limits<uint32_t>::digits - std::countl_zero(std::max(width, height)));
}

void *Renderer::GetOpenGLExtensionFunction(char const *extName) noexcept
{
    if (!extName) {
        GOLOGE("Renderer::GetOpenGLExtensionFunction extName is null");
        return nullptr;
    }

    if (void *glApi = reinterpret_cast<void *>(eglGetProcAddress(extName)); glApi) {
        return glApi;
    }

    return dlsym(RTLD_DEFAULT, extName);
}

[[maybe_unused]] void Renderer::DisableAssertOnDebugReport() noexcept
{
    assertOnDebugReport_ = false;
}

[[maybe_unused]] void Renderer::EnableAssertOnDebugReport() noexcept
{
    assertOnDebugReport_ = true;
}

void Renderer::SetUploadTextureAlignment(uint32_t width, GLenum internalFormat) noexcept
{
    uint32_t bytes = 0U;

    switch (internalFormat) {
        case GL_RGBA8:
            bytes = 4U;
            break;

        case GL_RGB8:
            bytes = 3U;
            break;

        case GL_RGBA16F:
            bytes = 8U;
            break;

        default:
            GOLOGE("Unknown internal format 0x%X", internalFormat);
            break;
    }

    if (!bytes) {
        GOLOGE("Renderer::SetUploadTextureAlignment internalFormat unknown");
        return;
    }
    bytes *= width;

    if (bytes % NUMBER_EIGHT == 0) {
        glPixelStorei(GL_UNPACK_ALIGNMENT, NUMBER_EIGHT);
        CheckOpenGLError();
        return;
    }

    if (bytes % NUMBER_FOUR == 0) {
        glPixelStorei(GL_UNPACK_ALIGNMENT, NUMBER_FOUR);
        CheckOpenGLError();
        return;
    }

    if (bytes % NUMBER_TWO == 0) {
        glPixelStorei(GL_UNPACK_ALIGNMENT, NUMBER_TWO);
        CheckOpenGLError();
        return;
    }

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    CheckOpenGLError();
}

[[maybe_unused]] void Renderer::UpdateTexture(GLuint texture, GLsizei width, GLsizei height, GLenum format, GLenum type,
    void const *pixels, GLenum target, GLint level, GLint xoffset, GLint yoffset) noexcept
{
    glBindTexture(GL_TEXTURE_2D, texture);
    CheckOpenGLError();

    // See comment about GL_PIXEL_UNPACK_BUFFER
    // https://docs.gl/es3/glBindBuffer
    glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0U);
    CheckOpenGLError();

    glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
    CheckOpenGLError();
}

void Renderer::AttachShader(uint32_t program, uint32_t shader) noexcept
{
    if (!shader) {
        return;
    }

    if (!glIsProgram(program)) {
        GOLOGE("Renderer::AttachShader glIsProgram execution failed");
        return;
    }
    CheckOpenGLError();

    if (!glIsShader(shader)) {
        GOLOGE("Renderer::AttachShader glIsShader execution failed");
        return;
    }
    CheckOpenGLError();

    glAttachShader(program, shader);
    CheckOpenGLError();

    glDeleteShader(shader);
    CheckOpenGLError();
}

bool Renderer::CheckAttribute(uint32_t program, uint32_t location, char const *attribute) noexcept
{
    auto const loc = static_cast<uint32_t>(glGetAttribLocation(program, attribute));
    CheckOpenGLError();

    if (UINT_MAX == loc) {
        GOLOGE("Invalid attribute location %s", attribute);
        return false;
    }

    if (loc != location) {
        GOLOGE("Attribute location %d mismatch location %d for attribute %s", location, loc, attribute);
        return false;
    }

    return true;
}

GLenum Renderer::CheckFBOStatus() noexcept
{
    GLenum const status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    CheckOpenGLError();

    switch (status) {
        case GL_FRAMEBUFFER_COMPLETE:
            // NOTHING - all good.
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
            GOLOGE("GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            GOLOGE("GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");
            break;

        case GL_FRAMEBUFFER_UNDEFINED:
            GOLOGE("GL_FRAMEBUFFER_UNDEFINED");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS:
            GOLOGE("GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_IMG:
            GOLOGE("GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_IMG");
            break;

        case GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
            GOLOGE("GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE");
            break;

        case GL_FRAMEBUFFER_UNSUPPORTED:
            GOLOGE("GL_FRAMEBUFFER_UNSUPPORTED");
            break;

        default:
            GOLOGE("Unknown FBO error 0x%08x", status);
            break;
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0U);
    CheckOpenGLError();
    return status;
}

GLint Renderer::ChoiceNumSamples(GLenum internalFormat, GLint nSamples) noexcept
{
    GLint numSamples = 0;
    glGetInternalformativ(GL_RENDERBUFFER, internalFormat, GL_NUM_SAMPLE_COUNTS, sizeof(numSamples), &numSamples);
    CheckOpenGLError();

    GLint samples[16U];
    glGetInternalformativ(GL_RENDERBUFFER, internalFormat, GL_SAMPLES, sizeof(samples), samples);
    CheckOpenGLError();

    GLint const * foundedSample = std::find(samples, samples + numSamples, nSamples);

    if (foundedSample != samples + numSamples) {
        return nSamples;
    }

    foundedSample = std::max_element(samples, samples + numSamples);
    nSamples = std::min(nSamples, *foundedSample);
    return nSamples;
}

GLuint Renderer::CreateBuffer(GLenum target, void const *src, GLsizeiptr size) noexcept
{
    GLuint buffer;

    glGenBuffers(1, &buffer);
    CheckOpenGLError();

    glBindBuffer(target, buffer);
    CheckOpenGLError();

    glBufferData(target, size, src, GL_DYNAMIC_DRAW);
    CheckOpenGLError();

    glBindBuffer(target, 0U);
    CheckOpenGLError();

    return buffer;
}

uint32_t Renderer::CreateGLSLProgram() noexcept
{
    GLuint const program = glCreateProgram();
    CheckOpenGLError();

    if (!glIsProgram(program)) {
        GOLOGE("Renderer::CreateGLSLProgram execution failed");
        return 0U;
    }
    CheckOpenGLError();

    return static_cast<uint32_t>(program);
}

uint32_t Renderer::CreateGLSLShader(char const *src, int shaderType) noexcept
{
    GLuint shader = glCreateShader(static_cast<GLenum>(shaderType));
    CheckOpenGLError();

    GLint compileStatus = 0;
    if (!src) {
        GOLOGE("Renderer::CreateGLSLShader src is null");
        return false;
    }

    auto size = static_cast<int>(strlen(src));
    glShaderSource(shader, 1, &src, &size);
    CheckOpenGLError();

    glCompileShader(shader);
    CheckOpenGLError();

    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    CheckOpenGLError();

    LoadLog(shader, static_cast<GLenum>(shaderType));

    if (!compileStatus) {
        glDeleteShader(shader);
        CheckOpenGLError();
        return INVALID_VALUE;
    }

    glReleaseShaderCompiler();
    CheckOpenGLError();

    return static_cast<uint32_t>(shader);
}

GLenum Renderer::GetFormat(GLenum internalFormat) noexcept
{
    switch (internalFormat) {
        case GL_RGB9_E5:
        case GL_RGB10_A2:
        case GL_RGBA32F:
        case GL_RGBA16F:
        case GL_COMPRESSED_RGBA_ASTC_4x4_KHR:
        case GL_COMPRESSED_RGBA_ASTC_5x4_KHR:
        case GL_COMPRESSED_RGBA_ASTC_5x5_KHR:
        case GL_COMPRESSED_RGBA8_ETC2_EAC:
        case GL_RGBA8:
            return GL_RGBA;

        case GL_COMPRESSED_RGB8_ETC2:
        case GL_R11F_G11F_B10F:
            return GL_RGB;

        case GL_RG:
            return GL_RG8;

        case GL_DEPTH_STENCIL:
            return GL_DEPTH_STENCIL;

        default:
            // NOTHING
            break;
    }

    return GL_RGBA;
}

GLenum Renderer::GetType(GLenum internalFormat) noexcept
{
    switch (internalFormat) {
        case GL_R11F_G11F_B10F:
        case GL_RGBA16F:
            return GL_HALF_FLOAT;

        case GL_RGB9_E5:
        case GL_RG8:
        case GL_RGBA8:
            return GL_UNSIGNED_BYTE;

        case GL_RGB10_A2:
            return GL_UNSIGNED_SHORT;

        case GL_RGBA32F:
            return GL_FLOAT;

        case GL_DEPTH_STENCIL:
            return GL_UNSIGNED_INT_24_8;

        default:
            // NOTHING
            break;
    }

    return GL_UNSIGNED_BYTE;
}

char const ** Renderer::GetVertexAttributeNames() noexcept
{
    static constexpr char const *attributes[static_cast<size_t>(Renderer::Attribute::TOTAL_ATTRIBUTES)] = {
        "POSITION",
        "BLENDWEIGHT",
        "NORMAL",
        "COLOR",
        "TEXCOORD0",
        "BLENDINDICES",
        "TANGENT",
        "TRANSFORM0",
        "TRANSFORM1",
        "TRANSFORM2",
    };

    return const_cast<char const **>(attributes);
}

uint32_t *GetAttributeIndices()
{
    static constexpr uint32_t attributeIndices[] = {
        static_cast<uint32_t>(Renderer::Attribute::POSITION),
        static_cast<uint32_t>(Renderer::Attribute::WEIGHT),
        static_cast<uint32_t>(Renderer::Attribute::NORMAL),
        static_cast<uint32_t>(Renderer::Attribute::COLOR),
        static_cast<uint32_t>(Renderer::Attribute::TEXCOORD0),
        static_cast<uint32_t>(Renderer::Attribute::BLENDINDICES),
        static_cast<uint32_t>(Renderer::Attribute::TANGENT),
        static_cast<uint32_t>(Renderer::Attribute::TRANSFORM0),
        static_cast<uint32_t>(Renderer::Attribute::TRANSFORM1),
        static_cast<uint32_t>(Renderer::Attribute::TRANSFORM2)
    };

    return const_cast<uint32_t *>(attributeIndices);
}

uint32_t Renderer::LinkProgram(uint32_t vertexShader, uint32_t pixelShader, uint32_t geometryShader,
    bool linkDefaultAttributes) noexcept
{
    uint32_t const program = CreateGLSLProgram();

    if (vertexShader) {
        AttachShader(program, vertexShader);
    }

    if (pixelShader) {
        AttachShader(program, pixelShader);
    }

    if (geometryShader != INVALID_VALUE) {
        AttachShader(program, geometryShader);
    }

    if (!LinkProgram(program)) {
        return INVALID_VALUE;
    }

    if (!linkDefaultAttributes) {
        return program;
    }

    uint32_t *attributeIndices = GetAttributeIndices();

    char const ** attributes = GetVertexAttributeNames();

    for (uint32_t i = 0; i < static_cast<uint32_t>(Renderer::Attribute::TOTAL_ATTRIBUTES); ++i) {
        char const * attribute = attributes[i];
        auto const index = static_cast<uint32_t>(glGetAttribLocation(program, attribute));
        if (index == std::numeric_limits<uint32_t>::max()) {
            continue;
        }

        glBindAttribLocation(program, attributeIndices[i], attribute);
        CheckOpenGLError();
    }

    if (!LinkProgram(program)) {
        return INVALID_VALUE;
    }

    for (uint32_t i = 0U; i < static_cast<uint32_t>(Renderer::Attribute::TOTAL_ATTRIBUTES); ++i) {
        char const * attribute = attributes[i];
        auto const loc = static_cast<uint32_t>(glGetAttribLocation(program, attribute));
        CheckOpenGLError();

        if (loc == std::numeric_limits<uint32_t>::max()) {
            continue;
        }

        [[maybe_unused]] bool const res = CheckAttribute(program, loc, attribute);
    }

    return program;
}

FBO Renderer::InitFBO(GLenum internalFormat, GLuint width, GLuint height, GLenum depthFormat, GLuint levels,
    GLenum target, GLuint texture, bool immutable) noexcept
{
    FBO fbo{};
    fbo.fboWidth_ = static_cast<uint16_t>(width);
    fbo.fboHeight_ = static_cast<uint16_t>(height);

    fbo.texture_ = texture ?
        texture :
        CreateTexture(internalFormat, width, height, static_cast<GLsizei>(levels), target, immutable);

    glGenFramebuffers(1, &fbo.fbo_);
    CheckOpenGLError();

    glBindFramebuffer(GL_FRAMEBUFFER, fbo.fbo_);
    CheckOpenGLError();

    fbo.depthTexture_ = depthFormat == GL_NONE ? 0U : CreateTexture(depthFormat, width, height, 1, target, immutable);

    return fbo;
}

bool Renderer::IsExtensionSupport(char const *extensions, char const *extName) noexcept
{
    if (!extensions || !*extensions) {
        GOLOGE("Renderer::IsExtensionSupport extensions is null");
        return false;
    }
    if (!extName || !*extName) {
        GOLOGE("Renderer::IsExtensionSupport extName is null");
        return false;
    }

    // Search for extName in the extensions string.  Use of strstr()
    // is not sufficient because extension names can be prefixes of
    // other extension names.  Could use strtok() but the constant
    // string returned by glGetString can be in read-only memory
    size_t extNameLen = std::strlen(extName);
    char const * end = extensions + std::strlen(extensions);

    while (extensions < end) {
        size_t const n = std::strcspn(extensions, " ");
        if (extNameLen == n && !std::strncmp(extName, extensions, n)) {
            return true;
        }

        extensions += (n + 1);
    }

    return false;
}

bool Renderer::LinkProgram(uint32_t program) noexcept
{
    GLint linked = 0;

    // link the program object and print out the info log
    glLinkProgram(program);
    CheckOpenGLError();

    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    CheckOpenGLError();

    LoadProgramLog(program);

    if (!linked) {
        return false;
    }

    // Validation is not such a good idea here because validation checks register file values for current programs
    // (uniforms). This file is in undefined state right after program linking.
    glValidateProgram(program);
    CheckOpenGLError();

    GLint validated = 0;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &validated);
    CheckOpenGLError();

    LoadProgramLog(program);
    return true;
}

void Renderer::LoadProgramLog(uint32_t object) noexcept
{
    int logLength = 0;
    char infoLog[8192U];
    infoLog[0U] = '\0';
    glGetProgramInfoLog(static_cast<GLuint>(object), static_cast<int>(sizeof(infoLog)) - 1, &logLength, infoLog);

    if (infoLog[0U]) {
        GOLOGE("GLSL Program Log: %s", &infoLog[0]);
    }

    CheckOpenGLError();
}

void Renderer::LoadLog(uint32_t object, GLenum type) noexcept
{
    int logLength = 0;
    char infoLog[8192U];
    infoLog[0U] = '\0';
    glGetShaderInfoLog(static_cast<GLuint>(object), sizeof(infoLog) - 1U, &logLength, infoLog);

    if (!infoLog[0U]) {
        return;
    }

    switch (type) {
        case GL_VERTEX_SHADER:
            GOLOGE("Vertex shader Log: %s", &infoLog[0]);
            break;

        case GL_FRAGMENT_SHADER:
            GOLOGE("Fragment shader Log: %s", &infoLog[0]);
            break;

        case GL_COMPUTE_SHADER:
            GOLOGE("Compute shader Log: %s", &infoLog[0]);
            break;

        case GL_GEOMETRY_SHADER:
            GOLOGE("Geometry shader Log: %s", &infoLog[0]);
            break;

        default:
            GOLOGE("Log: %s", &infoLog[0]);
            break;
    }
}

void Renderer::OutEGLError(char const *message) noexcept
{
    EGLint const err = eglGetError();
    if (err == EGL_SUCCESS) {
        return;
    }

    constexpr char const *errorMessages[] = {
        "EGL_NOT_INITIALIZED",
        "EGL_BAD_ACCESS",
        "EGL_BAD_ALLOC",
        "EGL_BAD_ATTRIBUTE",
        "EGL_BAD_CONFIG",
        "EGL_BAD_CONTEXT",
        "EGL_BAD_CURRENT_SURFACE",
        "EGL_BAD_DISPLAY",
        "EGL_BAD_MATCH",
        "EGL_BAD_NATIVE_PIXMAP",
        "EGL_BAD_NATIVE_WINDOW",
        "EGL_BAD_PARAMETER",
        "EGL_BAD_SURFACE",
        "EGL_CONTEXT_LOST"
    };

    [[maybe_unused]] constexpr auto errors = std::size(errorMessages);
    auto const offset = static_cast<size_t>(err - EGL_SUCCESS);
    if (offset >= errors) {
        GOLOGE("Renderer::OutEGLError execution failed");
        return;
    }

    char const * errString = errorMessages[offset];

    if (message && *message) {
        GOLOGE("%s %s", message, errString);
        return;
    }

    GOLOGE("EGL Error %s", errString);
}
} // namespace AdaptiveBufferResolution
