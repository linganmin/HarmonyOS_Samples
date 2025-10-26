/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "Blit.h"
#include "AAssetImporter.h"
#include "Device.h"
#include "Utils.h"
#include <log.hpp>

namespace VulkanFG {
void Blit::Init(BlitDescriptor &&desc)
{
    VkDevice device = Device::Instance().GetNativeDevice();
    if (!CreateDSLayout(device) || !CreatePipelineLayout(device) || !CreatePipeline(device, desc)) {
        GOLOGE("Can't create blit util");
    }
}

void Blit::Destroy()
{
    VkDevice device = Device::Instance().GetNativeDevice();

    if (m_pipeline != VK_NULL_HANDLE) {
        vkDestroyPipeline(device, m_pipeline, nullptr);
        m_pipeline = VK_NULL_HANDLE;
    }

    if (m_pipelineLayout != VK_NULL_HANDLE) {
        vkDestroyPipelineLayout(device, m_pipelineLayout, nullptr);
        m_pipelineLayout = VK_NULL_HANDLE;
    }

    if (m_dsLayout != VK_NULL_HANDLE) {
        vkDestroyDescriptorSetLayout(device, m_dsLayout, nullptr);
        m_dsLayout = VK_NULL_HANDLE;
    }
}

void Blit::Run(VkCommandBuffer commandBuffer, VkDescriptorSet scrImage)
{
    vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_pipeline);

    vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_pipelineLayout, 0U, 1U, &scrImage, 0U,
        nullptr);

    vkCmdDraw(commandBuffer, 4U, 1U, 0U, 0U);
}

VkDescriptorSetLayout Blit::GetDescriptorSetLayout()
{
    return m_dsLayout;
}

bool Blit::CreateDSLayout(VkDevice device)
{
    constexpr VkDescriptorSetLayoutBinding binding {
        .binding = GetSourceImageBinding(),
        .descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .descriptorCount = 1U,
        .stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT,
        .pImmutableSamplers = nullptr
    };

    VkDescriptorSetLayoutCreateInfo info {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .bindingCount = 1U,
        .pBindings = &binding
    };
    return vkCreateDescriptorSetLayout(device, &info, nullptr, &m_dsLayout) == VK_SUCCESS;
}

bool Blit::CreatePipelineLayout(VkDevice device)
{
    VkPipelineLayoutCreateInfo const layoutInfo {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .setLayoutCount = 1U,
        .pSetLayouts = &m_dsLayout,
        .pushConstantRangeCount = 0U,
        .pPushConstantRanges = nullptr
    };
    return vkCreatePipelineLayout(device, &layoutInfo, nullptr, &m_pipelineLayout) == VK_SUCCESS;
}

void SetStagesInfo(VkPipelineShaderStageCreateInfo stagesInfo[], VkShaderModule &vert, VkShaderModule &frag)
{
    stagesInfo[0] = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .stage = VK_SHADER_STAGE_VERTEX_BIT,
        .module = vert,
        .pName = "main",
        .pSpecializationInfo = nullptr
    };
    stagesInfo[1] = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .stage = VK_SHADER_STAGE_FRAGMENT_BIT,
        .module = frag,
        .pName = "main",
        .pSpecializationInfo = nullptr
    };
}

VkPipelineVertexInputStateCreateInfo GetVertexInfo()
{
    constexpr VkPipelineVertexInputStateCreateInfo vertexInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .vertexBindingDescriptionCount = 0U,
        .pVertexBindingDescriptions = nullptr,
        .vertexAttributeDescriptionCount = 0U,
        .pVertexAttributeDescriptions = nullptr
    };
    
    return vertexInfo;
}

VkPipelineInputAssemblyStateCreateInfo GetInputAssemblyInfo()
{
    constexpr VkPipelineInputAssemblyStateCreateInfo inputAssemblyInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
        .primitiveRestartEnable = VK_FALSE
    };

    return inputAssemblyInfo;
}

VkViewport GetViewport(const VkExtent2D &r)
{
    VkViewport const viewport{
        .x = 0.0F,
        .y = 0.0F,
        .width = static_cast<float>(r.width),
        .height = static_cast<float>(r.height),
        .minDepth = 0.0F,
        .maxDepth = 1.0F
    };

    return viewport;
}

VkRect2D GetScissor(const VkExtent2D &r)
{
    VkRect2D const scissor{
        .offset{
        .x = 0,
        .y = 0 },

        .extent = r
    };

    return scissor;
}

VkPipelineViewportStateCreateInfo GetViewportInfo(const VkViewport &viewport, const VkRect2D &scissor)
{
    VkPipelineViewportStateCreateInfo const viewportInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .viewportCount = 1U,
        .pViewports = &viewport,
        .scissorCount = 1U,
        .pScissors = &scissor
    };

    return viewportInfo;
}

VkPipelineRasterizationStateCreateInfo GetRasterizationInfo()
{
    VkPipelineRasterizationStateCreateInfo const rasterizationInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .depthClampEnable = VK_FALSE,
        .rasterizerDiscardEnable = VK_FALSE,
        .polygonMode = VK_POLYGON_MODE_FILL,
        .cullMode = VK_CULL_MODE_NONE,
        .frontFace = VK_FRONT_FACE_CLOCKWISE,
        .depthBiasEnable = VK_FALSE,
        .depthBiasConstantFactor = 0.0F,
        .depthBiasClamp = 0.0F,
        .depthBiasSlopeFactor = 0.0F,
        .lineWidth = 1.0F
    };

    return rasterizationInfo;
}

VkPipelineMultisampleStateCreateInfo GetMultisampleInfo()
{
    constexpr VkPipelineMultisampleStateCreateInfo multisampleInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .rasterizationSamples = VK_SAMPLE_COUNT_1_BIT,
        .sampleShadingEnable = VK_FALSE,
        .minSampleShading = 0.0F,
        .pSampleMask = nullptr,
        .alphaToCoverageEnable = VK_FALSE,
        .alphaToOneEnable = VK_FALSE
    };

    return multisampleInfo;
}

VkPipelineDepthStencilStateCreateInfo GetDepthStencilInfo()
{
    constexpr VkPipelineDepthStencilStateCreateInfo depthStencilInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .depthTestEnable = VK_FALSE,
        .depthWriteEnable = VK_FALSE,
        .depthCompareOp = VK_COMPARE_OP_ALWAYS,
        .depthBoundsTestEnable = VK_FALSE,
        .stencilTestEnable = VK_FALSE,

        .front = {
            .failOp = VK_STENCIL_OP_KEEP,
            .passOp = VK_STENCIL_OP_KEEP,
            .depthFailOp = VK_STENCIL_OP_KEEP,
            .compareOp = VK_COMPARE_OP_ALWAYS,
            .compareMask = std::numeric_limits<uint32_t>::max(),
            .writeMask = 0x00U,
            .reference = std::numeric_limits<uint32_t>::max()
        },

        .back = {
            .failOp = VK_STENCIL_OP_KEEP,
            .passOp = VK_STENCIL_OP_KEEP,
            .depthFailOp = VK_STENCIL_OP_KEEP,
            .compareOp = VK_COMPARE_OP_ALWAYS,
            .compareMask = std::numeric_limits<uint32_t>::max(),
            .writeMask = 0x00U,
            .reference = std::numeric_limits<uint32_t>::max()
        },

        .minDepthBounds = 0.0F,
        .maxDepthBounds = 1.0F
    };

    return depthStencilInfo;
}

void SetBlendAttachmentStates(VkPipelineColorBlendAttachmentState blendAttachmentStates[])
{
    blendAttachmentStates[0] = (VkPipelineColorBlendAttachmentState) {
        .blendEnable = VK_FALSE,
        .srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA,
        .dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = VK_BLEND_OP_ADD,
        .srcAlphaBlendFactor = VK_BLEND_FACTOR_ZERO,
        .dstAlphaBlendFactor = VK_BLEND_FACTOR_ONE,
        .alphaBlendOp = VK_BLEND_OP_ADD,
        .colorWriteMask =
            VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT
    };

    blendAttachmentStates[1] = (VkPipelineColorBlendAttachmentState) {
        .blendEnable = VK_FALSE,
        .srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA,
        .dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = VK_BLEND_OP_ADD,
        .srcAlphaBlendFactor = VK_BLEND_FACTOR_ZERO,
        .dstAlphaBlendFactor = VK_BLEND_FACTOR_ONE,
        .alphaBlendOp = VK_BLEND_OP_ADD,
        .colorWriteMask =
            VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT
    };
}

VkPipelineColorBlendStateCreateInfo GetColorBlendInfo(VkPipelineColorBlendAttachmentState blendAttachmentStates[])
{
    VkPipelineColorBlendStateCreateInfo const colorBlendInfo{
        .sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .logicOpEnable = VK_FALSE,
        .logicOp = VK_LOGIC_OP_NO_OP,
        .attachmentCount = 1U,
        .pAttachments = blendAttachmentStates,
        .blendConstants = { 0.0F, 0.0F, 0.0F, 0.0F }
    };

    return colorBlendInfo;
}

bool CreatePipelineResources(VkDevice device, VkGraphicsPipelineCreateInfo pipelineInfo, VkPipeline &m_pipeline,
    VkShaderModule &vert, VkShaderModule &frag)
{
    VkResult const status = vkCreateGraphicsPipelines(device, VK_NULL_HANDLE, 1U, &pipelineInfo, nullptr, &m_pipeline);
    vkDestroyShaderModule(device, vert, nullptr);
    vkDestroyShaderModule(device, frag, nullptr);

    if (status != VK_SUCCESS) {
        return false;
    }

    SetLabel(device, m_pipeline, VK_OBJECT_TYPE_PIPELINE, "Blit");
    return true;
}

bool Blit::CreatePipeline(VkDevice device, BlitDescriptor const & desc)
{
    AAssetImporter &importer = AAssetImporter::Instance();
    auto const vs = importer.ImportShaderAsset("quad.vert.spv");
    if (!vs) {
        GOLOGE("Load vs shader asset failed!");
        return false;
    }

    auto const fs = importer.ImportShaderAsset("quad.frag.spv");
    if (!fs) {
        GOLOGE("Load fs shader asset failed!");
        return false;
    }

    VkShaderModule vert = CreateShaderModule(vs->shaderData);
    VkShaderModule frag = CreateShaderModule(fs->shaderData);

    VkPipelineShaderStageCreateInfo stagesInfo[2]{};
    SetStagesInfo(stagesInfo, vert, frag);

    VkPipelineVertexInputStateCreateInfo vertexInfo = GetVertexInfo();

    VkPipelineInputAssemblyStateCreateInfo inputAssemblyInfo = GetInputAssemblyInfo();

    VkViewport const viewport = GetViewport(desc.dstResolution);

    VkRect2D const scissor = GetScissor(desc.dstResolution);

    VkPipelineViewportStateCreateInfo const viewportInfo = GetViewportInfo(viewport, scissor);

    VkPipelineRasterizationStateCreateInfo const rasterizationInfo = GetRasterizationInfo();

    VkPipelineMultisampleStateCreateInfo multisampleInfo = GetMultisampleInfo();

    VkPipelineDepthStencilStateCreateInfo depthStencilInfo = GetDepthStencilInfo();

    VkPipelineColorBlendAttachmentState blendAttachmentStates[2]{};
    SetBlendAttachmentStates(blendAttachmentStates);

    VkPipelineColorBlendStateCreateInfo const colorBlendInfo = GetColorBlendInfo(blendAttachmentStates);

    VkGraphicsPipelineCreateInfo const pipelineInfo {
        .sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .stageCount = static_cast<uint32_t>(std::size(stagesInfo)),
        .pStages = stagesInfo,
        .pVertexInputState = &vertexInfo,
        .pInputAssemblyState = &inputAssemblyInfo,
        .pTessellationState = nullptr,
        .pViewportState = &viewportInfo,
        .pRasterizationState = &rasterizationInfo,
        .pMultisampleState = &multisampleInfo,
        .pDepthStencilState = &depthStencilInfo,
        .pColorBlendState = &colorBlendInfo,
        .pDynamicState = nullptr,
        .layout = m_pipelineLayout,
        .renderPass = desc.renderPass,
        .subpass = desc.subpass,
        .basePipelineHandle = VK_NULL_HANDLE,
        .basePipelineIndex = -1
    };

    return CreatePipelineResources(device, pipelineInfo, m_pipeline, vert, frag);
}
} // namespace VulkanFG
