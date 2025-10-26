/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "include/render_thread.h"
#include <GLES2/gl2ext.h>
#include <sys/poll.h>
#include <unistd.h>

namespace NativeXComponentSample {
constexpr char DEMO_NAME[] = "HMOSLiveStream";
constexpr uint32_t LOG_PRINT_DOMAIN = 0xFF00;
const std::string TEXTURE_2D_SRC = "#define TEXTURE_2D_SRC 1\n";
const std::string VERSION_GLSL = "#version 300 es\n";
const std::string VERSION310_GLSL = "#version 310 es\n";
constexpr GLuint RECTANGLE_INDICES[] = {
    0, 1, 2,  // first triangle
    0, 2, 3   // second triangle
};
namespace Detail {
static void CreateGLTex(GLenum target, uint32_t& outTextureId, bool openMipmap = false)
{
    uint32_t textureId = 0;
    glGenTextures(1, &textureId);
    glBindTexture(target, textureId);
    glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    if (openMipmap) {
        // default: trilinear sammpling
        glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    } else {
        // default: use bilinear sampling
        glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    glBindTexture(target, 0);
    outTextureId = textureId;
}

static void LeftProd(float* lmatrix, float* rmatrix, float* out)
{
    for (int y = 0; y < 4; y++) {
        for (int z = 0; z < 4; z++) {
            float res = 0;
            for (int x = 0; x < 4; x++) {
                res += lmatrix[y * 4 + x] * rmatrix[x * 4 + z];
            }
            out[y * 4 + z] = res;
        }
    }
}

std::string vertexShader = R"delimiter(
attribute vec3 position;
attribute vec2 texCoord;
varying vec2 vTexCoord;
uniform mat4 matTransform;

void main()
{
    gl_Position = vec4(position, 1.0);
    vec4 rotatedUV = matTransform * vec4(texCoord, 0.0, 1.0);
    vTexCoord = rotatedUV.xy;
}
)delimiter";

std::string fragmentShader = R"delimiter(
#extension GL_EXT_YUV_target : require

#extension GL_OES_EGL_image_external_essl3 : require
precision highp float;
in vec2 vTexCoord;

#if defined(TEXTURE_2D_SRC) && TEXTURE_2D_SRC
uniform sampler2D tex;
#else
//uniform samplerExternalOES tex;
uniform __samplerExternal2DY2YEXT tex;
#endif

layout(yuv) out vec4 outColor;
// out vec4 outColor;

vec3 rgb2yuv_bt2020_limited(vec3 rgb)
{
    vec3 RGB2Y = vec3(0.224951, 0.580575, 0.050779);
    vec3 RGB2U = vec3(-0.122296, -0.315632, 0.437928);
    vec3 RGB2V = vec3(0.437928, -0.402706, -0.035222);
    float outY = dot(RGB2Y, rgb) + 0.062561;
    float outU = dot(RGB2U, rgb) + 0.500489;
    float outV = dot(RGB2V, rgb) + 0.500489;
    vec3 YUV;
    YUV.x = clamp(outY, 0.0, 1.0);
    YUV.y = clamp(outU, 0.0, 1.0);
    YUV.z = clamp(outV, 0.0, 1.0);
    return YUV;
}

void main()
{
    vec4 color = texture(tex, vTexCoord);
#if (defined(TEXTURE_2D_SRC) && TEXTURE_2D_SRC)
    color = vec4(rgb2yuv_bt2020_limited(color.rgb), color.a);
#endif
    outColor = color;
}
)delimiter";

std::string fragmentShaderBW = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision mediump float;
varying vec2 vTexCoord;
uniform samplerExternalOES texture;
void main()
{
    vec4 tc = texture2D(texture, vTexCoord);
    float color = tc.r * 0.3 + tc.g * 0.59 + tc.b * 0.11;
    gl_FragColor = vec4(color, color, color, 1.0);
}
)delimiter";

std::string frameFragmentShader = R"delimiter(
#extension GL_OES_EGL_image_external : require
precision highp float;
varying vec2 vTexCoord;

uniform samplerExternalOES texture;
void main()
{
    gl_FragColor = texture2D(texture, vTexCoord);
}
)delimiter";

GLfloat vertices[] = {
    // positions       // texture coords
    -1.0f, 1.0f,  0.0f, 0.0f, 0.0f, // top left
    -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, // bottom left
    1.0f, -1.0f, 0.0f, 1.0f, 1.0f, // bottom right
    1.0f, 1.0f,  0.0f, 1.0f, 0.0f  // top right
};

GLuint indices[] = {
    0, 1, 2,  // first triangle
    0, 2, 3   // second triangle
};
} // namespace Detail

RenderThread::RenderThread()
{
    Start();
}

RenderThread::~RenderThread() noexcept
{
    running_ = false;
    if (thread_.joinable()) {
        thread_.join();
    }
}

bool RenderThread::InitRenderContext()
{
    renderContext_ = std::make_unique<EglRenderContext>();
    return renderContext_->Init();
}

void RenderThread::DestroyRenderContext()
{
    renderContext_.reset();
}

void RenderThread::CleanGLResources()
{
    glDeleteVertexArrays(1, &vertexArrayObject_);
    glDeleteBuffers(1, &vertexBufferObject_);
    glDeleteTextures(1, &inTexId_);
    glDeleteTextures(1, &outTexId_);
    videoShader_.reset();
    imageShader_.reset();
}

bool RenderThread::CreateGLResources()
{
    videoShader_ = std::make_unique<NativeXComponentSample::ShaderProgram>(VERSION_GLSL + Detail::vertexShader,
                                                                           VERSION_GLSL + Detail::fragmentShader);
    imageShader_ = std::make_unique<NativeXComponentSample::ShaderProgram>(
        VERSION_GLSL + Detail::vertexShader, VERSION_GLSL + TEXTURE_2D_SRC + Detail::fragmentShader);
    frameShader_ = std::make_unique<NativeXComponentSample::ShaderProgram>(
        Detail::vertexShader, Detail::frameFragmentShader);

    if (!videoShader_->Valid() || !imageShader_->Valid()) {
        return false;
    }

    glGenVertexArrays(1, &vertexArrayObject_);
    glGenBuffers(1, &vertexBufferObject_);

    glBindVertexArray(vertexArrayObject_);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject_);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Detail::vertices), Detail::vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
 
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    if (nativeImageTexId_ == 9999) {
        Detail::CreateGLTex(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "nativeImageTexId_:%{public}d",
                     nativeImageTexId_);
    }
    if (noiseImageTexId_ == 9999) {
        Detail::CreateGLTex(GL_TEXTURE_2D, noiseImageTexId_, true);
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "noiseImageTexId_:%{public}d",
                     noiseImageTexId_);
    }
    if (outTexId_ == 9999 && inTexId_ == 9999) {
        Detail::CreateGLTex(GL_TEXTURE_EXTERNAL_OES, inTexId_);
        Detail::CreateGLTex(GL_TEXTURE_EXTERNAL_OES, outTexId_);
        glGenFramebuffers(1, &vertexFrameObject_);
    }

    UpdateImageResource(nullptr, 0, 0, 0);
    return true;
}

void RenderThread::UpdateNativeWindow(void *window, uint64_t width, uint64_t height)
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "UpdateNativeWindow,window:%{public}p.", window);
    auto nativeWindow = reinterpret_cast<OHNativeWindow *>(window);
    xcomponentWindows_ = nativeWindow;
    
    int xcomponentHeight, xcomponentWidth;
    OH_NativeWindow_NativeWindowHandleOpt(
        xcomponentWindows_, GET_BUFFER_GEOMETRY, &xcomponentHeight, &xcomponentWidth);
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread",
                 "12xcomponentHeight_:%{public}d, xcomponentWidth_:%{public}d", xcomponentHeight, xcomponentWidth);
    
    PostTask([this, nativeWindow, width, height](EglRenderContext &renderContext) {
        if (nativeWindow_ != nativeWindow) {
            nativeWindow_ = nativeWindow;
            if (eglSurface_ != EGL_NO_SURFACE) {
                renderContext_->DestroyEglSurface(eglSurface_);
                eglSurface_ = EGL_NO_SURFACE;
                CleanGLResources();
            }
        }
        if (nativeWindow_ != nullptr) {
            // [Start Display_native_window]
            // SDR set BT709
            int32_t ret = OH_NativeWindow_SetColorSpace(nativeWindow_, OH_COLORSPACE_BT709_LIMIT);
            // [End Display_native_window]

            ret |=
                OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_YCBCR_420_SP);
            if (ret != 0) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                             "nativeWindow_:%{public}p, ret:%{public}d", nativeWindow_, ret);
            }
            if (eglSurface_ == EGL_NO_SURFACE) {
                eglSurface_ = renderContext_->CreateEglSurface(static_cast<EGLNativeWindowType>(nativeWindow_));
            }
            if (eglSurface_ == EGL_NO_SURFACE) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "xfl CreateEglSurface failed.");
                return;
            }
            renderContext_->MakeCurrent(eglSurface_);
            CreateGLResources();

        }
    });
}

void RenderThread::CreateEncoderSurface(void *window, int32_t width, int32_t height)
{
    if (encoderSurface_ != EGL_NO_SURFACE) {
        renderContext_->DestroyEglSurface(encoderSurface_);
        encoderSurface_ = EGL_NO_SURFACE;
    }
    if (renderContext_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "renderContext_ is nullptr");
        return;
    }

    auto nativeWindow = reinterpret_cast<OHNativeWindow *>(window);
    PostTask([this, nativeWindow, width, height](EglRenderContext &renderContext) {
        if (encoderNativeWindow_ != nativeWindow) {
            if (encoderNativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectUnreference(encoderNativeWindow_);
            }
            encoderNativeWindow_ = nativeWindow;
            if (encoderNativeWindow_ != nullptr) {
                (void)OH_NativeWindow_NativeObjectReference(encoderNativeWindow_);
            }

            if (encoderSurface_ != EGL_NO_SURFACE) {
                renderContext_->DestroyEglSurface(encoderSurface_);
                encoderSurface_ = EGL_NO_SURFACE;
            }
        }
        if (encoderNativeWindow_ != nullptr) {
            // [Start Encode_native_window]
            (void)OH_NativeWindow_NativeWindowHandleOpt(encoderNativeWindow_, SET_BUFFER_GEOMETRY,
                                                        static_cast<int>(width), static_cast<int>(height));
            // [End Encode_native_window]

            // SDR set BT709
            int32_t ret = OH_NativeWindow_SetColorSpace(nativeWindow_, OH_COLORSPACE_BT709_LIMIT);
            ret |=
                OH_NativeWindow_NativeWindowHandleOpt(nativeWindow_, SET_FORMAT, NATIVEBUFFER_PIXEL_FMT_YCBCR_420_SP);
            if (ret != 0) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                             "encoderNativeWindow_:%{public}p, ret:%{public}d", nativeWindow_, ret);
            }
            if (encoderSurface_ == EGL_NO_SURFACE) {
                encoderSurface_ =
                    renderContext_->CreateEglSurface(static_cast<EGLNativeWindowType>(encoderNativeWindow_));
            }
            if (encoderSurface_ == EGL_NO_SURFACE) {
                OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "xfl CreateEglSurface failed.");
                return;
            }
        }
    });
    encoderWidth = width;
    encoderHeight = height;
}

void RenderThread::DeleteEncoderSurface(void)
{
    renderContext_->DestroyEglSurface(encoderSurface_);
    encoderSurface_ = EGL_NO_SURFACE;
}

void RenderThread::AddBW(void)
{
    PostTask([this](EglRenderContext &renderContext) {
        videoShader_.reset();
        if (isVertexShader) {
            isVertexShader = false;
            videoShader_ =
                std::make_unique<NativeXComponentSample::ShaderProgram>(Detail::vertexShader, Detail::fragmentShader);
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Shader shader fragmentShader.");
        } else {
            isVertexShader = true;
            videoShader_ =
                std::make_unique<NativeXComponentSample::ShaderProgram>(Detail::vertexShader, Detail::fragmentShaderBW);
            OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Shader shader fragmentShaderBW.");
        }
    });
}

void RenderThread::Start()
{
    if (running_) {
        return;
    }

    running_ = true;
    thread_ = std::thread([this]() {
        ThreadMainLoop();
        // Ensure that the creation and destruction of renderContext are executed on the rendering thread
        CleanGLResources();
        DestroyNativeImage();
        if (nativeWindow_ != nullptr) {
            OH_NativeWindow_DestroyNativeWindow(nativeWindow_);
            nativeWindow_ = nullptr;
        }
        if (encoderNativeWindow_ != nullptr) {
            (void)OH_NativeWindow_NativeObjectUnreference(encoderNativeWindow_);
            nativeWindow_ = nullptr;
        }
        DestroyRenderContext();
        running_ = false;
    });
}

void RenderThread::OnVsync(long long timestamp, void *data)
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OnVsync %{public}llu.", timestamp);
    auto renderThread = static_cast<RenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }

    renderThread->vSyncCnt_++;
    renderThread->wakeUpCond_.notify_one();
}

bool RenderThread::InitNativeVsync()
{
    nativeVsync_ = OH_NativeVSync_Create(DEMO_NAME, strlen(DEMO_NAME));
    if (nativeVsync_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "Create NativeVSync failed.");
        return false;
    }
    (void)OH_NativeVSync_RequestFrame(nativeVsync_, &RenderThread::OnVsync, this);
    return true;
}

void RenderThread::DestroyNativeVsync()
{
    if (nativeVsync_ != nullptr) {
        OH_NativeVSync_Destroy(nativeVsync_);
        nativeVsync_ = nullptr;
    }
}

void RenderThread::OnNativeImageFrameAvailable(void *data)
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "OnNativeImageFrameAvailable.");
    auto renderThread = static_cast<RenderThread *>(data);
    if (renderThread == nullptr) {
        return;
    }
    renderThread->availableFrameCnt_++;
    renderThread->wakeUpCond_.notify_one();    
}
// [Start Create_Native_Image]
bool RenderThread::CreateNativeImage()
{
    nativeImage_ = OH_NativeImage_Create(-1, GL_TEXTURE_EXTERNAL_OES);
    if (nativeImage_ == nullptr) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "OH_NativeImage_Create failed.");
        return false;
    }
    int ret = 0;
    {
        std::lock_guard<std::mutex> lock(nativeImageSurfaceIdMutex_);
        nativeImageWindow_ = OH_NativeImage_AcquireNativeWindow(nativeImage_);
        ret = OH_NativeImage_GetSurfaceId(nativeImage_, &nativeImageSurfaceId_);
    }
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
            "OH_NativeImage_GetSurfaceId failed, ret is %{public}d.", ret);
        return false;
    }

    nativeImageFrameAvailableListener_.context = this;
    nativeImageFrameAvailableListener_.onFrameAvailable = &RenderThread::OnNativeImageFrameAvailable;
    ret = OH_NativeImage_SetOnFrameAvailableListener(nativeImage_, nativeImageFrameAvailableListener_);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_SetOnFrameAvailableListener failed, ret is %{public}d.", ret);
        return false;
    }

    return true;
}
// [End Create_Native_Image]

void RenderThread::DestroyNativeImage()
{
    if (nativeImageTexId_ != 0U) {
        glDeleteTextures(1, &nativeImageTexId_);
        nativeImageTexId_ = 0U;
    }

    if (nativeImage_ != nullptr) {
        (void)OH_NativeImage_UnsetOnFrameAvailableListener(nativeImage_);
        OH_NativeImage_Destroy(&nativeImage_);
        nativeImage_ = nullptr;
    }
}

void RenderThread::ThreadMainLoop()
{
    threadId_ = std::this_thread::get_id();
    if (!InitRenderContext()) {
        return;
    }
    if (!CreateNativeImage()) {
        return;
    }
    ConfigSceneMatrix();
    while (running_) {
        {
            OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "Waiting for vsync.");
            std::unique_lock<std::mutex> lock(wakeUpMutex_);
            wakeUpCond_.wait(lock, [this]() { return wakeUp_ || availableFrameCnt_ > 0; });
            wakeUp_ = false;
        }

        OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "Executing tasks.");
        std::vector<RenderTask> tasks;
        {
            std::lock_guard<std::mutex> lock(taskMutex_);
            tasks.swap(tasks_);
        }
        for (const auto &task : tasks) {
            task(*renderContext_);
        }

        if (availableFrameCnt_ <= 0) {
            continue;
        }
        DrawImage();
        availableFrameCnt_--;
    }
}

void RenderThread::PostTask(const RenderTask &task)
{
    if (!running_) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread",
            "PostTask failed: RenderThread is not running");
        return;
    }
    
    {
        std::lock_guard<std::mutex> lock(taskMutex_);
        tasks_.push_back(task);
    }

    if (std::this_thread::get_id() != threadId_) {
        std::lock_guard<std::mutex> lock(wakeUpMutex_);
        wakeUp_ = true;
        wakeUpCond_.notify_one();
    }
}

 void RenderThread::ConfigSceneMatrix()
{
    std::array<float, 16> translate_matrix = {
        1.0, 0.0, 0.0, 0.5,
        0.0, 1.0, 0.0, 0.5,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    };
    std::array<float, 16> scale_matrix = {
        0.333, 0.0, 0.0, 0.0,
        0.0, 0.25, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    };
    std::array<float, 16> rotate_matrix = {
        -1.0, 0.0, 0.0, 0.0,
        0.0, -1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0
    };
    std::array<float, 16> imageMatrixTmp;
    std::array<float, 16> imageMatrix;
    Detail::LeftProd(rotate_matrix.data(), scale_matrix.data(), imageMatrixTmp.data());
    Detail::LeftProd(translate_matrix.data(), imageMatrixTmp.data(), imageMatrix.data());
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "isCameraFront_:%{public}d.",
                 isCameraFront_.load());
    drawImageMatrix_ = imageMatrix;
}

void RenderThread::DrawScene()
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    videoShader_->Use();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, nativeImageTexId_);
    videoShader_->SetInt("tex", 0);
    videoShader_->SetMatrix4v("matTransform", drawCameraImageMatrix_.data(), 16, false);
    glBindVertexArray(vertexArrayObject_);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, RECTANGLE_INDICES);

    imageShader_->Use();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, noiseImageTexId_);
    imageShader_->SetInt("tex", 0);
    imageShader_->SetMatrix4v("matTransform", drawImageMatrix_.data(), 16, true);
    glBindVertexArray(vertexArrayObject_);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, RECTANGLE_INDICES);
    glFinish();
}

void RenderThread::UpdateImageResource(void* data, int32_t width, int32_t height, int32_t stride, bool mipmap)
{
    glBindTexture(GL_TEXTURE_2D, noiseImageTexId_);
    if (!data) {
        constexpr uint32_t w = 32, h = 32;
        constexpr uint32_t r = 720, g = 1023, b = 0, a = 3;
        constexpr uint32_t mockColor = (a << 30) | (b << 20) | (g << 10) | r;
        std::vector<uint32_t> data(w * h, mockColor);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB10_A2, w, h, 0, GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV_EXT, data.data());
    } else {
        glPixelStorei(GL_UNPACK_ROW_LENGTH, stride >> 2);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB10_A2, width, height, 0,
            GL_RGBA, GL_UNSIGNED_INT_2_10_10_10_REV_EXT, data);
        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
    }
    if (mipmap) {
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
}

void RenderThread::ImageDraw(OHNativeWindowBuffer *InBuffer, OHNativeWindowBuffer *OutBuffer,
    int32_t imageWidth, int32_t imageHeight, int32_t viewWidth, int32_t viewHeight)
{
    EGLImageKHR imgIn = renderContext_->CreateEGLImage(InBuffer);
    EGLImageKHR imgOut = renderContext_->CreateEGLImage(OutBuffer);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, inTexId_);
    renderContext_->EGLImageTargetTexture2DOES(imgIn);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, GL_NONE);
    glBindFramebuffer(GL_FRAMEBUFFER, vertexFrameObject_);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, outTexId_);
    renderContext_->EGLImageTargetTexture2DOES(imgOut);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_EXTERNAL_OES, outTexId_, 0);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread", "glCheckFramebufferStatus failed");
        return;
    }
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, GL_NONE);
    
    // Center alignment
    float imageAspect = (float) imageWidth / imageHeight;
    float viewAspect = (float) viewWidth / viewHeight;
    int viewportX, viewportY, viewportWidth, viewportHeight;
    if (imageAspect > viewAspect) {
        viewportHeight = viewHeight;
        viewportWidth = static_cast<int>(viewportHeight * imageAspect);
        viewportX = -(viewportWidth - viewWidth) / 2;
        viewportY = 0;
    } else {
        viewportWidth = viewWidth;
        viewportHeight = static_cast<int> (viewWidth / imageAspect);
        viewportX = 0;
        viewportY = -(viewportHeight - viewHeight) / 2;
    }
    OH_LOG_Print(
        LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread",
        "DrawImagefhm. %{public}d %{public}d %{public}d %{public}d => %{public}d %{public}d %{public}d %{public}d",
        imageWidth, imageHeight, viewWidth, viewHeight, viewportX, viewportY, viewportWidth, viewportHeight);
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(viewportX, viewportY, viewportWidth, viewportHeight);
    frameShader_->Use();
    frameShader_->SetMatrix4v("matTransform", drawCameraImageMatrix_.data(), 16, false);
    glBindVertexArray(vertexArrayObject_);
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, inTexId_);
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, Detail::indices);
    
    glBindTexture(GL_TEXTURE_EXTERNAL_OES, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glUseProgram(0);
    glFinish();
    renderContext_->DeleteEGLImage(imgIn);
    renderContext_->DeleteEGLImage(imgOut);
}

void RenderThread::DrawImage()
{
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread", "DrawImage.");
    if (eglSurface_ == EGL_NO_SURFACE) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN, "RenderThread", "eglSurface_ is EGL_NO_SURFACE");
        return;
    }

    // Get camera output buffer
    OHNativeWindowBuffer *InBuffer;
    int32_t fenceFd1 = -1;
    int32_t ret = OH_NativeImage_AcquireNativeWindowBuffer(nativeImage_, &InBuffer, &fenceFd1);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeImage_AcquireNativeWindowBuffer failed, ret: %{public}d", ret);
        return;
    }

    if (OH_NativeImage_GetTransformMatrixV2(nativeImage_, drawCameraImageMatrix_.data())) {
        OH_LOG_Print(LOG_APP, LOG_WARN, LOG_PRINT_DOMAIN,
                     "RenderThread", "OH_NativeImage_GetTransformMatrix failed!");
        return;
    }

    ret = OH_NativeWindow_NativeObjectReference(InBuffer);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeWindow_NativeObjectReference failed, ret: %{public}d", ret);
        return;
    }
   
    // Get encoding input buffer
    OHNativeWindowBuffer *OutBuffer;
    OHNativeWindowBuffer *OutBufferEncoder;
    int32_t fenceFd2 = -1;
    int32_t fenceFd3 = -1;
    ret = OH_NativeWindow_NativeWindowRequestBuffer(nativeWindow_, &OutBuffer, &fenceFd2);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeWindow_NativeWindowRequestBuffer failed, ret: %{public}d", ret);
        return;
    }
    int retCode = -1;
    uint32_t timeout = 3000;
    if (fenceFd2 != -1) {
        struct pollfd pollfds = {0};
        pollfds.fd = fenceFd2;
        pollfds.events = POLLIN;
        do {
            retCode = poll(&pollfds, 1, timeout);
        } while (retCode == -1 && (errno == EINTR || errno == EAGAIN));
        close(fenceFd2); // Prevent file descriptor leaks
    }

    ret = OH_NativeWindow_NativeWindowRequestBuffer(encoderNativeWindow_, &OutBufferEncoder, &fenceFd3);
    if (ret != 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeWindow_NativeWindowRequestBuffer failed, ret: %{public}d", ret);
        return;
    }
    if (fenceFd3 != -1) {
        struct pollfd pollfds = {0};
        pollfds.fd = fenceFd3;
        pollfds.events = POLLIN;
        do {
            retCode = poll(&pollfds, 1, timeout);
        } while (retCode == -1 && (errno == EINTR || errno == EAGAIN));
        close(fenceFd3); // Prevent file descriptor leaks
    }
    int viewWidth = 0;
    int viewHeight = 0;
    OH_NativeWindow_NativeWindowHandleOpt(encoderNativeWindow_, GET_BUFFER_GEOMETRY, &viewHeight, &viewWidth);
    OH_LOG_Print(LOG_APP, LOG_INFO, LOG_PRINT_DOMAIN, "RenderThread", "viewHeight:%{public}d, viewWidth:%{public}d",
                 viewHeight, viewWidth);

    ret = OH_NativeWindow_NativeWindowHandleOpt(xcomponentWindows_, GET_BUFFER_GEOMETRY, &xcomponentHeight_,
                                                &xcomponentWidth_);
    if (ret != 0 || xcomponentHeight_ == 0 || xcomponentWidth_ == 0) {
        OH_LOG_Print(LOG_APP, LOG_ERROR, LOG_PRINT_DOMAIN, "RenderThread",
                     "OH_NativeWindow_NativeWindowHandleOpt get Xcomponent size failed!");
    }
    OH_LOG_Print(LOG_APP, LOG_DEBUG, LOG_PRINT_DOMAIN, "RenderThread",
                 "xcomponentHeight_:%{public}d, xcomponentWidth_:%{public}d", xcomponentHeight_, xcomponentWidth_);
    int imageRotation = cameraRotation_;
    if (imageRotation == 0 || imageRotation == 180) {
        ImageDraw(InBuffer, OutBuffer, viewHeight, viewWidth, xcomponentWidth_, xcomponentHeight_);
        ImageDraw(InBuffer, OutBufferEncoder, viewHeight, viewWidth, viewWidth, viewHeight);
    } else {
        ImageDraw(InBuffer, OutBuffer, viewWidth, viewHeight, xcomponentWidth_, xcomponentHeight_);
        ImageDraw(InBuffer, OutBufferEncoder, viewWidth, viewHeight, viewWidth, viewHeight);
    }

    OH_NativeWindow_NativeObjectUnreference(InBuffer);
    OH_NativeImage_ReleaseNativeWindowBuffer(nativeImage_, InBuffer, fenceFd1);
    // Set the refresh region; if the Rect in Region is nullptr or rectNumber is 0, it is considered that the entire
    // OHNativeWindowBuffer has content changes.
    Region region{nullptr, 0};
    int acquireFenceFd1 = -1;
    int acquireFenceFd2 = -1;
    // Submit to the consumer for use via OH_NativeWindow_NativeWindowFlushBuffer, for example, to display on the
    // screen.
    OH_NativeWindow_NativeWindowFlushBuffer(nativeWindow_, OutBuffer, acquireFenceFd1, region);
    OH_NativeWindow_NativeWindowFlushBuffer(encoderNativeWindow_, OutBufferEncoder, acquireFenceFd2, region);
}

OH_NativeImage *RenderThread::GetNativeImageEncoder()
{
    return nativeImage_;
}

void RenderThread::SetCameraFront(bool isCameraFront)
{
    isCameraFront_ = isCameraFront;
}

void RenderThread::UpdateCameraRotation(int rotation)
{
    cameraRotation_ = rotation;
}
} // namespace NativeXComponentSample
