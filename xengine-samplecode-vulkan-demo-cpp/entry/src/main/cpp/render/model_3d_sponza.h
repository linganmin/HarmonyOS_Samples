/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

#ifndef RENDER_MODEL_3D_SPONZA_H
#define RENDER_MODEL_3D_SPONZA_H

#include "vulkanexamplebase.h"
#include "vulkan_obj_model.h"
#include "algorithm/fsr.h"
#include "xengine/xeg_vulkan_adaptive_vrs.h"
#include "xengine/xeg_vulkan_spatial_upscale.h"
#include "xengine/xeg_vulkan_extension.h"
#include "common/common.h"

#define ENABLE_VALIDATION false
#define VRS_TILE_SIZE 8
#define SENSITIVITY 0.4
#define LIGHT_NUM 40

class VulkanExample : public VulkanExampleBase {
public:
    VulkanExample() : VulkanExampleBase()
    {
        camera.type = Camera::CameraType::firstperson;
        camera.position = { 0.0f, 1.0f, 0.0f };
        camera.setRotation(glm::vec3(0.0f, -90.0f, 0.0f));
        
        enabledInstanceExtensions.push_back(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME);
        enabledDeviceExtensions.push_back(VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME);
        enabledDeviceExtensions.push_back(VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME);
    }

    ~VulkanExample();
    

    glm::mat4 m_model = glm::mat4(1.0f);
    glm::vec3 m_lightDir = glm::vec3(0.0f, -1.0f, 0.0f);
    glm::mat4 m_lightSpaceMatrix = glm::mat4(1.0f);

    vkOBJ::StaticModel m_scene;
    
    int use_method = 0;
    int cur_method = 0;
    bool use_vrs = false;
    bool cur_vrs = false;
    bool use_reprojectionMatrix = true;
    
    void UseVRS(bool useVRS)
    {
        use_vrs = useVRS;
        LOGI("VulkanExample curr use vrs: %{public}d", use_vrs);
    }
    
    void SetMethod(int method)
    {
        use_method = method;
        LOGI("VulkanExample curr set method: %{public}d", use_method);
    }

    FSR *fsr;
    XEG_SpatialUpscale xegSpatialUpscale;
    XEG_AdaptiveVRS xeg_adaptiveVRS;
    XEG_AdaptiveVRS xeg_adaptiveVRS4Upscale;
    XEG_AdaptiveVRSCreateInfo xeg_createInfo;

    struct UBOSceneParams {
        glm::mat4 projection;
        glm::mat4 model;
        glm::mat4 view;
    } uboSceneParams;

    struct PointLight {
        alignas(16) glm::vec3 position;
        alignas(16) glm::vec3 ambient;
        alignas(16) glm::vec3 diffuse;
        alignas(16) glm::vec3 specular;
        alignas(4) float constant;
        alignas(4) float linear;
        alignas(4) float quadratic;
    };

    glm::vec3 pointLightPositions[LIGHT_NUM] = {
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
    
    struct DirLight {
        alignas(16) glm::vec3 lightDir;
        alignas(16) glm::vec3 ambient;
        alignas(16) glm::vec3 diffuse;
        alignas(16) glm::vec3 specular;
    } dirLight;

    struct UBOLightParams {
        alignas(16) glm::vec3 viewPos;
        PointLight pointLights[LIGHT_NUM];
        DirLight dirLight;
        alignas(16) glm::mat4 lightSpaceMatrix;
    } uboLightParams;
    
    struct {
        VkPipeline gBufferLight;
        VkPipeline light;
        VkPipeline swap;
    } pipelines;

    struct {
        VkPipeline gBufferLight;
        VkPipeline light;
        VkPipeline swapUpscale;
    } upscalePipelines;

    struct {
        VkPipelineLayout gBufferLight;
        VkPipelineLayout light;
        VkPipelineLayout swap;
    } pipelineLayouts;

    struct {
        VkDescriptorSet gBufferLight = VK_NULL_HANDLE;
        VkDescriptorSet light = VK_NULL_HANDLE;
        VkDescriptorSet swap = VK_NULL_HANDLE;
    } descriptorSets;

    struct {
        VkDescriptorSet light = VK_NULL_HANDLE;
        VkDescriptorSet swapUpscale = VK_NULL_HANDLE;
    } upscaleDescriptorSets;

    struct {
        VkDescriptorSetLayout gBufferLight;
        VkDescriptorSetLayout light;
        VkDescriptorSetLayout swap;
    } descriptorSetLayouts;

    struct {
        vks::Buffer sceneParams;
        vks::Buffer lightParams;
    } uniformBuffers;
    
    struct FrameBufferAttachment {
        VkImage image;
        VkDeviceMemory mem;
        VkImageView view;
        VkFormat format;
        void Destroy(VkDevice device)
        {
            vkDestroyImage(device, image, nullptr);
            vkDestroyImageView(device, view, nullptr);
            vkFreeMemory(device, mem, nullptr);
            image = VK_NULL_HANDLE;
            view = VK_NULL_HANDLE;
            mem = VK_NULL_HANDLE;
        }
    };
    
    struct FrameBuffer {
        int32_t width, height;
        VkFramebuffer frameBuffer;
        VkRenderPass renderPass;
        void setSize(int32_t w, int32_t h)
        {
            this->width = w;
            this->height = h;
        }
        void destroy(VkDevice device)
        {
            vkDestroyFramebuffer(device, frameBuffer, nullptr);
            vkDestroyRenderPass(device, renderPass, nullptr);
            frameBuffer = VK_NULL_HANDLE;
            renderPass = VK_NULL_HANDLE;
        }
    };

    struct {
        struct Offscreen : public FrameBuffer {
            FrameBufferAttachment position, normal, viewNormal, albedo, depth;
        } gBufferLight;
        struct Render : public FrameBuffer {
            FrameBufferAttachment color;
        } light, shadingRate;
    } frameBuffers;
    
    struct {
        struct Offscreen : public FrameBuffer {
            FrameBufferAttachment position, normal, viewNormal, albedo, depth;
        } gBufferLight;
        struct Render : public FrameBuffer {
            FrameBufferAttachment color;
        } light, upscale, shadingRate;
    } upscaleFrameBuffers;
    
    VkSampler colorSampler;

public:
    
    virtual void render()
    {
        if (!prepared) {
            return;
        }
        if (cur_method != use_method || cur_vrs != use_vrs) {
            buildCommandBuffers();
            LOGI("VulkanExample rebuild command buffers");
            cur_method = use_method;
            cur_vrs = use_vrs;
        }

        Draw();
        if (camera.updated) {
            UpdateUniformBufferMatrices();
        }
    }

    virtual void viewChanged()
    {
        UpdateUniformBufferMatrices();
    }

    bool prepare();
    void getEnabledFeatures();
    void buildCommandBuffers();

private:
    VkPhysicalDeviceFragmentShadingRatePropertiesKHR physicalDeviceShadingRateImageProperties{};
    VkPhysicalDeviceFragmentShadingRateFeaturesKHR enabledPhysicalDeviceShadingRateImageFeaturesKHR{};
    void InitXEGVRS();
    void DispatchVRS(bool upscale, VkCommandBuffer commandBuffer);
    void PrepareShadingRateImage(uint32_t sriWidth, uint32_t sriHeight, FrameBufferAttachment *attachment);
    void CreateAttachment(VkFormat format, VkImageUsageFlagBits usage,
        FrameBufferAttachment *attachment, uint32_t width, uint32_t height);
    void PrepareOffscreenFramebuffers();
    void LoadAssets();
    void BuildUpscaleCommandBuffers();
    void SetupDescriptorPool();
    void SetupLayouts();
    void SetupDescriptors();
    void PreparePipelines();
    void PrepareUniformBuffers();
    void InitLight();
    void UpdateLightUniformBufferParams();
    void UpdateUniformBufferMatrices();
    void Draw();
    void InitFSR();
    void InitSpatialUpscale();
    bool CheckXEngine();
    std::array<VkVertexInputAttributeDescription, 3> GetAttributeDescriptions();
    VkPipelineVertexInputStateCreateInfo m_pipelineVertexInputStateCreateInfo = {};
    VkVertexInputBindingDescription m_vertexInputBindingDescription = {};
    std::vector<VkVertexInputAttributeDescription> m_vertexInputAttributeDescriptions;
};
#endif // RENDER_MODEL_3D_SPONZA_H
