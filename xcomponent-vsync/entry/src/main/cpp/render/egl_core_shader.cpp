/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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
#include <hilog/log.h>
#include "egl_core_shader.h"
#include "plugin_common.h"

const char *GAME_SYNC_NAME = "openglVSync";

const GLfloat squareVerticles[] = {
    1.0f, -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, 1.0f,
};

// ELG drawing program.
char vertexShader[] = "#version 300 es\n"
                      "layout(location = 0) in vec4 a_position;\n"
                      "layout(location = 1) in vec4 a_color;\n"
                      "out vec4 fragCoord;\n"
                      "out vec4 v_color;\n"
                      "void main()\n"
                      "{\n"
                      "   gl_Position = a_position;\n"
                      "   fragCoord = a_position;\n"
                      "   v_color = a_color;\n"
                      "}\n";

// ELG drawing program.
char fragmentShader[] = "#version 300 es\n"
                        "precision mediump float;\n"
                        "uniform vec3 iResolution;\n"
                        "uniform float iTime;\n"
                        "in vec4 v_color;\n"
                        "in vec4 fragCoord;\n"
                        "out vec4 fragColor;\n"
                        "const float PI = 3.1415;\n"
                        "const float OMEGA = 4.0;\n"
                        "const float STEP = 10.0;\n"
                        "const float TIME_SCALE = 0.003;\n"
                        "\n"
                        "vec3 drawCircle(vec2 uv, vec3 color0, vec3 color, float r, vec2 p, float w)\n"
                        "{\n"
                        "\treturn vec3(color * w /  abs(distance(uv, p) - r)) + color0;\n"
                        "}\n"
                        "\n"
                        "vec3 drawPoint(vec2 uv, vec3 color0, vec3 color, float r, vec2 p)\n"
                        "{\n"
                        "\treturn vec3(color * r /  distance(uv, p)) + color0;\n"
                        "}\n"
                        "\n"
                        "vec3 drawSegment(vec2 uv, vec3 color0, vec3 color, vec2 p0, vec2 p1, float w)\n"
                        "{\n"
                        "\tvec2 a = uv - p0;\n"
                        "\tvec2 b = p1 - p0;\n"
                        "\tvec2 c = b * max(min(dot(a, b) / dot(b, b), 1.0), 0.0);\n"
                        "\tfloat d = distance(a, c);\n"
                        "\treturn color * (w / d) + color0;\n"
                        "}\n"
                        "\n"
                        "vec3 drawFourier(vec2 uv, vec3 color0, float amp, float t, float omega, vec2 p)\n"
                        "{\n"
                        "\tvec2 pp = uv - p;\n"
                        "\t\n"
                        "\tvec3 dstColor = color0;\n"
                        "\n"
                        "\tfloat y = 0.0;\n"
                        "\tvec2 p0 = vec2(p.x, 0.0);\n"
                        "\t\n"
                        "\tfor(float i = 0.0; i < STEP; i++) {\n"
                        "\t\tfloat n = 2.0 * i + 1.0;\n"
                        "\t\tfloat ampn = amp / n;\n"
                        "\t\tvec2 p1 = vec2(p0.x + ampn * cos(n * t), p0.y + ampn * sin(n * t));\n"
                        "\t\ty += ampn * sin(n * (omega * pp.x + t));\n"
                        "\n"
                        "\t\tdstColor = drawCircle(uv, dstColor, vec3(0.5), ampn, p0, 0.00125);\n"
                        "\t\tdstColor = drawPoint(uv, dstColor, vec3(0.5), 0.00125, p1);\n"
                        "\t\tdstColor = drawSegment(uv, dstColor, vec3(1.0, 0.0, 0.0), p0, p1, 0.001);\n"
                        "\t\tp0 =  p1;\n"
                        "\t}\n"
                        "\t\n"
                        "\tvec2 p1 = vec2(p.x + 2.0 * PI / omega, p0.y);\n"
                        "\tdstColor = drawPoint(uv, dstColor, vec3(1.0), 0.0125, p1);\n"
                        "\tdstColor = drawSegment(uv, dstColor, vec3(1.0), p0, p1, 0.0025);\n"
                        "\t\n"
                        "\tfloat dist = distance(pp, vec2(pp.x, y));\n"
                        "\tdstColor += 0.005 / dist;\n"
                        "\treturn dstColor;\n"
                        "}\n"
                        "\n"
                        "void main()\n"
                        "{\n"
                        "\tvec2 p = (2.0 * fragCoord.xy - 1.0)  * vec2(1.0, iResolution.y / iResolution.x);\n"
                        "\tvec3 color = vec3(0.0);\n"
                        "\tfloat t = iTime * TIME_SCALE;\n"
                        "\n"
                        "\tfloat r = 0.6;\n"
                        "\tvec2 offset = vec2(-0.5, 0.0);\n"
                        "\tcolor = drawFourier(p, color, r, t * OMEGA, OMEGA, offset);\n"
                        "\t\n"
                        "\tfragColor = vec4(color, 1.0);\n"
                        "}";

struct SyncParam {
    EGLCore *eglCore = nullptr;
    void *window = nullptr;
};

static EGLConfig getConfig(EGLDisplay eglDisplay) {
    int attribList[] = {EGL_SURFACE_TYPE,
                        EGL_WINDOW_BIT,
                        EGL_RED_SIZE,
                        8,
                        EGL_GREEN_SIZE,
                        8,
                        EGL_BLUE_SIZE,
                        8,
                        EGL_ALPHA_SIZE,
                        8,
                        EGL_RENDERABLE_TYPE,
                        EGL_OPENGL_ES2_BIT,
                        EGL_NONE};
    EGLConfig configs = NULL;
    int configsNum;
    if (!eglChooseConfig(eglDisplay, attribList, &configs, 1, &configsNum)) {
        LOGE("eglChooseConfig ERROR");
        return NULL;
    }
    return configs;
}

// Create an EGLSurface instance. The drawing information is first drawn on the EGLSurface and displayed through
// EGLDisplay.
void EGLCore::OnSurfaceCreated(void *window, int w, int h) {
    LOGD("EGLCore::GLContextInit window = %{public}p, w = %{public}d, h = %{public}d.", window, w, h);
    width_ = w;
    height_ = h;
    iTime = 0;
    SyncParam *param = new SyncParam();
    param->eglCore = this;
    param->window = window;
    mVsync = OH_NativeVSync_Create(GAME_SYNC_NAME, 3);
    if (!mVsync) {
        LOGE("EGLCore:: Create mVsync failed");
        return;
    }
    
    OH_NativeVSync_RequestFrame(
        mVsync,
        [](long long timestamp, void *data) {
            LOGI("EGLCore::OH_NativeVSync_RequestFrame timestamp = %{public}lld", timestamp);
            SyncParam *syncParam = (SyncParam *)data;
            if (syncParam == nullptr) {
                return;
            }
            EGLCore *eglCore = syncParam->eglCore;
            void *window = syncParam->window;
            if (eglCore == nullptr || window == nullptr) {
                return;
            }
            eglCore->mEglWindow = static_cast<EGLNativeWindowType>(window);

            // 1. create shared context
            eglCore->mEGLDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
            if (eglCore->mEGLDisplay == EGL_NO_DISPLAY) {
                LOGE("EGLCore::unable to get EGL display.");
                return;
            }

            EGLint eglMajVers, eglMinVers;
            if (!eglInitialize(eglCore->mEGLDisplay, &eglMajVers, &eglMinVers)) {
                eglCore->mEGLDisplay = EGL_NO_DISPLAY;
                LOGE("EGLCore::unable to initialize display");
                return;
            }

            eglCore->mEGLConfig = getConfig(eglCore->mEGLDisplay);
            if (eglCore->mEGLConfig == nullptr) {
                LOGE("EGLCore::GLContextInit config ERROR");
                return;
            }

            // 2. Create EGL Surface from Native Window
            EGLint winAttribs[] = {EGL_GL_COLORSPACE_KHR, EGL_GL_COLORSPACE_SRGB_KHR, EGL_NONE};
            if (eglCore->mEglWindow) {
                eglCore->mEGLSurface =
                    eglCreateWindowSurface(eglCore->mEGLDisplay, eglCore->mEGLConfig, eglCore->mEglWindow, winAttribs);
                if (eglCore->mEGLSurface == nullptr) {
                    LOGE("EGLCore::eglCreateContext eglSurface is null");
                    return;
                }
            }

            // 3. Create EGLContext from
            int attrib3_list[] = {EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE};
            eglCore->mEGLContext =
                eglCreateContext(eglCore->mEGLDisplay, eglCore->mEGLConfig, eglCore->mSharedEGLContext, attrib3_list);
            if (!eglMakeCurrent(eglCore->mEGLDisplay, eglCore->mEGLSurface, eglCore->mEGLSurface,
                                eglCore->mEGLContext)) {
                LOGE("EGLCore::eglMakeCurrent error = %{public}d", eglGetError());
            }
            eglCore->mProgramHandle = eglCore->CreateProgram(vertexShader, fragmentShader);
            if (!eglCore->mProgramHandle) {
                LOGE("EGLCore::Could not create CreateProgram");
                return;
            }

            eglCore->DrawSquare();
            eglCore->switchSpecular();
            eglCore->switchAmbient();
        },
        param);
}

// Draw geometric shapes.
void EGLCore::DrawSquare() {
    GLfloat color[] = {0.5f, 0.6f, 0.3f, 1.0f};

    const GLfloat squareVerticles[] = {
        1.0f, -1.0f, -1.0f, -1.0f, 1.0f, 1.0f, -1.0f, 1.0f,
    };
    glViewport(0, 0, width_, height_);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(mProgramHandle);
    positionHandle = glGetAttribLocation(mProgramHandle, "a_position");
    glVertexAttribPointer(positionHandle, 2, GL_FLOAT, GL_FALSE, 2 * 4, squareVerticles);
    glEnableVertexAttribArray(positionHandle);
    glVertexAttrib4fv(1, color);

    iTimeHandle = glGetUniformLocation(mProgramHandle, "iTime");
    glUniform1f(iTimeHandle, iTime);
    GLint resolutionHandle = glGetUniformLocation(mProgramHandle, "iResolution");
    glUniform3f(resolutionHandle, static_cast<GLfloat>(width_), static_cast<GLfloat>(height_), 1.0f);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionHandle);
    glFlush();
    glFinish();
    Update();
}

// EGL achieves diffuse reflection effect.
void EGLCore::switchDiffuse() {
    GLfloat color[] = {0.5f, 0.6f, 0.3f, 1.0f};
    const GLfloat triangleVertices[] = {0.0f, 1.0f, -1.0f, -1.0f, 1.0f, -1.0f};

    glViewport(0, 0, width_, height_);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(mProgramHandle);
    GLint positionHandle = glGetAttribLocation(mProgramHandle, "a_position");
    glVertexAttribPointer(positionHandle, 2, GL_FLOAT, GL_FALSE, 0, triangleVertices);
    glEnableVertexAttribArray(positionHandle);
    glVertexAttrib4fv(1, color);

    iTimeHandle = glGetUniformLocation(mProgramHandle, "iTime");
    glUniform1f(iTimeHandle, iTime);
    GLint resolutionHandle = glGetUniformLocation(mProgramHandle, "iResolution");
    glUniform3f(resolutionHandle, static_cast<GLfloat>(width_), static_cast<GLfloat>(height_), 1.0f);

    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(positionHandle);
    glDisableVertexAttribArray(resolutionHandle);
    glFlush();
    glFinish();
    Update();
}

// EGL achieves ambient light effects.
void EGLCore::switchAmbient() {
    if (!eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
        LOGE("EGLCore::eglMakeCurrent error = %{public}d", eglGetError());
    }
    iTime++;
    if (iTime > 500.0f) {
        iTime = 0;
    }
    GLfloat tempColor = sin(iTime / 100.0f);
    LOGE("EGLCore::switchAmbient tempColor = %{public}f", tempColor);
    GLfloat color[] = {0.7f * tempColor, 0.2f * tempColor, 0.2f * tempColor, 1.0f};

    const GLfloat triangleVertices[] = {-1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 0.0f};

    glViewport(0, 0, width_, height_);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(mProgramHandle);
    GLint positionHandle = glGetAttribLocation(mProgramHandle, "a_position");
    glVertexAttribPointer(positionHandle, 2, GL_FLOAT, GL_FALSE, 0, triangleVertices);
    glEnableVertexAttribArray(positionHandle);
    glVertexAttrib4fv(1, color);
    glUniform1f(iTimeHandle, iTime);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(positionHandle);
    Update();
}

// EGL realizes specular lighting effect.
void EGLCore::switchSpecular() {
    if (!eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
        LOGE("EGLCore::eglMakeCurrent switchSpecular error = %{public}d", eglGetError());
    }
    LOGI("EGLCore::mEGLDisplay iTime %{public}f", iTime);

    iTime++;
    GLfloat tempColor = sin(iTime / 100);
    LOGI("EGLCore::switchAmbient tempColor = %{public}f", tempColor);

    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(mProgramHandle);
    glEnableVertexAttribArray(positionHandle);
    glVertexAttribPointer(positionHandle, 2, GL_FLOAT, GL_FALSE, 2 * 4, squareVerticles);

    glUniform1f(iTimeHandle, iTime);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(positionHandle);
    Update();
    OH_NativeVSync_RequestFrame(
        mVsync,
        [](long long timestamp, void *data) {
            LOGI("EGLCore::OH_NativeVSync_RequestFrame error = %{public}lld", timestamp);
            (reinterpret_cast<EGLCore *>(data))->switchSpecular();
        },
        (void *)this);
}

/* Exchange the data in the canvas in the memory EGLSurface to EGLDisplay and output it to the screen to display the
 * drawn content.
 */
void EGLCore::Update() { eglSwapBuffers(mEGLDisplay, mEGLSurface); }

// Get shader.
GLuint EGLCore::LoadShader(GLenum type, const char *shaderSrc) {
    GLuint shader_;
    GLint compiled_;

    shader_ = glCreateShader(type);
    LOGE(" Create the shader object");
    if (shader_ == 0) {
        LOGE("LoadShader shader_ error");
        return 0;
    }
    glShaderSource(shader_, 1, &shaderSrc, nullptr);
    LOGE("Load the shader source success");
    glCompileShader(shader_);
    LOGE("Compile the shader success");
    glGetShaderiv(shader_, GL_COMPILE_STATUS, &compiled_);
    LOGE("Check the  Compile status success");
    if (!compiled_) {
        LOGE("the  Compile is null");
        GLint infoLen = 0;
        glGetShaderiv(shader_, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader_, infoLen, nullptr, infoLog);
            LOGE("glGetShaderInfoLog success");
            free(infoLog);
        }
        glDeleteShader(shader_);
        return 0;
    }
    return shader_;
}

GLuint EGLCore::CreateProgram(const char *vertexShader, const char *fragShader) {
    GLuint vertex_;
    GLuint fragment_;
    GLuint program_;
    GLint linked_;
    vertex_ = LoadShader(GL_VERTEX_SHADER, vertexShader);
    fragment_ = LoadShader(GL_FRAGMENT_SHADER, fragShader);
    program_ = glCreateProgram();
    if (vertex_ == 0 || fragment_ == 0 || program_ == 0) {
        CreateProgramError(vertexShader, fragShader);
        return 0;
    }
    glAttachShader(program_, vertex_);
    LOGE("glAttachShader  success");
    glAttachShader(program_, fragment_);
    LOGE("glAttachShader2  success");
    glLinkProgram(program_);
    LOGE("glLinkProgram  success");
    glGetProgramiv(program_, GL_LINK_STATUS, &linked_);
    LOGE("glGetProgramiv  success");
    if (!linked_) {
        LOGE("CreateProgram linked error");
        GLint infoLen = 0;
        glGetProgramiv(program_, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program_, infoLen, nullptr, infoLog);
            free(infoLog);
        }
        glDeleteShader(vertex_);
        glDeleteShader(fragment_);
        glDeleteProgram(program_);
        return 0;
    }
    glDeleteShader(vertex_);
    glDeleteShader(fragment_);

    return program_;
}

GLuint EGLCore::CreateProgramError(const char *vertexShader, const char *fragShader) {
    GLuint vertex;
    GLuint fragment;
    GLuint program;

    vertex = LoadShader(GL_VERTEX_SHADER, vertexShader);
    if (vertex == 0) {
        LOGE("CreateProgram vertex error");
        return 0;
    }

    fragment = LoadShader(GL_FRAGMENT_SHADER, fragShader);
    if (fragment == 0) {
        LOGE("CreateProgram fragment error");
        glDeleteShader(vertex);
        return 0;
    }

    program = glCreateProgram();
    if (program == 0) {
        LOGE("CreateProgram program error");
        glDeleteShader(vertex);
        glDeleteShader(fragment);
        return 0;
    }
    return 0;
}

// Destroy the vsync instance.
void EGLCore::OnSurfaceDestroyed() {
    LOGI("EGLCore::OnSurfaceDestroyed");
    if (nullptr != mVsync) {
        OH_NativeVSync_Destroy(mVsync);
        mVsync = nullptr;
    }
    if (!eglDestroyContext(mEGLDisplay, mEGLContext)) {
        LOGE("EGLCore::OnSurfaceDestroyed error = %{public}x", eglGetError());
    }
}

void EGLCore::OnSurfaceChanged(void *window, int32_t w, int32_t h) { LOGI("EGLCore::OnSurfaceDestroyed"); }