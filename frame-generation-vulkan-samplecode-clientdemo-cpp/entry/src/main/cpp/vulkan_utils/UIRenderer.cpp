/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "log.hpp"
#include "Blit.h"
#include "UIRenderer.h"
#include "Device.h"
#include "DescriptorPool.h"
#include "Utils.h"
#include <array>
#include <glm/gtc/matrix_transform.hpp>


namespace VulkanFG {
static std::vector<UIRenderer::UIRegistryInfo> s_uiRegistryLists = {
    { "logo.png", "logo", { -1200, 1200 }, { 1.25f, 1.25f }, 1.0f },
    { "gui-saving.png", "saving", { 660, 1200 }, { 0.5f, 0.5f }, 0.7f },
    { "spinner.png", "spinner", { 700, 1200 }, { 0.15f, 0.15f }, 0.7f },
    { "passive-star.png", "passive-star1", { 475, -300 }, { 0.35f, 0.35f }, 1.0f },
    { "passive-star.png", "passive-star2", { 530, -300 }, { 0.35f, 0.35f }, 1.0f },
    { "passive-star.png", "passive-star3", { 585, -300 }, { 0.35f, 0.35f }, 1.0f },
    { "passive-star.png", "passive-star4", { 640, -300 }, { 0.35f, 0.35f }, 1.0f },
    { "passive-star.png", "passive-star5", { 695, -300 }, { 0.35f, 0.35f }, 1.0f },
    { "active-star.png", "active-star4", { 640, -300 }, { 0.35f, 0.35f }, 1.0f, false },
    { "active-star.png", "active-star5", { 695, -300 }, { 0.35f, 0.35f }, 1.0f, false },
};

static uint16_t indices[] = { 0, 1, 2, 2, 1, 3 };
void UIRenderer::Init(const UIRenderer::UIRendererDescriptor &descriptor)
{
    m_descriptor = descriptor;
    CreateRenderPass();
    CreateFrameBuffers();
    CreateDescriptorSetLayout();
    CreateGraphicsPipeline();

    Blit::Instance().Init(Blit::BlitDescriptor {
        .dstResolution {
            .width = m_descriptor.canvasWidth,
            .height = m_descriptor.canvasHeight
        },

        .renderPass = m_renderPass,
        .subpass = 0U
    });

    m_projMatrix = glm::mat4(1.0f);
    m_projMatrix[0][0] = 2.0f / m_descriptor.canvasWidth;
    m_projMatrix[1][1] = 2.0f / m_descriptor.canvasHeight;

	CreateIndexBuffer();
    for (auto &uiRegistry : s_uiRegistryLists) {
        LoadUI(uiRegistry);
    }
}

void UIRenderer::CreateIndexBuffer() {
	VkDeviceSize bufferSize = sizeof(indices);

	VulkanFG::Buffer::BufferDescriptor bufferDesc;
	bufferDesc.name = "IndexBuffer";
	bufferDesc.bufferSize = sizeof(indices);
	bufferDesc.usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT | VK_BUFFER_USAGE_INDEX_BUFFER_BIT;
	bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT
	| VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT;
        
	indexBuffer.Init(bufferDesc);
	indexBuffer.UpdateData(indices, bufferSize);
}
VkAttachmentDescription GetAttachmentDesc(VkFormat &colorFormat)
{
    VkAttachmentDescription const attachmentDesc{
        .flags = 0U,
        .format = colorFormat,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .loadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .storeOp = VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
    };

    return attachmentDesc;
}

void UIRenderer::CreateRenderPass()
{
    VkAttachmentDescription const attachmentDesc = GetAttachmentDesc(m_descriptor.colorFormat);

    constexpr static VkAttachmentReference colorReference {
        .attachment = 0U,
        .layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    };

    constexpr VkSubpassDescription subpassExt {
        .flags = 0U,
        .pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS,
        .inputAttachmentCount = 0U,
        .pInputAttachments = nullptr,
        .colorAttachmentCount = 1U,
        .pColorAttachments = &colorReference,
        .pResolveAttachments = nullptr,
        .pDepthStencilAttachment = nullptr,
        .preserveAttachmentCount = 0U,
        .pPreserveAttachments = nullptr
    };

    constexpr VkSubpassDependency dependencyExt {
        .srcSubpass = VK_SUBPASS_EXTERNAL,
        .dstSubpass = 0U,
        .srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        .dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        .srcAccessMask = VK_ACCESS_NONE,
        .dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,
        .dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT
    };

    VkRenderPassCreateInfo const renderPassInfoExt {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .attachmentCount = 1U,
        .pAttachments = &attachmentDesc,
        .subpassCount = 1U,
        .pSubpasses = &subpassExt,
        .dependencyCount = 1U,
        .pDependencies = &dependencyExt
    };

    VkDevice device = Device::Instance().GetNativeDevice();
    VK_CHECK(vkCreateRenderPass(device, &renderPassInfoExt, nullptr, &m_renderPass));
    VulkanFG::SetLabel(device, m_renderPass, VK_OBJECT_TYPE_RENDER_PASS, "UI");
}

void UIRenderer::CreateFrameBuffers()
{
    m_framebuffers.resize(m_descriptor.frameBufferNum);
    for (uint32_t i = 0U; i < m_descriptor.frameBufferNum; ++i) {
        std::vector<VkImageView> attachments;
        attachments.push_back(m_descriptor.colorImageViews[i]);
        VkFramebufferCreateInfo framebufferInfo{};
        framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        framebufferInfo.renderPass = m_renderPass;
        framebufferInfo.attachmentCount = static_cast<uint32_t>(attachments.size());
        framebufferInfo.pAttachments = attachments.data();
        framebufferInfo.width = m_descriptor.canvasWidth;
        framebufferInfo.height = m_descriptor.canvasHeight;
        framebufferInfo.layers = 1;

        VK_CHECK(vkCreateFramebuffer(VulkanFG::Device::Instance().GetNativeDevice(), &framebufferInfo, nullptr,
            &m_framebuffers[i]));
    }
}

void UIRenderer::CreateDescriptorSetLayout()
{
    VkDescriptorSetLayoutBinding uiUniformBinding{};
    uiUniformBinding.binding = 0;
    uiUniformBinding.descriptorCount = 1;
    uiUniformBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    uiUniformBinding.pImmutableSamplers = nullptr;
    uiUniformBinding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;

    VkDescriptorSetLayoutBinding uiTextureBinding{};
    uiTextureBinding.binding = 1;
    uiTextureBinding.descriptorCount = 1;
    uiTextureBinding.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    uiTextureBinding.pImmutableSamplers = nullptr;
    uiTextureBinding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;

    VkDescriptorSetLayoutBinding uiTransformBinding{};
    uiTransformBinding.binding = NUMBER_TWO;
    uiTransformBinding.descriptorCount = 1;
    uiTransformBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    uiTransformBinding.pImmutableSamplers = nullptr;
    uiTransformBinding.stageFlags = VK_SHADER_STAGE_VERTEX_BIT;

    std::array<VkDescriptorSetLayoutBinding, NUMBER_THREE> bindings = { uiUniformBinding, uiTextureBinding,
        uiTransformBinding };
    VkDescriptorSetLayoutCreateInfo layoutInfo{};
    layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    layoutInfo.bindingCount = static_cast<uint32_t>(bindings.size());
    layoutInfo.pBindings = bindings.data();

    VK_CHECK(vkCreateDescriptorSetLayout(VulkanFG::Device::Instance().GetNativeDevice(), &layoutInfo, nullptr,
        &m_descriptorSetLayout));
}

std::unique_ptr<VkPipelineShaderStageCreateInfo[]> UIRenderer::CreateShaderStages(VkShaderModule vertShaderModule,
    VkShaderModule fragShaderModule)
{
    std::unique_ptr<VkPipelineShaderStageCreateInfo[]> shaderStages =
        std::make_unique<VkPipelineShaderStageCreateInfo[]>(2);

    shaderStages[0].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    shaderStages[0].stage = VK_SHADER_STAGE_VERTEX_BIT;
    shaderStages[0].module = vertShaderModule;
    shaderStages[0].pName = "main";

    shaderStages[1].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    shaderStages[1].stage = VK_SHADER_STAGE_FRAGMENT_BIT;
    shaderStages[1].module = fragShaderModule;
    shaderStages[1].pName = "main";

    return shaderStages;
}

VkPipelineColorBlendStateCreateInfo UIRenderer::CreateColorBlending()
{
    static VkPipelineColorBlendAttachmentState colorBlendAttachment{};
    colorBlendAttachment.colorWriteMask =
        VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
    colorBlendAttachment.blendEnable = VK_TRUE;
    colorBlendAttachment.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA;
    colorBlendAttachment.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA;
    colorBlendAttachment.colorBlendOp = VK_BLEND_OP_ADD;
    colorBlendAttachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ZERO;
    colorBlendAttachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ONE;
    colorBlendAttachment.alphaBlendOp = VK_BLEND_OP_ADD;

    VkPipelineColorBlendStateCreateInfo colorBlending{};
    colorBlending.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    colorBlending.logicOpEnable = VK_FALSE;
    colorBlending.logicOp = VK_LOGIC_OP_COPY; // Optional
    colorBlending.attachmentCount = 1;
    colorBlending.pAttachments = &colorBlendAttachment;
    colorBlending.blendConstants[0] = 0.0f;            // Optional
    colorBlending.blendConstants[1] = 0.0f;            // Optional
    colorBlending.blendConstants[NUMBER_TWO] = 0.0f;   // Optional
    colorBlending.blendConstants[NUMBER_THREE] = 0.0f; // Optional

    return colorBlending;
}

VkPipelineRasterizationStateCreateInfo UIRenderer::CreateRasterizerInfo()
{
    VkPipelineRasterizationStateCreateInfo rasterizer{};
    rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    rasterizer.depthClampEnable = VK_FALSE;
    rasterizer.rasterizerDiscardEnable = VK_FALSE;
    rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
    rasterizer.lineWidth = 1.0f;
    rasterizer.cullMode = VK_CULL_MODE_NONE;
    rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE;
    rasterizer.depthBiasEnable = VK_FALSE;

    return rasterizer;
}

void UIRenderer::CreatePipelineLayout(VkDevice device)
{
    VkPipelineLayoutCreateInfo pipelineLayoutInfo{};
    pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    pipelineLayoutInfo.pSetLayouts = &m_descriptorSetLayout;
    pipelineLayoutInfo.setLayoutCount = 1;
    pipelineLayoutInfo.pushConstantRangeCount = 0;
    pipelineLayoutInfo.pPushConstantRanges = nullptr;

    VK_CHECK(vkCreatePipelineLayout(device, &pipelineLayoutInfo, nullptr, &m_pipelineLayout));
}

void UIRenderer::CreatePipeline(VkDevice device, VkPipelineShaderStageCreateInfo *shaderStages,
    VkPipelineVertexInputStateCreateInfo &vertexInputInfo, VkPipelineInputAssemblyStateCreateInfo &inputAssembly,
    VkPipelineRasterizationStateCreateInfo &rasterizer, VkPipelineMultisampleStateCreateInfo &multisampling,
    VkPipelineDepthStencilStateCreateInfo &depthStencil, VkPipelineColorBlendStateCreateInfo &colorBlending)
{
   // =============================== mutable pipeline var ================================
    std::vector<VkDynamicState> dynamicStates = {
        VK_DYNAMIC_STATE_VIEWPORT,
        VK_DYNAMIC_STATE_SCISSOR,
    };

    VkPipelineDynamicStateCreateInfo dynamicState{};
    dynamicState.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
    dynamicState.dynamicStateCount = static_cast<uint32_t>(dynamicStates.size());
    dynamicState.pDynamicStates = dynamicStates.data();

    VkPipelineViewportStateCreateInfo viewportState{};
    viewportState.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
    viewportState.viewportCount = 1;
    viewportState.scissorCount = 1;

    VkGraphicsPipelineCreateInfo pipelineInfo{};
    pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
    pipelineInfo.stageCount = NUMBER_TWO;
    pipelineInfo.pStages = shaderStages;
    pipelineInfo.pVertexInputState = &vertexInputInfo;
    pipelineInfo.pInputAssemblyState = &inputAssembly;
    pipelineInfo.pViewportState = &viewportState;
    pipelineInfo.pRasterizationState = &rasterizer;
    pipelineInfo.pMultisampleState = &multisampling;
    pipelineInfo.pDepthStencilState = &depthStencil;
    pipelineInfo.pColorBlendState = &colorBlending;
    pipelineInfo.pDynamicState = &dynamicState;

    pipelineInfo.layout = m_pipelineLayout;
    pipelineInfo.renderPass = m_renderPass;
    pipelineInfo.subpass = 0;
    pipelineInfo.basePipelineHandle = VK_NULL_HANDLE;
    pipelineInfo.basePipelineIndex = -1;

    VK_CHECK(vkCreateGraphicsPipelines(device, VK_NULL_HANDLE, 1U, &pipelineInfo, nullptr, &m_graphicsPipeline));
    VulkanFG::SetLabel(device, m_graphicsPipeline, VK_OBJECT_TYPE_PIPELINE, "m_graphicsPipeline [UI]");
}

void UIRenderer::CreateGraphicsPipeline()
{
    auto vs = VulkanFG::AAssetImporter::Instance().ImportShaderAsset("ff_ui_vert.spv");
    if (!vs.has_value()) {
        GOLOGE("Load ui vs shader asset failed!");
        return;
    }
    auto fs = VulkanFG::AAssetImporter::Instance().ImportShaderAsset("ff_ui_frag.spv");
    if (!fs.has_value()) {
        GOLOGE("Load ui fs shader asset failed!");
        return;
    }
    VkShaderModule vertShaderModule = VulkanFG::CreateShaderModule(vs.value().shaderData);
    VkShaderModule fragShaderModule = VulkanFG::CreateShaderModule(fs.value().shaderData);

    std::unique_ptr<VkPipelineShaderStageCreateInfo[]> shaderStages =
        CreateShaderStages(vertShaderModule, fragShaderModule);

    // =============================== vertex assembly ================================
    VkPipelineVertexInputStateCreateInfo vertexInputInfo{};
    vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    vertexInputInfo.vertexAttributeDescriptionCount = 0;
    vertexInputInfo.vertexBindingDescriptionCount = 0;

    VkPipelineInputAssemblyStateCreateInfo inputAssembly{};
    inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP;
    inputAssembly.primitiveRestartEnable = VK_FALSE;

    // =============================== rasterizer ================================
    VkPipelineRasterizationStateCreateInfo rasterizer = CreateRasterizerInfo();

    // =============================== rasterizer - multisampling ================================
    VkPipelineMultisampleStateCreateInfo multisampling{};
    multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    multisampling.sampleShadingEnable = VK_FALSE;
    multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;

    // =============================== depth-stencil ================================
    VkPipelineDepthStencilStateCreateInfo depthStencil{};
    depthStencil.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
    depthStencil.depthTestEnable = VK_FALSE; // For UI, we disable depth test
    depthStencil.depthBoundsTestEnable = VK_FALSE;
    depthStencil.stencilTestEnable = VK_FALSE;

    // =============================== rasterizer - color blend ================================
    VkPipelineColorBlendStateCreateInfo colorBlending = CreateColorBlending();

    // =============================== pipeline ================================
    VkDevice device = VulkanFG::Device::Instance().GetNativeDevice();
    CreatePipelineLayout(device);

    CreatePipeline(device, shaderStages.get(), vertexInputInfo, inputAssembly, rasterizer, multisampling, depthStencil,
        colorBlending);

    vkDestroyShaderModule(device, fragShaderModule, nullptr);
    vkDestroyShaderModule(device, vertShaderModule, nullptr);
}

void UIRenderer::UpdateBufferDescriptor(const UIRenderer::UIRegistryInfo &uiRegistryInfo, UIItem &uiItem)
{
    VulkanFG::Buffer::BufferDescriptor bufferDesc;
    bufferDesc.name = "UniformBuffer";
    bufferDesc.bufferSize = sizeof(UIImageUniformBuffer);
    bufferDesc.usage = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
    bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;

    UIImageUniformBuffer bufferValue{ uiRegistryInfo.transparancy };
    uiItem.uniformBuffers.resize(m_descriptor.frameInFlightNum);
    for (auto &buffer : uiItem.uniformBuffers) {
        buffer.Init(bufferDesc);
        buffer.UpdateData(&bufferValue, sizeof(UIImageUniformBuffer));
    }
}

void UIRenderer::UpdateBufferDescriptor(const UIRenderer::UIRegistryInfo &uiRegistryInfo, float offsetX, float offsetY,
    AAssetImporter::ImageAsset &uiImage, UIItem &uiItem)
{
    VulkanFG::Buffer::BufferDescriptor bufferDesc;
    bufferDesc.name = "TransformUniformBuffer";
    bufferDesc.bufferSize = sizeof(TransformUniformBuffer);
    bufferDesc.usage = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
    bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    uiItem.transformBuffers.resize(m_descriptor.frameInFlightNum);
    TransformUniformBuffer bufferValue{
        .transform = glm::mat4(1.0f)
    };
    glm::mat4 trans = glm::mat4(1.0f);
    trans = glm::rotate(trans, glm::radians(0.0f), glm::vec3(0.0f, 0.0f, 1.0f));
    trans[0] *= uiImage.width * uiRegistryInfo.scale[0] / 2.0f;
    trans[1] *= uiImage.height * uiRegistryInfo.scale[1] / 2.0f;
    trans[NUMBER_THREE] = glm::vec4(offsetX, offsetY, 0.0f, 1.0f);
    bufferValue.transform = m_projMatrix * trans;
    for (auto &buffer : uiItem.transformBuffers) {
        buffer.Init(bufferDesc);
        buffer.UpdateData(&bufferValue, sizeof(TransformUniformBuffer));
    }
}

void UIRenderer::LoadUI(const UIRenderer::UIRegistryInfo &uiRegistryInfo)
{
    auto &uiName = uiRegistryInfo.name;
    if (m_uiItemMap.find(uiName) != m_uiItemMap.end()) {
        GOLOGE("Ui %s has exist in UIRenderer!", uiName.c_str());
        return;
    }

    auto uiAsset = VulkanFG::AAssetImporter::Instance().ImportImageAsset(uiRegistryInfo.path);
    if (!uiAsset.has_value()) {
        GOLOGE("Load ui %s asset failed!", uiName.c_str());
        return;
    }
    auto &uiImage = uiAsset.value();
    uint32_t eleSize = uiImage.format == VulkanFG::AAssetImporter::ImageAsset::Format::RGBA ? 4 : 3;

    auto uiIter = m_uiItemMap.emplace(uiName, UIItem());
    UIItem &uiItem = uiIter.first->second;
    BuildTexture(&uiItem.image, uiImage.imageData.data(), uiImage.width, uiImage.height, eleSize);

    float offsetX;
    float offsetY;
    GetAdjustedUIOffset(uiRegistryInfo, uiImage.width, uiImage.height, offsetX, offsetY);

    UpdateBufferDescriptor(uiRegistryInfo, uiItem);

    UpdateBufferDescriptor(uiRegistryInfo, offsetX, offsetY, uiImage, uiItem);

    AddUIDescriptorSets(uiName);

    SetUIExtent(uiName, uiImage.width, uiImage.height);
    SetUIOffset(uiName, offsetX, offsetY);
    SetUIScale(uiName, uiRegistryInfo.scale[0], uiRegistryInfo.scale[1]);
    SetUITransparancy(uiName, uiRegistryInfo.transparancy);
    SetUIEnable(uiName, uiRegistryInfo.initEnable);
}

void UIRenderer::SetUIOffset(const std::string &uiName, float offsetX, float offsetY)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it first before set offset!", uiName.c_str());
        return;
    }
    uiIter->second.offset[0] = static_cast<int32_t>(offsetX);
    uiIter->second.offset[1] = static_cast<int32_t>(offsetY);
}


void UIRenderer::SetUIExtent(const std::string &uiName, uint32_t width, uint32_t height)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it first before set extent!", uiName.c_str());
        return;
    }
    uiIter->second.extent[0] = width;
    uiIter->second.extent[1] = height;
}


void UIRenderer::SetUIScale(const std::string &uiName, float scaleX, float scaleY)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it first before set scale!", uiName.c_str());
        return;
    }
    uiIter->second.scale[0] = scaleX;
    uiIter->second.scale[1] = scaleY;
}

void UIRenderer::SetUITransparancy(const std::string &uiName, float transparancy)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it first before set transparancy!", uiName.c_str());
        return;
    }
    uiIter->second.transparancy = transparancy;
}


void UIRenderer::SetUIEnable(const std::string &uiName, bool enable)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it first before set enable!", uiName.c_str());
        return;
    }
    uiIter->second.enable = enable;
}

void UIRenderer::ExcuteUpdateDescriptorSets(UIItem &uiImage, std::vector<VkDescriptorSet> descriptorSets)
{
    for (size_t i = 0; i < m_descriptor.frameInFlightNum; i++) {
        VkDescriptorBufferInfo uniformBufferInfo{};
        uniformBufferInfo.buffer = uiImage.uniformBuffers[i].GetNativeBuffer();
        uniformBufferInfo.offset = 0;
        uniformBufferInfo.range = sizeof(UIImageUniformBuffer);

        VkDescriptorImageInfo uiImageInfo{};
        uiImageInfo.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        uiImageInfo.imageView = uiImage.image.GetNativeImageView();
        uiImageInfo.sampler = uiImage.image.GetNativeSampler();

        VkDescriptorBufferInfo tranformBufferInfo{};
        tranformBufferInfo.buffer = uiImage.transformBuffers[i].GetNativeBuffer();
        tranformBufferInfo.offset = 0;
        tranformBufferInfo.range = sizeof(TransformUniformBuffer);

        std::array<VkWriteDescriptorSet, NUMBER_THREE> descriptorWrites{};
        descriptorWrites[0].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        descriptorWrites[0].dstSet = descriptorSets[i];
        descriptorWrites[0].dstBinding = 0;
        descriptorWrites[0].dstArrayElement = 0;
        descriptorWrites[0].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
        descriptorWrites[0].descriptorCount = 1;
        descriptorWrites[0].pBufferInfo = &uniformBufferInfo;

        descriptorWrites[1].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        descriptorWrites[1].dstSet = descriptorSets[i];
        descriptorWrites[1].dstBinding = 1;
        descriptorWrites[1].dstArrayElement = 0;
        descriptorWrites[1].descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
        descriptorWrites[1].descriptorCount = 1;
        descriptorWrites[1].pImageInfo = &uiImageInfo;

        descriptorWrites[NUMBER_TWO].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
        descriptorWrites[NUMBER_TWO].dstSet = descriptorSets[i];
        descriptorWrites[NUMBER_TWO].dstBinding = NUMBER_TWO;
        descriptorWrites[NUMBER_TWO].dstArrayElement = 0;
        descriptorWrites[NUMBER_TWO].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
        descriptorWrites[NUMBER_TWO].descriptorCount = 1;
        descriptorWrites[NUMBER_TWO].pBufferInfo = &tranformBufferInfo;

        vkUpdateDescriptorSets(VulkanFG::Device::Instance().GetNativeDevice(),
            static_cast<uint32_t>(descriptorWrites.size()), descriptorWrites.data(), 0, nullptr);
    }
}

void UIRenderer::AddUIDescriptorSets(const std::string &uiName)
{
    auto uiIter = m_uiItemMap.find(uiName);
    if (uiIter == m_uiItemMap.end()) {
        GOLOGE("Ui %s does not exist in UIRenderer! Load it before create descriptor set!", uiName.c_str());
        return;
    }

    if (!uiIter->second.uiDescriptorSets.empty()) {
        GOLOGE("Ui %s has own its descriptor sets in UIRenderer!", uiName.c_str());
        return;
    }
    auto &descriptorSets = uiIter->second.uiDescriptorSets;
    descriptorSets.resize(m_descriptor.frameInFlightNum);

    std::vector<VkDescriptorSetLayout> layouts(m_descriptor.frameInFlightNum, m_descriptorSetLayout);
    VkDescriptorSetAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    allocInfo.descriptorPool = VulkanFG::DescriptorPool::Instance().GetNativeDescriptorPool();
    allocInfo.descriptorSetCount = static_cast<uint32_t>(m_descriptor.frameInFlightNum);
    allocInfo.pSetLayouts = layouts.data();

    VK_CHECK(
        vkAllocateDescriptorSets(VulkanFG::Device::Instance().GetNativeDevice(), &allocInfo, descriptorSets.data()));

    ExcuteUpdateDescriptorSets(uiIter->second, descriptorSets);
}

void UIRenderer::Draw(VkCommandBuffer commandBuffer, uint32_t swapchainIdx, uint32_t frameIdx,
    VkDescriptorSet background)
{
    VulkanFG::DebugGroup const group(commandBuffer, "UI");

    VkRenderPassBeginInfo const renderPassInfo {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .pNext = nullptr,
        .renderPass = m_renderPass,
        .framebuffer = m_framebuffers[swapchainIdx],

        .renderArea {
            .offset {
                .x = 0,
                .y = 0
            },

            .extent = {
                .width = m_descriptor.canvasWidth,
                .height = m_descriptor.canvasHeight
            }
        },

        .clearValueCount = 0U,
        .pClearValues = nullptr
    };

    VkExtent2D const &extent = renderPassInfo.renderArea.extent;

    vkCmdBeginRenderPass(commandBuffer, &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE);
    Blit::Instance().Run(commandBuffer, background);

    vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_graphicsPipeline);

    VkViewport const viewport {
        .x = 0.0F,
        .y = 0.0F,
        .width = static_cast<float>(extent.width),
        .height = static_cast<float>(extent.height),
        .minDepth = 0.0F,
        .maxDepth = 1.0F
    };

    VkRect2D const scissor {
        .offset {
            .x = 0,
            .y = 0
        },

        .extent = extent
    };

    vkCmdSetViewport(commandBuffer, 0U, 1U, &viewport);
    vkCmdSetScissor(commandBuffer, 0U, 1U, &scissor);

    for (const auto &iter : m_uiItemMap) {
        if (iter.second.enable) {
            DrawUIItem(iter.second, commandBuffer, frameIdx);
        }
    }

    vkCmdEndRenderPass(commandBuffer);
}

void UIRenderer::DrawUIItem(UIItem const &item, VkCommandBuffer commandBuffer, uint32_t frameIdx)
{
    vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_pipelineLayout, 0U, 1U,
        &item.uiDescriptorSets[frameIdx], 0U, nullptr);

    vkCmdBindIndexBuffer(commandBuffer, indexBuffer.GetNativeBuffer(), 0, VK_INDEX_TYPE_UINT16);
    vkCmdDrawIndexed(commandBuffer, 6U, 1U, 0U, 0, 0U);
}

void UIRenderer::SpinUIItem(UIRenderer::UIItem &item, uint32_t frameIdx)
{
    static float speed = -0.1f; // degree / s
    static std::chrono::time_point<std::chrono::steady_clock> s_start = std::chrono::steady_clock::now();
    std::chrono::time_point<std::chrono::steady_clock> s_now = std::chrono::steady_clock::now();
    auto deltaT = std::chrono::duration_cast<std::chrono::microseconds>(s_now - s_start).count();
    float deltaD = speed * (deltaT / 1000.f);

    TransformUniformBuffer bufferValue{
        .transform = glm::mat4(1.0f)
    };
    glm::mat4 trans = glm::mat4(1.0f);
    trans = glm::rotate(trans, glm::radians(deltaD), glm::vec3(0.0f, 0.0f, 1.0f));
    trans[0] *= item.extent[0] * item.scale[0] / 2.0f;
    trans[1] *= item.extent[1] * item.scale[1] / 2.0f;
    trans[NUMBER_THREE] = glm::vec4(item.offset[0], item.offset[1], 0.0f, 1.0f);
    bufferValue.transform = m_projMatrix * trans;
    item.transformBuffers[frameIdx].UpdateData(&bufferValue, sizeof(TransformUniformBuffer));
}

void UIRenderer::Update(uint32_t frameIdx)
{
    for (auto &iter : m_uiItemMap) {
        if (iter.first == "spinner") {
            SpinUIItem(iter.second, frameIdx);
        }
    }

    constexpr float START_TIME_OUT = 0.777f;
    static std::chrono::time_point<std::chrono::steady_clock> s_start = std::chrono::steady_clock::now();
    std::chrono::time_point<std::chrono::steady_clock> s_now = std::chrono::steady_clock::now();
    auto deltaT = std::chrono::duration_cast<std::chrono::seconds>(s_now - s_start).count();
    if (deltaT > START_TIME_OUT) {
        m_uiItemMap["passive-star4"].enable = !m_uiItemMap["passive-star4"].enable;
        m_uiItemMap["passive-star5"].enable = !m_uiItemMap["passive-star5"].enable;
        m_uiItemMap["active-star4"].enable = !m_uiItemMap["active-star4"].enable;
        m_uiItemMap["active-star5"].enable = !m_uiItemMap["active-star5"].enable;
        s_start = std::chrono::steady_clock::now();
    }
}

void UIRenderer::GetAdjustedUIOffset(const UIRegistryInfo &uiRegistry, float width, float height, float &offsetX,
    float &offsetY)
{
    constexpr int32_t paddingPixels = 30;
    offsetX = uiRegistry.offset[0];
    offsetY = uiRegistry.offset[1];

    int32_t canvasBoundaryWidth = m_descriptor.canvasWidth / 2;
    int32_t canvasBoundaryHeight = m_descriptor.canvasHeight / 2;
    float halfW = width / 2.0f;
    float halfH = height / 2.0f;

    std::array<std::array<float, NUMBER_TWO>, NUMBER_FOUR> coordinates = { {
        { uiRegistry.offset[0] - halfW * uiRegistry.scale[0],
          uiRegistry.offset[1] - halfW * uiRegistry.scale[1] }, // left-bottom
        { uiRegistry.offset[0] + halfW * uiRegistry.scale[0],
          uiRegistry.offset[1] - halfW * uiRegistry.scale[1] }, // right-bottom
        { uiRegistry.offset[0] + halfW * uiRegistry.scale[0],
          uiRegistry.offset[1] + halfW * uiRegistry.scale[1] }, // right-top
        { uiRegistry.offset[0] - halfW * uiRegistry.scale[0],
          uiRegistry.offset[1] + halfW * uiRegistry.scale[1] }, // left-top
                                                      } };

    // left-bottom
    if (coordinates[0][0] < -canvasBoundaryWidth) {
        offsetX = -canvasBoundaryWidth + paddingPixels + halfW * uiRegistry.scale[0];
    }

    if (coordinates[0][1] < -canvasBoundaryHeight) {
        offsetY = -canvasBoundaryHeight + paddingPixels + halfH * uiRegistry.scale[1];
    }

    // right-bottom
    if (coordinates[1][0] > canvasBoundaryWidth) {
        offsetX = canvasBoundaryWidth - paddingPixels - halfW * uiRegistry.scale[0];
    }

    // right-top
    if (coordinates[NUMBER_TWO][1] > canvasBoundaryHeight) {
        offsetY = canvasBoundaryHeight - paddingPixels - halfH * uiRegistry.scale[1];
    }
}

VkDescriptorSet UIRenderer::MakeBackground(Image &background)
{
    VkDescriptorSetLayout dsLayout = Blit::Instance().GetDescriptorSetLayout();

    VkDescriptorSetAllocateInfo const allocateInfo {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .pNext = nullptr,
        .descriptorPool = DescriptorPool::Instance().GetNativeDescriptorPool(),
        .descriptorSetCount = 1U,
        .pSetLayouts = &dsLayout,
    };

    VkDevice device = Device::Instance().GetNativeDevice();
    VkDescriptorSet ds;
    VK_CHECK(vkAllocateDescriptorSets(device, &allocateInfo, &ds));

    VkDescriptorImageInfo const imageInfo{
        .sampler = background.GetNativeSampler(),
        .imageView = background.GetNativeImageView(),
        .imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    };

    VkWriteDescriptorSet const write{
        .sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .pNext = nullptr,
        .dstSet = ds,
        .dstBinding = Blit::GetSourceImageBinding(),
        .dstArrayElement = 0U,
        .descriptorCount = 1U,
        .descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .pImageInfo = &imageInfo,
        .pBufferInfo = nullptr,
        .pTexelBufferView = nullptr
    };

    vkUpdateDescriptorSets(device, 1U, &write, 0U, nullptr);
    return ds;
}

void UIRenderer::Destroy()
{
    Blit::Instance().Destroy();

    VkDevice device = Device::Instance().GetNativeDevice();
    vkDestroyPipeline(device, m_graphicsPipeline, nullptr);
    vkDestroyPipelineLayout(device, m_pipelineLayout, nullptr);

    vkDestroyDescriptorSetLayout(device, m_descriptorSetLayout, nullptr);

    for (auto frameBuffer : m_framebuffers) {
        vkDestroyFramebuffer(device, frameBuffer, nullptr);
    }

    m_framebuffers.clear();
	indexBuffer.Destroy();        

    if (m_renderPass != VK_NULL_HANDLE) {
        vkDestroyRenderPass(device, m_renderPass, nullptr);
        m_renderPass = VK_NULL_HANDLE;
    }

    for (auto uiIter : m_uiItemMap) {
        UIItem &uiItem = uiIter.second;
        uiItem.image.Destroy();

        for (auto &buffer : uiItem.uniformBuffers) {
            buffer.Destroy();
        }

        for (auto &buffer : uiItem.transformBuffers) {
            buffer.Destroy();
        }

        vkFreeDescriptorSets(device, DescriptorPool::Instance().GetNativeDescriptorPool(),
            uiItem.uiDescriptorSets.size(), uiItem.uiDescriptorSets.data());
    }

    m_uiItemMap.clear();
    m_projMatrix = glm::mat4(1.0f);
}
} // namespace VulkanFG