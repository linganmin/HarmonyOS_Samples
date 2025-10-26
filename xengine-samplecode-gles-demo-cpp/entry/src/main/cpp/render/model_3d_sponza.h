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

#ifndef RENDER_MODEL3DSPONZA_H
#define RENDER_MODEL3DSPONZA_H
#include <random>
#include <glm/glm.hpp>
#include <glm/detail/type_mat.hpp>
#include <glm/detail/type_mat4x4.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <native_buffer/native_buffer.h>
#include <native_window/external_window.h>
#include "xengine/xeg_gles_extension.h"
#include "xengine/xeg_gles_spatial_upscale.h"
#include "xengine/xeg_gles_adaptive_vrs.h"
#include "xengine/xeg_gles_neural_upscale.h"
#include "common/common.h"
#include "model/shader.h"
#include "model/model.h"
#include "model/camera.h"

#define LIGHT_NUM 40
#define ADAPTIVE_VRS_TEXEL_SIZE 8
#define ADAPTIVE_VRS_USE_REPROJECTMATRIX true
#define NEURAL_UPSCALE 1
#define SPATIAL_UPSCALE 2
#define FSR_UPSCALE 3


class Model3DSponza {
public:
    Model3DSponza();
    ~Model3DSponza();
    bool Init(int screenW, int screenH);
    void Draw(int screenW, int screenH);
    void Destroy();
    void SetUpscaleMode(int mode)
    {
        LOGD("Model3DSponza curr set upscale mode is %{public}d", mode);
        switch (mode) {
            case NEURAL_UPSCALE:
                // use Neural Upscale
                m_upscalemode = NEURAL_UPSCALE;
                break;
            case SPATIAL_UPSCALE:
                // use Spatial Upscale
                m_upscalemode = SPATIAL_UPSCALE;
                break;
            case FSR_UPSCALE:
                // use FSR Upscale
                m_upscalemode = FSR_UPSCALE;
                break;
            default:
                // not use any upscale method
                m_upscalemode = 0;
        }
    }
    
    void SetUseVRS(bool useVRS)
    {
        m_useVRS = useVRS;
        LOGD("Model3DSponza set use vrs is %{public}d", useVRS);
    }

private:
    void InitFrameBuffer();
    void DeleteFrameAndTexture();
    unsigned int CreateFrameBuffer();
    unsigned int CreateFramebufferTexture(unsigned int width, unsigned int height, GLint internalformat, GLenum format,
                               GLenum index, GLenum type, bool isNative = false);
    unsigned int CreateStorage2DTexture(int width, int height, GLenum internalformat, GLsizei levels);
    void InitVerticesBuffer();
    void DispatchVRS();
    void DispatchFSR();
    void DispatchSpatialUpscale();
    void DispatchNeuralUpscale();
    void CheckFrameBuffer(std::string bufferName);
    void SetShaderTexture();
    bool CheckXEngine();
    PFNEGLCREATEIMAGEKHRPROC fp_eglCreateImageKHR = nullptr;
    PFNGLEGLIMAGETARGETTEXTURE2DOESPROC fp_glEGLImageTargetTexture2DOES = nullptr;
    PFNEGLDESTROYIMAGEKHRPROC fp_eglDestroyImageKHR = nullptr;

private:
    Camera m_camera;
    unsigned int m_screenWidth;
    unsigned int m_screenHeight;
    unsigned int m_lowResWidth;
    unsigned int m_lowResHeight;
    unsigned int m_highResWidth;
    unsigned int m_highResHeight;
    float m_lowScale = 0.4f;
    float m_highScale = 0.6f;
    float m_near_plane = 0.1f;
    float m_far_plane = 64.0f;
    float m_fov = 60.0f;
    float m_moveSpeed = 0.002;
    int m_maxMoveDistance = 10;
    float m_sharpness = 0.4f;
    glm::vec3 m_lightDir = glm::vec3(0.0f, -1.0f, 0.0f);
    
    Shader *m_shaderGBufferLight = nullptr;
    Shader *m_shaderLight = nullptr;
    Shader *m_shaderWindow = nullptr;
    Shader *m_shaderFSREASU = nullptr;
    Shader *m_shaderFSRRCAS = nullptr;
    Model *m_pModel = nullptr;

    OH_NativeBuffer *m_lightNativeBufferHandle = nullptr;
    OHNativeWindowBuffer *m_nativeWindowBuffer = nullptr;
    EGLImageKHR m_eglImage = nullptr;
    
    glm::vec3 m_pointLightPositions[LIGHT_NUM] = {
        glm::vec3(0.0f, 2.0f, -0.2f),
        glm::vec3(1.0f, 2.0f, -0.2f),
        glm::vec3(2.0f, 2.0f, -0.2f),
        glm::vec3(3.0f, 2.0f, -0.2f),
        glm::vec3(4.0f, 2.0f, -0.2f),
        glm::vec3(5.0f, 2.0f, -0.2f),
        glm::vec3(6.0f, 2.0f, -0.2f),
        glm::vec3(7.0f, 2.0f, -0.2f),
        glm::vec3(8.0f, 2.0f, -0.2f),
        glm::vec3(9.0f, 2.0f, -0.2f),
        glm::vec3(0.0f, 3.0f, -0.2f),
        glm::vec3(-1.0f, 2.0f, -0.2f),
        glm::vec3(-2.0f, 2.0f, -0.2f),
        glm::vec3(-3.0f, 2.0f, -0.2f),
        glm::vec3(-4.0f, 2.0f, -0.2f),
        glm::vec3(-5.0f, 2.0f, -0.2f),
        glm::vec3(-6.0f, 2.0f, -0.2f),
        glm::vec3(-7.0f, 2.0f, -0.2f),
        glm::vec3(-8.0f, 2.0f, -0.2f),
        glm::vec3(-9.0f, 2.0f, -0.2f),
        glm::vec3(0.0f, 2.0f, 0.2f),
        glm::vec3(1.0f, 2.0f, 0.2f),
        glm::vec3(2.0f, 2.0f, 0.2f),
        glm::vec3(3.0f, 2.0f, 0.2f),
        glm::vec3(4.0f, 2.0f, 0.2f),
        glm::vec3(5.0f, 2.0f, 0.2f),
        glm::vec3(6.0f, 2.0f, 0.2f),
        glm::vec3(7.0f, 2.0f, 0.2f),
        glm::vec3(8.0f, 2.0f, 0.2f),
        glm::vec3(9.0f, 2.0f, 0.2f),
        glm::vec3(0.0f, 3.0f, 0.2f),
        glm::vec3(-1.0f, 2.0f, 0.2f),
        glm::vec3(-2.0f, 2.0f, 0.2f),
        glm::vec3(-3.0f, 2.0f, 0.2f),
        glm::vec3(-4.0f, 2.0f, 0.2f),
        glm::vec3(-5.0f, 2.0f, 0.2f),
        glm::vec3(-6.0f, 2.0f, 0.2f),
        glm::vec3(-7.0f, 2.0f, 0.2f),
        glm::vec3(-8.0f, 2.0f, 0.2f),
        glm::vec3(-9.0f, 2.0f, 0.2f),
    };
    unsigned int m_quadVAO, m_quadVBO;
    unsigned int m_gBufferFBO, m_gPosition, m_gNormal, m_gNormalView, m_gAlbedo, m_rboDepth;
    unsigned int m_lightFBO, m_lightColorTexture;
    unsigned int m_upscaleFBO, m_upscaleColorTexture;
    unsigned int m_fsrEASUFBO, m_fsrEASUColorTexture;
    unsigned int m_shadingRateImageTexture;
    bool m_initialized = false;
    bool m_useVRS = false;
    bool m_curVRS = false;
    int m_currmode = 0;
    int m_upscalemode = 0;
};


#endif // RENDER_MODEL3DSPONZA_H
