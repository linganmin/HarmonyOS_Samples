/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_MAINSCENERENDERER_H
#define HELLO_VULKAN_MAINSCENERENDERER_H

#include "Singleton.hpp"
#include <vulkan/vulkan.h>
#include <vector>
#include "Image.h"
#include "Buffer.h"
#include "glm/mat4x4.hpp"
#include "Camera.h"
#include "log.hpp"
#include "AAssetImporter.h"

namespace VulkanFG {
class MainSceneRenderer : public Singleton<MainSceneRenderer> {
public:
    constexpr static uint32_t s_instanceRowNum = 18;
    constexpr static uint32_t s_instanceColumnNum = 18;
    constexpr static uint32_t s_instanceTotalNum = s_instanceRowNum * s_instanceColumnNum;
    constexpr static float DEFAULT_INSTANCE_PER_SIDE = 32.0F;
    constexpr static float DEFAULT_DISTANCE = 3.0F;
    constexpr static float DENSITY = DEFAULT_INSTANCE_PER_SIDE / static_cast<float>(s_instanceRowNum);
    constexpr static float SCALE = 0.75F * DENSITY;
    constexpr static glm::vec3 ROTATION_AXIS = glm::vec3(0.0f, -1.0f, 0.0f);
    constexpr static float ROTATION_SPEED = 1.0F;
    constexpr static float WAVE_HEIGHT = 0.4F * DENSITY;

    typedef struct MainSceneRendererDescriptor {
        uint32_t frameInFlightNum = 0U;
        uint32_t frameBufferNum = 0U;
        uint32_t frameBufferWidth = 0U;
        uint32_t frameBufferHeight = 0U;
        VkFormat colorFormat = VK_FORMAT_UNDEFINED;
        VkFormat depthStencilFormat = VK_FORMAT_UNDEFINED;
    } MainSceneRendererDescriptor;

    void Init(const MainSceneRendererDescriptor &desc);
    void Update(uint32_t frameIdx);
    void Render(VkCommandBuffer commandBuffer, VkFramebuffer frameBuffer, size_t fifIndex);
    [[nodiscard]] VkRenderPass GetRenderPass() const;
    glm::mat4 GetSceneViewProjMatrix()
    {
        return m_camera.GetViewPerspectiveMatrix();
    }

    glm::mat4 GetInstanceModelTransform(uint32_t id)
    {
        if (id >= s_instanceTotalNum) {
            GOLOGE("GetInstanceModelTransform execution failed");
            return glm::mat4();
        }
        PerInstanceBuffer *perInstanceBuffer = reinterpret_cast<PerInstanceBuffer *>(
            (uint64_t)m_perInstanceBuffersObj.instanceBuffers + id * m_dynamicUboAlignedSize);
        return perInstanceBuffer->modelTransform;
    }

    void Destroy();
    ~MainSceneRenderer() override = default;

private:
    typedef struct HostVsUniformBuffer {
        alignas(16) glm::mat4 viewTransform;
        alignas(16) glm::mat4 perspectiveTransform;
        alignas(16) glm::mat4 vpTransform;
    } HostVsUniformBuffer;

    typedef struct PerInstanceBuffer {
        alignas(16) glm::mat4 modelTransform;
        alignas(16) glm::vec4 diffuseColor;
    } PerInstanceBuffer;

    typedef struct HostVsDynamicUniformBuffer {
        PerInstanceBuffer *instanceBuffers = nullptr;
    } HostVsDynamicUniformBuffer;

    typedef struct HostFsUniformBuffer {
        alignas(16) glm::vec3 g_AmbientLightColor;
        alignas(16) glm::vec3 g_SpotLightColor;
        alignas(16) glm::vec3 g_SpotLightLocation;
    } HostFsUniformBuffer;

    void CreateVertexBuffer();
    void CreateTextures();
    void CreateUniformBuffers();
    void CreateDynamicUniformBuffers();

    size_t m_dynamicUboAlignedSize = 0;
    uint32_t m_vertexNum;
    VulkanFG::Buffer m_vertexBuffer;
    VulkanFG::Image m_diffuseTexture;
    VulkanFG::Image m_normalTexture;

    void CreateOpaqueRenderPass();
    void CreateOpaqueDescriptorSetLayout();
    void CreateOpaqueGraphicsPipeline();
    void CreateOpaqueDescriptorSets();

    std::unique_ptr<VkPipelineShaderStageCreateInfo[]> CreateShaderStages(VkShaderModule vertShaderModule,
        VkShaderModule fragShaderModule);
    VkPipelineColorBlendStateCreateInfo CreateColorBlending();
    VkPipelineRasterizationStateCreateInfo CreateRasterizerInfo();
    VkPipelineDepthStencilStateCreateInfo CreateDepthStencil();
    void CreatePipelineLayout(VkDevice device);
    void CreatePipeline(VkDevice device, VkPipelineShaderStageCreateInfo *shaderStages,
        VkPipelineVertexInputStateCreateInfo &vertexInputInfo, VkPipelineInputAssemblyStateCreateInfo &inputAssembly,
        VkPipelineRasterizationStateCreateInfo &rasterizer, VkPipelineMultisampleStateCreateInfo &multisampling,
        VkPipelineDepthStencilStateCreateInfo &depthStencil, VkPipelineColorBlendStateCreateInfo &colorBlending);
    void WriteDescriptorSet(std::array<VkWriteDescriptorSet, NUMBER_FIVE> &descriptorWrites, size_t index,
        VkDescriptorBufferInfo &vsBufferInfo, VkDescriptorImageInfo &diffuseImageInfo,
        VkDescriptorImageInfo &normalImageInfo, VkDescriptorBufferInfo &fsBufferInfo,
        VkDescriptorBufferInfo &vsDynamicBufferInfo);

    MainSceneRendererDescriptor m_descriptor;
    VkRenderPass m_opaqueRenderPass = VK_NULL_HANDLE;

    VkDescriptorSetLayout m_opaqueDescriptorSetLayout = VK_NULL_HANDLE;
    VkPipelineLayout m_opaquePipelineLayout = VK_NULL_HANDLE;
    VkPipeline m_opaqueGraphicsPipeline = VK_NULL_HANDLE;
    std::vector<VkDescriptorSet> m_opaqueDescriptorSets;

    HostVsUniformBuffer m_sceneBufferObj;
    std::vector<VulkanFG::Buffer> m_sceneBuffers;

    HostVsDynamicUniformBuffer m_perInstanceBuffersObj;
    std::vector<VulkanFG::Buffer> m_perInstanceBuffers;

    HostFsUniformBuffer m_lightBufferObj;
    std::vector<VulkanFG::Buffer> m_lightBuffers;

    VulkanFG::Camera m_camera;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_MAINSCENERENDERER_H
