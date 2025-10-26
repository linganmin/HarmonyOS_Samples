/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <chrono>
#include <string>
#include <unistd.h>
#include <EGL/egl.h>
#include "file/file_operator.h"
#include "shader/shader_draw.h"
#include "shader/shader_gbuffer.h"
#include "shader/shader_light.h"
#include "shader/shader_fsr.h"
#include "model_3d_sponza.h"

Model3DSponza::Model3DSponza() {}

Model3DSponza::~Model3DSponza()
{
    LOGI("Model3DSponza release");
    Destroy();
}

bool Model3DSponza::Init(int screenW, int screenH)
{
    if (m_shaderWindow != nullptr && m_pModel != nullptr) {
        return true;
    }

    if (!CheckXEngine()) {
        return false;
    }

    fp_eglCreateImageKHR = reinterpret_cast<PFNEGLCREATEIMAGEKHRPROC>(eglGetProcAddress("eglCreateImageKHR"));
    if (fp_eglCreateImageKHR == nullptr) {
        LOGE("eglCreateImageKHR not found!");
    }
    fp_eglDestroyImageKHR = reinterpret_cast<PFNEGLDESTROYIMAGEKHRPROC>(eglGetProcAddress("eglDestroyImageKHR"));
    if (fp_eglDestroyImageKHR == nullptr) {
        LOGE("eglDestroyImageKHR not found!");
    }
    fp_glEGLImageTargetTexture2DOES =
        reinterpret_cast<PFNGLEGLIMAGETARGETTEXTURE2DOESPROC>(eglGetProcAddress("glEGLImageTargetTexture2DOES"));
    if (fp_glEGLImageTargetTexture2DOES == nullptr) {
        LOGE("glEGLImageTargetTexture2DOES not found!");
    }

    m_shaderGBufferLight= new Shader(gBufferVS.c_str(), gBufferFS.c_str());
    m_shaderLight= new Shader(lightVS.c_str(), lightFS.c_str());
    m_shaderFSREASU  = new Shader(fsrVS.c_str(), fsrEASUFS.c_str());
    m_shaderFSRRCAS = new Shader(fsrVS.c_str(), fsrRCASFS.c_str());
    m_shaderWindow= new Shader(drawVS.c_str(), drawFS.c_str());
    SetShaderTexture();
    std::string path = FileOperator::GetInstance()->GetFileAbsolutePath("/model/Sponza/sponza.obj");
    m_camera.position = { 1.0f, -0.75f, 0.0f };
    m_camera.SetMovement(m_moveSpeed, m_maxMoveDistance);
    m_camera.SetRotation(glm::vec3(0.0f, 90.0f, 0.0f));
    m_camera.SetPerspective(m_fov, screenW / screenH, m_near_plane, m_far_plane);
    m_pModel = new Model(path);
    if (m_pModel == nullptr) {
        LOGE("Model3DSponza get model failed, model is null");
    } else {
        LOGI("Model3DSponza get model success");
    }
    return true;
}

bool Model3DSponza::CheckXEngine()
{
    std::string extensions = (const char *)HMS_XEG_GetString(XEG_EXTENSIONS);
    LOGI("Model3DSponza support extensions: %{public}s", extensions.c_str());
    std::string::size_type spatialIdx = extensions.find(XEG_SPATIAL_UPSCALE_EXTENSION_NAME);
    std::string::size_type neuralIdx = extensions.find(XEG_NEURAL_UPSCALE_EXTENSION_NAME);
    std::string::size_type adaptiveVRSIdx = extensions.find(XEG_ADAPTIVE_VRS_EXTENSION_NAME);
    if (spatialIdx == std::string::npos || adaptiveVRSIdx == std::string::npos || neuralIdx == std::string::npos) {
        LOGE("Model3DSponza not support selected extension.");
        return false;
    } else {
        LOGI("Model3DSponza support selected extension.");
    }
    
    return true;
}

void Model3DSponza::DispatchVRS()
{
    LOGD("Model3DSponza dispatch compute shading rate image.");
    if (ADAPTIVE_VRS_USE_REPROJECTMATRIX) {
        if (m_camera.curVP.perspective == glm::mat4(0)) {
            float *reprojectionM = const_cast<float *>(glm::value_ptr(glm::mat4(0)));
            HMS_XEG_DispatchAdaptiveVRS(reprojectionM, m_lightColorTexture, m_rboDepth, m_shadingRateImageTexture);
        } else {
            glm::mat4 currVP = m_camera.curVP.perspective * m_camera.curVP.view;
            glm::mat4 inv = glm::inverse(currVP);
            glm::mat4 preVP = m_camera.preVP.perspective * m_camera.preVP.view;
            glm::mat4 reproject = preVP * inv;
            float *reprojectionM = (float *)glm::value_ptr(reproject);
            HMS_XEG_DispatchAdaptiveVRS(reprojectionM, m_lightColorTexture, m_rboDepth, m_shadingRateImageTexture);
        }
    } else {
        HMS_XEG_DispatchAdaptiveVRS(NULL, m_lightColorTexture, m_rboDepth, m_shadingRateImageTexture);
    }
}

void Model3DSponza::Draw(int screenW, int screenH)
{
    auto tStart = std::chrono::high_resolution_clock::now();
    if (m_screenWidth != screenW && m_screenHeight != screenH) {
        m_initialized = false;
    }
    m_screenWidth = screenW;
    m_screenHeight = screenH;
    
    if (m_pModel == nullptr) {
        LOGE("Model3DSponza get model failed");
        return;
    }
    
    if (!m_initialized) {
        m_lowResWidth = m_screenWidth * m_highScale;
        m_lowResHeight = m_screenHeight * m_highScale;
        m_highResWidth = m_screenWidth * m_highScale;
        m_highResHeight = m_screenHeight * m_highScale;
        InitVerticesBuffer();
        InitFrameBuffer();
        m_initialized = true;
        LOGI("Model3DSponza initialized");
    }
    
    if (m_currmode != m_upscalemode) {
        if (m_upscalemode > 0) {
            m_lowResWidth = m_screenWidth * m_lowScale;
            m_lowResHeight = m_screenHeight * m_lowScale;
            m_highResWidth = m_screenWidth * m_highScale;
            m_highResHeight = m_screenHeight * m_highScale;
            LOGI("Model3DSponza use upscale is true");
        } else {
            m_lowResWidth = m_screenWidth * m_highScale;
            m_lowResHeight = m_screenHeight * m_highScale;
            m_highResWidth = m_screenWidth * m_highScale;
            m_highResHeight = m_screenHeight * m_highScale;
            LOGI("Model3DSponza use upscale is false");
        }
        LOGI("Model3DSponza recreate framebuffer end");
        DeleteFrameAndTexture();
        InitVerticesBuffer();
        InitFrameBuffer();
        m_currmode = m_upscalemode;
    }

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    glClearColor(0.05f, 0.05f, 0.05f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw GBuffer
    glBindFramebuffer(GL_FRAMEBUFFER, m_gBufferFBO);
    glViewport(0, 0, m_lowResWidth, m_lowResHeight);
    glScissor(0, 0, m_lowResWidth, m_lowResHeight);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glm::mat4 model = glm::scale(glm::mat4(1.0f), glm::vec3(0.01f, 0.01f, 0.01f));
    m_shaderGBufferLight->Use();
    m_shaderGBufferLight->SetMat4("projection", m_camera.matrices.perspective);
    m_shaderGBufferLight->SetMat4("view", m_camera.matrices.view);
    m_shaderGBufferLight->SetMat4("model", model);
    m_pModel->Draw((*m_shaderGBufferLight));
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    if (m_useVRS) {
        DispatchVRS();
    }

    // draw light
    glBindFramebuffer(GL_FRAMEBUFFER, m_lightFBO);
        // apply sri
        if (m_useVRS) {
            HMS_XEG_ApplyAdaptiveVRS(m_shadingRateImageTexture);
        } else {
            HMS_XEG_ApplyAdaptiveVRS(0);
        }
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        m_shaderLight->Use();
        m_shaderLight->SetVec3("viewPos", m_camera.position);
        m_shaderLight->SetVec3("dirLight.lightdir", m_lightDir);
        m_shaderLight->SetVec3("dirLight.ambient", 0.05f, 0.05f, 0.05f);
        m_shaderLight->SetVec3("dirLight.diffuse", 0.4f, 0.4f, 0.4f);
        m_shaderLight->SetVec3("dirLight.specular", 0.5f, 0.5f, 0.5f);
        for (int i = 0; i < LIGHT_NUM; i++) {
            m_shaderLight->SetVec3("pointLights[" + std::to_string(i) + "].position", m_pointLightPositions[i]);
            m_shaderLight->SetVec3("pointLights[" + std::to_string(i) + "].ambient", 0.05f, 0.05f, 0.05f);
            m_shaderLight->SetVec3("pointLights[" + std::to_string(i) + "].diffuse", 0.4f, 0.4f, 0.4f);
            m_shaderLight->SetVec3("pointLights[" + std::to_string(i) + "].specular", 0.5f, 0.5f, 0.5f);
            m_shaderLight->SetFloat("pointLights[" + std::to_string(i) + "].constant", 20.0f);
            m_shaderLight->SetFloat("pointLights[" + std::to_string(i) + "].linear", 0.15f);
            m_shaderLight->SetFloat("pointLights[" + std::to_string(i) + "].quadratic", 0.32f);
        }
        glBindVertexArray(m_quadVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, m_gPosition);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, m_gNormal);
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, m_gAlbedo);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArray(0);
    
    switch (m_upscalemode) {
        case NEURAL_UPSCALE:
            DispatchNeuralUpscale();
            break;
        case SPATIAL_UPSCALE:
            DispatchSpatialUpscale();
            break;
        case FSR_UPSCALE:
            DispatchFSR();
            break;
        default:
            LOGD("Model3DSponza render no upscale");
    }

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, screenW, screenH);
        glScissor(0, 0, screenW, screenH);
        glClear(GL_COLOR_BUFFER_BIT);
        m_shaderWindow->Use();
        glActiveTexture(GL_TEXTURE0);
        if (m_upscalemode > 0) {
            glBindTexture(GL_TEXTURE_2D, m_upscaleColorTexture);
        } else {
            glBindTexture(GL_TEXTURE_2D, m_lightColorTexture);
        }
        glBindVertexArray(m_quadVAO);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArray(0);

    m_camera.Update();
    auto tEnd = std::chrono::high_resolution_clock::now();
    auto tDiff = std::chrono::duration<double, std::milli>(tEnd - tStart).count();
    LOGD("Model3DSponza cost time: %{public}f", tDiff);
}

void Model3DSponza::DispatchFSR()
{
    glBindFramebuffer(GL_FRAMEBUFFER, m_fsrEASUFBO);
    glViewport(0, 0, m_highResWidth, m_highResHeight);
    glScissor(0, 0, m_highResWidth, m_highResHeight);
    m_shaderFSREASU->Use();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_lightColorTexture);
    m_shaderFSREASU->SetVec4("ubo.uTextureSize", m_lowResWidth, m_lowResHeight, 1.0f / m_lowResWidth,
                             1.0f / m_lowResHeight);
    m_shaderFSREASU->SetVec4("ubo.uTextureRegion", 0, 0, m_lowResWidth, m_lowResHeight);
    glDrawArrays(GL_TRIANGLES, 0, 3);

    glBindFramebuffer(GL_FRAMEBUFFER, m_upscaleFBO);
    m_shaderFSRRCAS->Use();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fsrEASUColorTexture);
    m_shaderFSRRCAS->SetFloat("uSharpness", m_sharpness);
    m_shaderFSRRCAS->SetVec4("uTextureSize", m_highResWidth, m_highResHeight, 1.0f / m_highResWidth,
                             1.0f / m_highResHeight);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    LOGD("Model3DSponza render fsr.");
}

void Model3DSponza::DispatchSpatialUpscale()
{
    glBindFramebuffer(GL_FRAMEBUFFER, m_upscaleFBO);
    glViewport(0, 0, m_highResWidth, m_highResHeight);
    glScissor(0, 0, m_highResWidth, m_highResHeight);
    HMS_XEG_RenderSpatialUpscale(m_lightColorTexture);
    LOGD("Model3DSponza render spatial upscale.");
}

void Model3DSponza::DispatchNeuralUpscale()
{
    glBindFramebuffer(GL_FRAMEBUFFER, m_upscaleFBO);
    glViewport(0, 0, m_highResWidth, m_highResHeight);
    glScissor(0, 0, m_highResWidth, m_highResHeight);
    HMS_XEG_RenderNeuralUpscale(m_lightColorTexture);
    LOGD("Model3DSponza render neural upscale.");
}

void Model3DSponza::InitVerticesBuffer()
{
    float quadVertices[] = {
        -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
        1.0f,  1.0f, 0.0f, 1.0f, 1.0f, 1.0f,  -1.0f, 0.0f, 1.0f, 0.0f,
    };
    glGenVertexArrays(1, &m_quadVAO);
    glGenBuffers(1, &m_quadVBO);
    glBindVertexArray(m_quadVAO);
    glBindBuffer(GL_ARRAY_BUFFER, m_quadVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
}

void Model3DSponza::CheckFrameBuffer(std::string bufferName)
{
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        LOGE("Model3DSponza create frameBuffer %{public}s failed", bufferName.c_str());
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

unsigned int Model3DSponza::CreateFrameBuffer()
{
    unsigned int frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    return frameBuffer;
}

unsigned int Model3DSponza::CreateFramebufferTexture(unsigned int width, unsigned int height, GLint internalformat,
    GLenum format, GLenum index, GLenum type, bool isNative)
{
    unsigned int texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    if (isNative) {
        OH_NativeBuffer_Config config = {};
        config.width = width;
        config.height = height;
        config.usage = NATIVEBUFFER_USAGE_CPU_READ | NATIVEBUFFER_USAGE_CPU_READ_OFTEN | NATIVEBUFFER_USAGE_HW_TEXTURE |
                       NATIVEBUFFER_USAGE_HW_RENDER | NATIVEBUFFER_USAGE_ALIGNMENT_512;
        config.format = NATIVEBUFFER_PIXEL_FMT_RGBA_8888;
        m_lightNativeBufferHandle = OH_NativeBuffer_Alloc(&config);
        if (m_lightNativeBufferHandle == nullptr) {
            LOGE("OH_NativeBuffer_Alloc failed, size:(%{public}d, %{public}d) ", width, height);
        }
        m_nativeWindowBuffer  =
            OH_NativeWindow_CreateNativeWindowBufferFromNativeBuffer(m_lightNativeBufferHandle);
        if (m_nativeWindowBuffer == nullptr) {
            LOGE("Error to Create nativeWindowBuffer");
        }
        m_eglImage = fp_eglCreateImageKHR(eglGetCurrentDisplay(), EGL_NO_CONTEXT, EGL_NATIVE_BUFFER_OHOS,
                                          static_cast<EGLClientBuffer>(m_nativeWindowBuffer), nullptr);
        if (m_eglImage == nullptr) {
            LOGE("Error to Create m_eglImage");
        }
        fp_glEGLImageTargetTexture2DOES(GL_TEXTURE_2D, m_eglImage);
    } else {
        glTexImage2D(GL_TEXTURE_2D, 0, internalformat, width, height, 0, format, type, NULL);
    }
    glFramebufferTexture2D(GL_FRAMEBUFFER, index, GL_TEXTURE_2D, texture, 0);
    return texture;
}

unsigned int Model3DSponza::CreateStorage2DTexture(int width, int height, GLenum internalformat,
    GLsizei levels)
{
    unsigned int texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexStorage2D(GL_TEXTURE_2D, levels, internalformat, width, height);
    return texture;
}

void Model3DSponza::InitFrameBuffer()
{
    LOGI("Model3DSponza initFrameBuffer");
    m_camera.SetPerspective(m_fov, m_screenWidth / m_screenHeight, m_near_plane, m_far_plane);
    // Create GBuffer Frame And Textures
    m_gBufferFBO = CreateFrameBuffer();
    m_gPosition =  CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_RGBA16F, GL_RGBA,
        GL_COLOR_ATTACHMENT0, GL_FLOAT);
    m_gNormal = CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_RGBA16F, GL_RGBA,
        GL_COLOR_ATTACHMENT1, GL_FLOAT);
    m_gAlbedo = CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_RGBA16F, GL_RGBA,
        GL_COLOR_ATTACHMENT2, GL_FLOAT);
    m_gNormalView = CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_RGBA16F, GL_RGBA,
        GL_COLOR_ATTACHMENT3, GL_FLOAT);
    unsigned int attachmentsLight[4] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2,
        GL_COLOR_ATTACHMENT3};
    glDrawBuffers(4, attachmentsLight);

    m_rboDepth = CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_DEPTH_COMPONENT, GL_DEPTH_COMPONENT,
        GL_DEPTH_ATTACHMENT, GL_UNSIGNED_SHORT);

    CheckFrameBuffer("GBuffer");
    
    // Create Light Frame And Textures
    m_lightFBO = CreateFrameBuffer();
    m_lightColorTexture = CreateFramebufferTexture(m_lowResWidth, m_lowResHeight, GL_RGB, GL_RGB,
        GL_COLOR_ATTACHMENT0, GL_UNSIGNED_BYTE, m_upscalemode == 1);
    CheckFrameBuffer("lightFBO");
    
    // Create Upscale Frame And Textures
    m_upscaleFBO = CreateFrameBuffer();
    m_upscaleColorTexture = CreateFramebufferTexture(m_highResWidth, m_highResHeight, GL_RGB, GL_RGB,
        GL_COLOR_ATTACHMENT0, GL_UNSIGNED_BYTE);
    CheckFrameBuffer("upscaleFBO");
    
    // Create FSR EASU Frame And Textures
    m_fsrEASUFBO = CreateFrameBuffer();
    m_fsrEASUColorTexture = CreateFramebufferTexture(m_highResWidth, m_highResHeight, GL_RGB, GL_RGB,
        GL_COLOR_ATTACHMENT0, GL_UNSIGNED_BYTE);
    CheckFrameBuffer("fsrEASUFBO");
    
    int upscaleScissor[4] = {0, 0, static_cast<int>(m_lowResWidth), static_cast<int>(m_lowResHeight)};
    // Init XEngine Spatial Upscale Params
    HMS_XEG_SpatialUpscaleParameter(XEG_SPATIAL_UPSCALE_SHARPNESS, &m_sharpness);
    HMS_XEG_SpatialUpscaleParameter(XEG_SPATIAL_UPSCALE_SCISSOR, upscaleScissor);

    // Init XEngine Neural Upscale Params
    HMS_XEG_NeuralUpscaleParameter(XEG_NEURAL_UPSCALE_SHARPNESS, &m_sharpness);
    HMS_XEG_NeuralUpscaleParameter(XEG_NEURAL_UPSCALE_SCISSOR, upscaleScissor);
    HMS_XEG_NeuralUpscaleParameter(XEG_NEURAL_UPSCALE_INPUT_HANDLE, m_lightNativeBufferHandle);

    // Init VRS ShadingRateImage
    int sriWidth = m_lowResWidth / ADAPTIVE_VRS_TEXEL_SIZE ;
    int sriHeight = m_lowResHeight / ADAPTIVE_VRS_TEXEL_SIZE ;
    m_shadingRateImageTexture = CreateStorage2DTexture(sriWidth, sriHeight, GL_R8UI, 1);
    std::vector<uint8_t> attachmentShadingRateData(sriWidth * sriHeight, 0);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, sriWidth, sriHeight, GL_RED_INTEGER,
                    GL_UNSIGNED_BYTE, attachmentShadingRateData.data());
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    // Init VRS Params
    GLsizei inputSize[2] = {static_cast<int>(m_lowResWidth), static_cast<int>(m_lowResHeight)};
    HMS_XEG_AdaptiveVRSParameter(XEG_ADAPTIVE_VRS_INPUT_SIZE, inputSize);
    GLuint inputRegion[4] = {0, 0, m_lowResWidth, m_lowResHeight};
    HMS_XEG_AdaptiveVRSParameter(XEG_ADAPTIVE_VRS_INPUT_REGION, inputRegion);
    GLboolean flip = false;
    HMS_XEG_AdaptiveVRSParameter(XEG_ADAPTIVE_VRS_FLIP, &flip);
    GLsizei texelSize[2] = {ADAPTIVE_VRS_TEXEL_SIZE, ADAPTIVE_VRS_TEXEL_SIZE};
    HMS_XEG_AdaptiveVRSParameter(XEG_ADAPTIVE_VRS_TEXEL_SIZE, texelSize);
    GLfloat sensitivity = 0.3;
    HMS_XEG_AdaptiveVRSParameter(XEG_ADAPTIVE_VRS_ERROR_SENSITIVITY, &sensitivity);
}

void Model3DSponza::SetShaderTexture()
{
    m_shaderLight->Use();
    m_shaderLight->SetInt("gPosition", 0);
    m_shaderLight->SetInt("gNormal", 1);
    m_shaderLight->SetInt("gAlbedo", 2);

    m_shaderWindow->Use();
    m_shaderWindow->SetInt("screenTexture", 0);

    m_shaderFSREASU->Use();
    m_shaderFSREASU->SetInt("uTexture", 0);

    m_shaderFSRRCAS->Use();
    m_shaderFSRRCAS->SetInt("uTexture", 0);
}

void Model3DSponza::Destroy()
{
    LOGD("Model3DSponza::Destroy");
    
    if (m_eglImage != nullptr) {
        fp_eglDestroyImageKHR(eglGetCurrentDisplay(), m_eglImage);
    }
    
    if (m_nativeWindowBuffer != nullptr) {
        OH_NativeWindow_DestroyNativeWindowBuffer(m_nativeWindowBuffer);
    }
    
    if (m_lightNativeBufferHandle != nullptr) {
        OH_NativeBuffer_Unreference(m_lightNativeBufferHandle);
    }
    
    if (m_pModel != nullptr) {
        m_pModel->Destroy();
        delete m_pModel;
        m_pModel = nullptr;
    }

    if (m_shaderGBufferLight != nullptr) {
        m_shaderGBufferLight->Destroy();
        delete m_shaderGBufferLight;
        m_shaderGBufferLight = nullptr;
    }

    if (m_shaderLight != nullptr) {
        m_shaderLight->Destroy();
        delete m_shaderLight;
        m_shaderLight = nullptr;
    }

    if (m_shaderWindow != nullptr) {
        m_shaderWindow->Destroy();
        delete m_shaderWindow;
        m_shaderWindow = nullptr;
    }

    DeleteFrameAndTexture();
}

void Model3DSponza::DeleteFrameAndTexture()
{
    glDeleteVertexArrays(1, &m_quadVAO);
    glDeleteBuffers(1, &m_quadVBO);
    glDeleteFramebuffers(1, &m_gBufferFBO);
    glDeleteFramebuffers(1, &m_lightFBO);
    glDeleteFramebuffers(1, &m_upscaleFBO);
    glDeleteFramebuffers(1, &m_fsrEASUFBO);
    glDeleteRenderbuffers(1, &m_rboDepth);

    glDeleteTextures(1, &m_gPosition);
    glDeleteTextures(1, &m_gNormal);
    glDeleteTextures(1, &m_gNormalView);
    glDeleteTextures(1, &m_gAlbedo);
    glDeleteTextures(1, &m_lightColorTexture);
    glDeleteTextures(1, &m_upscaleColorTexture);
    glDeleteTextures(1, &m_fsrEASUColorTexture);
    glDeleteTextures(1, &m_shadingRateImageTexture);
}