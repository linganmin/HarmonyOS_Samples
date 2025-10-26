/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_UIRENDERER_H
#define HELLO_VULKAN_UIRENDERER_H

#include "Singleton.hpp"
#include <vulkan/vulkan.h>
#include <vector>
#include <map>
#include <string>
#include "Image.h"
#include "Buffer.h"
#include "glm/mat4x4.hpp"
#include "AAssetImporter.h"
namespace VulkanFG {
class UIRenderer : public Singleton<UIRenderer> {
public:
    typedef struct UIRendererDescriptor {
        uint32_t frameInFlightNum = 0;
        uint32_t frameBufferNum = 0;
        uint32_t canvasWidth = 0;
        uint32_t canvasHeight = 0;
        VkFormat colorFormat;
        VkFormat depthStencilFormat;
        std::vector<VkImageView> colorImageViews;
        VkImageView depthStencilImageView = VK_NULL_HANDLE;
    } UIRendererDescriptor;

    typedef struct UIRegistryInfo {
        std::string path;
        std::string name;
        float offset[2];
        float scale[2];
        float transparancy;
        bool initEnable = true;
    } UIRegistryInfo;

    void Init(const UIRendererDescriptor &descriptor);
    void LoadUI(const UIRegistryInfo &uiRegistryInfo);
    void SetUIOffset(const std::string &uiName, float offsetX, float offsetY);
    void SetUITransparancy(const std::string &uiName, float transparancy);
    void SetUIExtent(const std::string &uiName, uint32_t width, uint32_t height);
    void SetUIScale(const std::string &uiName, float scaleX, float scaleY);
    void SetUIEnable(const std::string &uiName, bool enable);
    void Draw(VkCommandBuffer commandBuffer, uint32_t swapchainIdx, uint32_t frameIdx, VkDescriptorSet background);
    void Update(uint32_t frameIdx);
    [[nodiscard]] VkDescriptorSet MakeBackground(Image &background);
    void Destroy();
    ~UIRenderer() override = default;

private:
    typedef struct UIItem {
        std::vector<Buffer> uniformBuffers;
        std::vector<Buffer> transformBuffers;
        Image image;
        std::vector<VkDescriptorSet> uiDescriptorSets;
        int32_t offset[2];
        uint32_t extent[2];
        float scale[2];
        float transparancy;
        bool enable;
    } UIItem;

    typedef struct UIImageUniformBuffer {
        float transparancy;
        float padding[3];
    } UIImageUniformBuffer;

    typedef struct TransformUniformBuffer {
        alignas(16) glm::mat4 transform;
    } TransformUniformBuffer;

    void CreateRenderPass();
	void CreateIndexBuffer();
    void CreateFrameBuffers();
    void CreateDescriptorSetLayout();
    void CreateGraphicsPipeline();
    void AddUIDescriptorSets(const std::string &uiName);
    void DrawUIItem(UIItem const &item, VkCommandBuffer commandBuffer, uint32_t frameIdx);
    void SpinUIItem(UIItem &item, uint32_t frameIdx);
    void GetAdjustedUIOffset(const UIRegistryInfo &uiRegistry, float width, float height, float &offsetX,
        float &offsetY);

    void ExcuteUpdateDescriptorSets(UIItem &uiIter, std::vector<VkDescriptorSet> descriptorSets);
    void UpdateBufferDescriptor(const UIRenderer::UIRegistryInfo &uiRegistryInfo, UIItem &uiItem);
    void UpdateBufferDescriptor(const UIRenderer::UIRegistryInfo &uiRegistryInfo, float offsetX, float offsetY,
        AAssetImporter::ImageAsset &uiImage, UIItem &uiItem);
    std::unique_ptr<VkPipelineShaderStageCreateInfo[]> CreateShaderStages(VkShaderModule vertShaderModule,
        VkShaderModule fragShaderModule);
    VkPipelineColorBlendStateCreateInfo CreateColorBlending();
    VkPipelineRasterizationStateCreateInfo CreateRasterizerInfo();
    void CreatePipelineLayout(VkDevice device);
    void CreatePipeline(VkDevice device, VkPipelineShaderStageCreateInfo *shaderStages,
        VkPipelineVertexInputStateCreateInfo &vertexInputInfo, VkPipelineInputAssemblyStateCreateInfo &inputAssembly,
        VkPipelineRasterizationStateCreateInfo &rasterizer, VkPipelineMultisampleStateCreateInfo &multisampling,
        VkPipelineDepthStencilStateCreateInfo &depthStencil, VkPipelineColorBlendStateCreateInfo &colorBlending);

    UIRendererDescriptor m_descriptor;
    VkPipelineLayout m_pipelineLayout = VK_NULL_HANDLE;
    VkDescriptorSetLayout m_descriptorSetLayout = VK_NULL_HANDLE;
    VkRenderPass m_renderPass = VK_NULL_HANDLE;
    VkPipeline m_graphicsPipeline = VK_NULL_HANDLE;
    std::vector<VkFramebuffer> m_framebuffers;
    std::vector<VkImageView> m_colorImageViews;
    std::map<std::string, UIItem> m_uiItemMap;
    glm::mat4 m_projMatrix;
	Buffer indexBuffer;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_UIRENDERER_H
