/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
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
#include "xengine/xeg_vulkan_temporal_upscale.h"
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

    void DestroyXegHandles();
    ~VulkanExample();

    float m_zNear = 0.1f;
    float m_zFar = 64.0f;
    glm::mat4 m_model = glm::mat4(1.0f);
    glm::vec3 m_lightDir = glm::vec3(0.0f, -1.0f, 0.0f);
    glm::mat4 m_lightSpaceMatrix = glm::mat4(1.0f);

    vkOBJ::StaticModel m_scene;
    
    const uint32_t jitterNum = 8;
    int use_method = 0;
    int cur_method = 0;
    bool use_vrs = false;
    bool cur_vrs = false;
    bool use_reprojectionMatrix = false;
    bool isSupportSpatial = true;
    bool isSupportVRS = true;
    bool isSupportTemporal = true;
    
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
    XEG_TemporalUpscale xegTemporalUpscale;
    
    struct UBOCameraMVParams {
        glm::mat4 vpMatInv;
        glm::mat4 vpMatNonJittered;
        glm::mat4 prevVPMatNonJittered;
    } uboCameraMVParams;

    struct UBOObjectMVParams {
        glm::mat4 vpMat;                // 当前帧VP矩阵（带jitter）
        glm::mat4 vpMatNonJittered;     // 当前帧VP矩阵（不带jitter）
        glm::mat4 prevVPMatNonJittered; // 上一帧VP矩阵（不带jitter）
        glm::mat4 modelMat;             // 当前帧model矩阵，动态物体
        glm::mat4 prevModelMat;         // 上一帧的model矩阵
    } uboObjectMVParams;

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
        VkPipeline gBufferDynamic;
        VkPipeline copyDepth;
        VkPipeline cameraMotionVector;
        VkPipeline objectMotionVector;
    } pipelines;

    struct {
        VkPipeline gBufferLight;
        VkPipeline light;
        VkPipeline swapUpscale;
        VkPipeline gBufferDynamic;
        VkPipeline copyDepth;
        VkPipeline cameraMotionVector;
        VkPipeline objectMotionVector;
    } upscalePipelines;

    struct {
        VkPipelineLayout gBufferLight;
        VkPipelineLayout light;
        VkPipelineLayout swap;
        VkPipelineLayout gBufferDynamic;
        VkPipelineLayout copyDepth;
        VkPipelineLayout cameraMotionVector;
        VkPipelineLayout objectMotionVector;
    } pipelineLayouts;

    struct {
        VkDescriptorSet gBufferLight = VK_NULL_HANDLE;
        VkDescriptorSet light = VK_NULL_HANDLE;
        VkDescriptorSet swap = VK_NULL_HANDLE;
        VkDescriptorSet copyDepth = VK_NULL_HANDLE;
        VkDescriptorSet cameraMotionVector = VK_NULL_HANDLE;
        VkDescriptorSet objectMotionVector = VK_NULL_HANDLE;
    } descriptorSets;

    struct {
        VkDescriptorSet gBufferLight = VK_NULL_HANDLE;
        VkDescriptorSet light = VK_NULL_HANDLE;
        VkDescriptorSet swapUpscale = VK_NULL_HANDLE;
        VkDescriptorSet copyDepth = VK_NULL_HANDLE;
        VkDescriptorSet cameraMotionVector = VK_NULL_HANDLE;
        VkDescriptorSet objectMotionVector = VK_NULL_HANDLE;
    } upscaleDescriptorSets;

    struct {
        VkDescriptorSetLayout gBufferLight;
        VkDescriptorSetLayout light;
        VkDescriptorSetLayout swap;
        VkDescriptorSetLayout copyDepth;
        VkDescriptorSetLayout cameraMotionVector;
        VkDescriptorSetLayout objectMotionVector;
    } descriptorSetLayouts;

    struct {
        vks::Buffer sceneParams;
        vks::Buffer lightParams;
        vks::Buffer cameraMVParams;
        vks::Buffer objectMVParams;
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
        u_int32_t width, height;
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
        struct CopyDepth : public FrameBuffer {
            FrameBufferAttachment depth;
        } copyDepth;
        struct Motion : public FrameBuffer {
            FrameBufferAttachment mv, dynamicMask;
        } motionVector;
    } upscaleFrameBuffers;

    struct {
        std::vector<VkImageView> imageViews;
        VkImageLayout imageLayout;
        VkDescriptorBufferInfo uniformDescriptor;
        bool needUbo;
    } descriptorSetInfo;
    
    VkSampler colorSampler;

public:
    
    virtual void render()
    {
        VulkanExampleBase::prepareFrame();
        if (imagesInFlight[currentBuffer] != VK_NULL_HANDLE) {
            vkWaitForFences(device, 1, &imagesInFlight[currentBuffer], VK_TRUE, UINT64_MAX);
        }
        imagesInFlight[currentBuffer] = waitFrameFences[activeIndex];
        if (!prepared) {
            return;
        }
        if (camera.updated) {
            UpdateUniformBufferMatrices();
        }
        // reset
        VK_CHECK_RESULT(vkResetFences(device, 1, &waitFrameFences[activeIndex]));
        Draw();
        if (use_method == 3) {
            frameNum++;
            if (frameNum > UINT64_MAX) {
                frameNum = 0;
            }
        }
        activeIndex = (activeIndex + 1) % MAX_FRAMES_IN_FLIGHT;
    }

    virtual void viewChanged()
    {
        UpdateUniformBufferMatrices();
    }

    bool Prepare();
    void GetEnabledFeatures();
    std::vector<VkClearValue> GetClearValues();
    void BuildCommandBuffers();

private:
    VkPhysicalDeviceFragmentShadingRatePropertiesKHR physicalDeviceShadingRateImageProperties{};
    VkPhysicalDeviceFragmentShadingRateFeaturesKHR enabledPhysicalDeviceShadingRateImageFeaturesKHR{};

    float jitterX = 0.0;
    float jitterY = 0.0;
    const float MAX_ANGLE = 30.0f; // glm::radians(180.0f);
    float currentAngle = 0.0f;
    bool isRotatingLeft = true;
    uint64_t frameNum = 0;

    void InitXEGVRS();
    void DispatchVRS(bool upscale, VkCommandBuffer commandBuffer);
    void PrepareShadingRateImage(uint32_t sriWidth, uint32_t sriHeight, FrameBufferAttachment *attachment);
    void CreateAttachment(VkFormat format, VkImageUsageFlagBits usage,
        FrameBufferAttachment *attachment, uint32_t width, uint32_t height);
    void ResizeFrameBuffers();
    void CreateRenderPassAttachment();
    VkAttachmentDescription CreateVkAttachmentDescription(VkImageLayout finalLayout, VkFormat format);
    std::vector<VkSubpassDependency> CreateSubpassDependency(VkPipelineStageFlags dstStageMask, VkAccessFlags dstAccessMask);
    VkRenderPassCreateInfo CreateRenderPassInfo(VkAttachmentDescription* pAttachments,
        uint32_t attachmentCount, VkSubpassDescription &subpass, VkSubpassDependency* pDependencies);
    VkFramebufferCreateInfo CreateFrameBufferInfo(
        VkRenderPass, uint32_t width, uint32_t height, VkImageView* date, uint32_t size);
    VkAttachmentDescription2KHR CreateVkAttachmentDescription2KHR(VkImageLayout finalLayout, VkFormat format);
    VkSubpassDescription2KHR CreateSunbpassDescription2KHRInfo(VkAttachmentReference2KHR &colorReference,
        VkFragmentShadingRateAttachmentInfoKHR &fragmentShadingRateAttachmentInfo);
    std::array<VkSubpassDependency2KHR, 2> CreateSubpassDependencies();
    VkRenderPassCreateInfo2KHR CreateRenderPassCI(uint32_t attachmentCount, VkAttachmentDescription2* date,
        uint32_t dependencyCount, VkSubpassDependency2* pDependencies, VkSubpassDescription2KHR &subpassDescription);
    template<typename T>
    std::vector<VkImageView> CreateImageViewAttachment(const T& fb);
    template<typename T>
    std::vector<VkAttachmentDescription> SetAttachmentDescriptionformat(
        const T& fb, std::vector<VkAttachmentDescription> attachmentDescs);
    void PrepareGBufferRenderPass();
    void PrepareLightRenderPass();
    void PrepareUpscaleRenderpass();
    void PrepareCopyRenderPass();
    void PrepareMVRenderPass();
    void PrepareOffscreenFrameBuffers();
    void LoadAssets();
    void SetBeginRenderPass(std::vector<VkClearValue> &clearValues, FrameBuffer &fb, VkPipelineLayout &layout,
        VkPipeline &pipeline, VkDescriptorSet &descriptorSet);
    void RecordTURenderPass(std::vector<VkClearValue> &clearValues);
    void BuildUpscaleCommandBuffers();
    void SetupDescriptorPool();
    void CreatePipelineLayout(std::vector<VkDescriptorSetLayoutBinding> &setLayoutBindings,
      VkDescriptorSetLayout &setLayout, VkPipelineLayout &pipelineLayout, bool needScene);
    void SetupLayouts();
    void AllocateAndUpdateDescriptorSets(VkDescriptorSetLayout &layout, VkDescriptorSet &vkDescriptorSet);
    void SetupDescriptors();
    void CreateGBufferPipeline(
        VkPipelineRasterizationStateCreateInfo &rasterizationState,
        VkPipelineColorBlendStateCreateInfo &colorBlendState,
        std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
        VkGraphicsPipelineCreateInfo &pipelineCreateInfo);
    void CreateMvPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
        VkPipelineColorBlendStateCreateInfo &colorBlendState,
        std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
        VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
        VkPipelineVertexInputStateCreateInfo &emptyVertexInputState);
    void CreateLightPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
        VkPipelineColorBlendStateCreateInfo &colorBlendState,
        std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
        VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
        VkPipelineVertexInputStateCreateInfo &emptyVertexInputState);
    void CreateCopyDepthPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
        VkPipelineDepthStencilStateCreateInfo &depthStencilState,
        std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
        VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
        VkPipelineVertexInputStateCreateInfo &emptyVertInputState);
    void PreparePipelines();
    void PrepareUniformBuffers();
    void InitLight();
    void UpdateLightUniformBufferParams();
    void UpdateUniformBufferMatrices();
    void Draw();
    void InitFSR();
    void InitSpatialUpscale();
    void InitXegTemporalUpscale();
    float GetHaltonSequence(uint32_t index, uint32_t radix);
    glm::mat4 GetJitterMat();
    bool CheckXEngine();
    void DestroyFrameBuffers();
    std::array<VkVertexInputAttributeDescription, 3> GetAttributeDescriptions();
    VkPipelineVertexInputStateCreateInfo m_pipelineVertexInputStateCreateInfo = {};
    VkVertexInputBindingDescription m_vertexInputBindingDescription = {};
    std::vector<VkVertexInputAttributeDescription> m_vertexInputAttributeDescriptions;
};
#endif // RENDER_MODEL_3D_SPONZA_H
