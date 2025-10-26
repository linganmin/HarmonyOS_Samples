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

#include "fsr.h"

FSR::~FSR()
{
    vkDestroySampler(m_device, m_colorSampler, nullptr);
    frameBuffers.easu.color.Destroy(m_device);
    frameBuffers.easu.Destroy(m_device);
    frameBuffers.rcas.Destroy(m_device);

    vkDestroyPipeline(m_device, pipelines.rcas, nullptr);
    vkDestroyPipeline(m_device, pipelines.easu, nullptr);

    vkDestroyPipelineLayout(m_device, pipelineLayouts.easu, nullptr);
    vkDestroyPipelineLayout(m_device, pipelineLayouts.rcas, nullptr);

    vkDestroyDescriptorSetLayout(m_device, descriptorSetLayouts.easu, nullptr);
    vkDestroyDescriptorSetLayout(m_device, descriptorSetLayouts.rcas, nullptr);

    uniformBuffers.rcasParams.destroy();

    for (auto& shaderModule : m_shaderModules) {
        vkDestroyShaderModule(m_device, shaderModule, nullptr);
    }
    vkDestroyDescriptorPool(m_device, m_descriptorPool, nullptr);
    vkDestroyPipelineCache(m_device, m_pipelineCache, nullptr);
}

void FSR::Init(InitParams &initParams)
{
    m_format = initParams.format;
    m_physicalDevice = initParams.physicalDevice;
    m_device = initParams.device;
    m_inputView = initParams.inputView;
    m_inputRegion = initParams.inputRegion;
    m_outputView = initParams.outputView;
    m_outputSize = initParams.outputSize;
    m_outputRegion = initParams.outputRegion;
    uboEASU.sharp = initParams.sharpness;
    m_vulkanDevice = initParams.vulkanDevice;

    easuConstants.offsetx = m_inputRegion.offset.x;
    easuConstants.offsety = m_inputRegion.offset.y;
    easuConstants.extentwidth = m_inputRegion.extent.width;
    easuConstants.extentheight = m_inputRegion.extent.height;
    CreatePipelineCache();
    AddEASUResult();
    PrepareOffscreenFramebuffers();
    PrepareUniformBuffers();
    SetupDescriptorPool();
    SetupLayouts();
    SetupDescriptors();
    PreparePipelines();
}

void FSR::Render(VkCommandBuffer cmdBuffer)
{
    BuildCommandBuffers(cmdBuffer);
}

void FSR::AddEASUResult()
{
    VkImageCreateInfo image = vks::initializers::imageCreateInfo();
    image.imageType = VK_IMAGE_TYPE_2D;
    image.format = m_format;
    image.extent.width = m_outputSize.width;
    image.extent.height = m_outputSize.height;
    image.extent.depth = 1;
    image.mipLevels = 1;
    image.arrayLayers = 1;
    image.samples = VK_SAMPLE_COUNT_1_BIT;
    image.tiling = VK_IMAGE_TILING_OPTIMAL;
    image.usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_SAMPLED_BIT;
    VK_CHECK_RESULT(vkCreateImage(m_device, &image, nullptr, &frameBuffers.easu.color.image));

    VkMemoryAllocateInfo memAlloc = vks::initializers::memoryAllocateInfo();
    VkMemoryRequirements memReqs;
    vkGetImageMemoryRequirements(m_device, frameBuffers.easu.color.image, &memReqs);
    memAlloc.allocationSize = memReqs.size;
    memAlloc.memoryTypeIndex = m_vulkanDevice->getMemoryType(memReqs.memoryTypeBits,
        VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VK_CHECK_RESULT(vkAllocateMemory(m_device, &memAlloc, nullptr, &frameBuffers.easu.color.mem));
    VK_CHECK_RESULT(vkBindImageMemory(m_device, frameBuffers.easu.color.image, frameBuffers.easu.color.mem, 0));

    VkImageViewCreateInfo imageView = vks::initializers::imageViewCreateInfo();
    imageView.viewType = VK_IMAGE_VIEW_TYPE_2D;
    imageView.format = m_format;
    imageView.subresourceRange = {};

    imageView.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    imageView.subresourceRange.baseMipLevel = 0;
    imageView.subresourceRange.levelCount = 1;
    imageView.subresourceRange.baseArrayLayer = 0;
    imageView.subresourceRange.layerCount = 1;
    imageView.image = frameBuffers.easu.color.image;
    VK_CHECK_RESULT(vkCreateImageView(m_device, &imageView, nullptr, &frameBuffers.easu.color.view));
}

void FSR::PrepareOffscreenFramebuffers()
{
    frameBuffers.easu.SetSize(static_cast<int32_t>(m_outputSize.width), static_cast<int32_t>(m_outputSize.height));
    frameBuffers.rcas.SetSize(static_cast<int32_t>(m_outputSize.width), static_cast<int32_t>(m_outputSize.height));
    
    VkAttachmentDescription colorAttachment = {};
    colorAttachment.format = m_format;
    colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
    colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
    colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
    colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
    colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
    VkAttachmentReference colorReference = { 0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL };

    VkSubpassDescription subpass = {};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.pColorAttachments = &colorReference;
    subpass.colorAttachmentCount = 1;

    std::array<VkSubpassDependency, 2> dependencies;

    dependencies[0].srcSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[0].dstSubpass = 0;
    dependencies[0].srcStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    dependencies[0].dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    dependencies[0].srcAccessMask = VK_ACCESS_MEMORY_READ_BIT;
    dependencies[0].dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    dependencies[0].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

    dependencies[1].srcSubpass = 0;
    dependencies[1].dstSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[1].srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    dependencies[1].dstStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    dependencies[1].srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    dependencies[1].dstAccessMask = VK_ACCESS_MEMORY_READ_BIT;
    dependencies[1].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

    VkRenderPassCreateInfo renderPassInfo = {};
    renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
    renderPassInfo.pAttachments = &colorAttachment;
    renderPassInfo.attachmentCount = 1;
    renderPassInfo.subpassCount = 1;
    renderPassInfo.pSubpasses = &subpass;
    renderPassInfo.dependencyCount = dependencies.size();
    renderPassInfo.pDependencies = dependencies.data();
    VK_CHECK_RESULT(vkCreateRenderPass(m_device, &renderPassInfo, nullptr, &frameBuffers.easu.renderPass));
    
    VkFramebufferCreateInfo fbufCreateInfo = vks::initializers::framebufferCreateInfo();
    fbufCreateInfo.renderPass = frameBuffers.easu.renderPass;
    fbufCreateInfo.pAttachments = &frameBuffers.easu.color.view;
    fbufCreateInfo.attachmentCount = 1;
    fbufCreateInfo.width = m_outputSize.width;
    fbufCreateInfo.height = m_outputSize.height;
    fbufCreateInfo.layers = 1;
    VK_CHECK_RESULT(vkCreateFramebuffer(m_device, &fbufCreateInfo, nullptr, &frameBuffers.easu.frameBuffer));
    
    fbufCreateInfo.renderPass = frameBuffers.easu.renderPass;
    fbufCreateInfo.pAttachments = &m_outputView;
    fbufCreateInfo.attachmentCount = 1;
    fbufCreateInfo.width = m_outputSize.width;
    fbufCreateInfo.height = m_outputSize.height;
    fbufCreateInfo.layers = 1;
    VK_CHECK_RESULT(vkCreateFramebuffer(m_device, &fbufCreateInfo, nullptr, &frameBuffers.rcas.frameBuffer));
    
    VkSamplerCreateInfo sampler = vks::initializers::samplerCreateInfo();
    sampler.magFilter = VK_FILTER_NEAREST;
    sampler.minFilter = VK_FILTER_NEAREST;
    sampler.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR;
    sampler.addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
    sampler.addressModeV = sampler.addressModeU;
    sampler.addressModeW = sampler.addressModeU;
    sampler.mipLodBias = 0.0f;
    sampler.maxAnisotropy = 1.0f;
    sampler.minLod = 0.0f;
    sampler.maxLod = 1.0f;
    sampler.borderColor = VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
    VK_CHECK_RESULT(vkCreateSampler(m_device, &sampler, nullptr, &m_colorSampler));
}

void FSR::SetupDescriptorPool()
{
    std::vector<VkDescriptorPoolSize> poolSizes = {
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 50),
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 50)
    };
    VkDescriptorPoolCreateInfo descriptorPoolInfo = vks::initializers::descriptorPoolCreateInfo(poolSizes, 10);
    VK_CHECK_RESULT(vkCreateDescriptorPool(m_device, &descriptorPoolInfo, nullptr, &m_descriptorPool));
}

void FSR::SetupLayouts()
{
    std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings;
    VkDescriptorSetLayoutCreateInfo setLayoutCreateInfo;
    VkPipelineLayoutCreateInfo pipelineLayoutCreateInfo = vks::initializers::pipelineLayoutCreateInfo();
    
    setLayoutBindings = {
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 0),
    };

    VkPushConstantRange pushConstantRange = {};
    pushConstantRange.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;
    pushConstantRange.offset = 0;
    pushConstantRange.size = sizeof(PushConstants);

    setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(setLayoutBindings.data(),
        static_cast<uint32_t>(setLayoutBindings.size()));
    VK_CHECK_RESULT(vkCreateDescriptorSetLayout(m_device, &setLayoutCreateInfo, nullptr, &descriptorSetLayouts.easu));
    pipelineLayoutCreateInfo.pSetLayouts = &descriptorSetLayouts.easu;
    pipelineLayoutCreateInfo.pushConstantRangeCount = 1;
    pipelineLayoutCreateInfo.pPushConstantRanges = &pushConstantRange;
    VK_CHECK_RESULT(vkCreatePipelineLayout(m_device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayouts.easu));
    
    setLayoutBindings = {
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 0),
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 1),
    };
    pipelineLayoutCreateInfo.pushConstantRangeCount = 0;
    pipelineLayoutCreateInfo.pPushConstantRanges = VK_NULL_HANDLE;
    setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(setLayoutBindings.data(),
        static_cast<uint32_t>(setLayoutBindings.size()));
    VK_CHECK_RESULT(vkCreateDescriptorSetLayout(m_device, &setLayoutCreateInfo, nullptr, &descriptorSetLayouts.rcas));
    pipelineLayoutCreateInfo.pSetLayouts = &descriptorSetLayouts.rcas;
    VK_CHECK_RESULT(vkCreatePipelineLayout(m_device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayouts.rcas));
}

void FSR::SetupDescriptors()
{
    VkDescriptorSetAllocateInfo descriptorAllocInfo =
        vks::initializers::descriptorSetAllocateInfo(m_descriptorPool, nullptr, 1);
    std::vector<VkWriteDescriptorSet> writeDescriptorSets;
    std::vector<VkDescriptorImageInfo> imageDescriptors;
    
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.easu;
        VK_CHECK_RESULT(vkAllocateDescriptorSets(m_device, &descriptorAllocInfo, &descriptorSets.easu));
        imageDescriptors = {
            vks::initializers::descriptorImageInfo(m_colorSampler, m_inputView,
                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };
        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(descriptorSets.easu, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 0,
                &imageDescriptors[0]),
        };
        vkUpdateDescriptorSets(m_device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(),
            0, NULL);
    }
    
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.rcas;
        VK_CHECK_RESULT(vkAllocateDescriptorSets(m_device, &descriptorAllocInfo, &descriptorSets.rcas));
        imageDescriptors = {
            vks::initializers::descriptorImageInfo(m_colorSampler, frameBuffers.easu.color.view,
                VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };
        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(descriptorSets.rcas, VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 0,
                &uniformBuffers.rcasParams.descriptor),
            vks::initializers::writeDescriptorSet(descriptorSets.rcas, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1,
                &imageDescriptors[0]),
        };
        vkUpdateDescriptorSets(m_device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(),
            0, NULL);
    }
}

void FSR::PreparePipelines()
{
    VkPipelineInputAssemblyStateCreateInfo inputAssemblyState =
        vks::initializers::pipelineInputAssemblyStateCreateInfo(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, 0, VK_FALSE);
    VkPipelineRasterizationStateCreateInfo rasterizationState =
        vks::initializers::pipelineRasterizationStateCreateInfo(VK_POLYGON_MODE_FILL, VK_CULL_MODE_BACK_BIT,
            VK_FRONT_FACE_COUNTER_CLOCKWISE, 0);
    VkPipelineColorBlendAttachmentState blendAttachmentState =
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
    VkPipelineColorBlendStateCreateInfo colorBlendState =
        vks::initializers::pipelineColorBlendStateCreateInfo(1, &blendAttachmentState);
    VkPipelineDepthStencilStateCreateInfo depthStencilState =
        vks::initializers::pipelineDepthStencilStateCreateInfo(VK_TRUE, VK_TRUE, VK_COMPARE_OP_LESS_OR_EQUAL);
    VkPipelineViewportStateCreateInfo viewportState =
        vks::initializers::pipelineViewportStateCreateInfo(1, 1, 0);
    VkPipelineMultisampleStateCreateInfo multisampleState =
        vks::initializers::pipelineMultisampleStateCreateInfo(VK_SAMPLE_COUNT_1_BIT, 0);
    std::vector<VkDynamicState> dynamicStateEnables = { VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR };
    VkPipelineDynamicStateCreateInfo dynamicState =
        vks::initializers::pipelineDynamicStateCreateInfo(dynamicStateEnables);
    std::array<VkPipelineShaderStageCreateInfo, 2> shaderStages;

    VkGraphicsPipelineCreateInfo pipelineCreateInfo = vks::initializers::pipelineCreateInfo();
    pipelineCreateInfo.pInputAssemblyState = &inputAssemblyState;
    pipelineCreateInfo.pRasterizationState = &rasterizationState;
    pipelineCreateInfo.pColorBlendState = &colorBlendState;
    pipelineCreateInfo.pMultisampleState = &multisampleState;
    pipelineCreateInfo.pViewportState = &viewportState;
    pipelineCreateInfo.pDepthStencilState = &depthStencilState;
    pipelineCreateInfo.pDynamicState = &dynamicState;
    pipelineCreateInfo.stageCount = static_cast<uint32_t>(shaderStages.size());
    pipelineCreateInfo.pStages = shaderStages.data();
    pipelineCreateInfo.flags = 0;

    {
        VkPipelineVertexInputStateCreateInfo emptyVertexInputState =
            vks::initializers::pipelineVertexInputStateCreateInfo();
        pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
        pipelineCreateInfo.renderPass = frameBuffers.easu.renderPass;
        pipelineCreateInfo.layout = pipelineLayouts.easu;
        rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

        blendAttachmentState = vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
        colorBlendState.attachmentCount = 1;
        colorBlendState.pAttachments = &blendAttachmentState;

        shaderStages[0] = LoadShader(GetShadersPath() + "/shader/algorithm/fullscreen.vert.spv",
            VK_SHADER_STAGE_VERTEX_BIT);
        shaderStages[1] = LoadShader(GetShadersPath() + "/shader/algorithm/easu.frag.spv",
            VK_SHADER_STAGE_FRAGMENT_BIT);
        VK_CHECK_RESULT(vkCreateGraphicsPipelines(m_device, m_pipelineCache, 1, &pipelineCreateInfo, nullptr,
            &pipelines.easu));
    }
    
    {
        VkPipelineVertexInputStateCreateInfo emptyVertexInputState =
            vks::initializers::pipelineVertexInputStateCreateInfo();
        pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
        pipelineCreateInfo.renderPass = frameBuffers.easu.renderPass;
        pipelineCreateInfo.layout = pipelineLayouts.rcas;
        rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

        blendAttachmentState = vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
        colorBlendState.attachmentCount = 1;
        colorBlendState.pAttachments = &blendAttachmentState;

        shaderStages[0] = LoadShader(GetShadersPath() + "/shader/algorithm/fullscreen.vert.spv",
            VK_SHADER_STAGE_VERTEX_BIT);
        shaderStages[1] = LoadShader(GetShadersPath() + "/shader/algorithm/rcas.frag.spv",
            VK_SHADER_STAGE_FRAGMENT_BIT);
        VK_CHECK_RESULT(vkCreateGraphicsPipelines(m_device, m_pipelineCache, 1, &pipelineCreateInfo, nullptr,
            &pipelines.rcas));
    }
}


void FSR::PrepareUniformBuffers()
{
    VK_CHECK_RESULT(m_vulkanDevice->createBuffer(
        VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
        VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        &uniformBuffers.rcasParams,
        sizeof(UBOEASU)));
    VK_CHECK_RESULT(uniformBuffers.rcasParams.map());

    memcpy(uniformBuffers.rcasParams.mapped, &uboEASU, sizeof(UBOEASU));
    uniformBuffers.rcasParams.unmap();
}

VkPipelineShaderStageCreateInfo FSR::LoadShader(std::string fileName, VkShaderStageFlagBits stage)
{
    VkPipelineShaderStageCreateInfo shaderStage = {};
    shaderStage.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    shaderStage.stage = stage;
    shaderStage.module = vks::tools::loadShader(fileName.c_str(), m_device);
    shaderStage.pName = "main";
    assert(shaderStage.module != VK_NULL_HANDLE);
    m_shaderModules.push_back(shaderStage.module);
    return shaderStage;
}

std::string FSR::GetShadersPath() const
{
    return FileOperator::GetInstance()->GetAssetPath();
}

void FSR::CreatePipelineCache()
{
    VkPipelineCacheCreateInfo pipelineCacheCreateInfo = {};
    pipelineCacheCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO;
    VK_CHECK_RESULT(vkCreatePipelineCache(m_device, &pipelineCacheCreateInfo, nullptr, &m_pipelineCache));
}

void FSR::BuildCommandBuffers(VkCommandBuffer cmdBuffer)
{
    VkClearValue clearValues[2];
    clearValues[0].color = { 1.0f, 1.0f, 1.0f, 1.0f };
    clearValues[1].depthStencil = { 1.0f, 0 };
    VkRenderPassBeginInfo renderPassBeginInfo = vks::initializers::renderPassBeginInfo();
    VkViewport viewport;
    VkRect2D scissor;
    
    renderPassBeginInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
    renderPassBeginInfo.pNext = nullptr;
    renderPassBeginInfo.renderPass = frameBuffers.easu.renderPass;
    renderPassBeginInfo.framebuffer = frameBuffers.easu.frameBuffer;
    renderPassBeginInfo.renderArea.offset.x = 0;
    renderPassBeginInfo.renderArea.offset.y = 0;
    renderPassBeginInfo.renderArea.extent.width = m_outputSize.width;
    renderPassBeginInfo.renderArea.extent.height = m_outputSize.height;
    renderPassBeginInfo.clearValueCount = 2;
    renderPassBeginInfo.pClearValues = clearValues;
    vkCmdBeginRenderPass(cmdBuffer, &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

    viewport = vks::initializers::viewport((float)frameBuffers.easu.width, (float)frameBuffers.easu.height, 0.0f, 1.0f);
    vkCmdSetViewport(cmdBuffer, 0, 1, &viewport);
    scissor = vks::initializers::rect2D(frameBuffers.easu.width, frameBuffers.easu.height, 0, 0);
    vkCmdSetScissor(cmdBuffer, 0, 1, &scissor);

    vkCmdBindDescriptorSets(cmdBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.easu, 0, 1,
        &descriptorSets.easu, 0, nullptr);
    vkCmdBindPipeline(cmdBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelines.easu);
    vkCmdPushConstants(cmdBuffer, pipelineLayouts.easu, VK_SHADER_STAGE_FRAGMENT_BIT, 0, sizeof(PushConstants),
        &easuConstants);
    vkCmdDraw(cmdBuffer, 3, 1, 0, 0);
    vkCmdEndRenderPass(cmdBuffer);

    VkImageMemoryBarrier imageMemoryBarrier{};
    imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    imageMemoryBarrier.srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    imageMemoryBarrier.dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED;
    imageMemoryBarrier.image = frameBuffers.easu.color.image;
    imageMemoryBarrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    imageMemoryBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
    imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
    imageMemoryBarrier.subresourceRange = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };

    vkCmdPipelineBarrier(cmdBuffer, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, 0, nullptr, 0, nullptr, 1, &imageMemoryBarrier);
    
    renderPassBeginInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
    renderPassBeginInfo.pNext = nullptr;
    renderPassBeginInfo.renderPass = frameBuffers.easu.renderPass;
    renderPassBeginInfo.framebuffer = frameBuffers.rcas.frameBuffer;
    renderPassBeginInfo.renderArea.offset.x = 0;
    renderPassBeginInfo.renderArea.offset.y = 0;
    renderPassBeginInfo.renderArea.extent.width = m_outputSize.width;
    renderPassBeginInfo.renderArea.extent.height = m_outputSize.height;
    renderPassBeginInfo.clearValueCount = 2;
    renderPassBeginInfo.pClearValues = clearValues;
    vkCmdBeginRenderPass(cmdBuffer, &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

    VkViewport dynamicViewport{};
    dynamicViewport.x = m_outputRegion.offset.x;
    dynamicViewport.y = m_outputRegion.offset.y;
    dynamicViewport.width = m_outputRegion.extent.width;
    dynamicViewport.height = m_outputRegion.extent.height;
    dynamicViewport.minDepth = 0.0f;
    dynamicViewport.maxDepth = 1.0f;

    VkRect2D dynamicScissor = {};
    dynamicScissor.offset = { 0, 0 };
    dynamicScissor.extent.width = m_outputSize.width;
    dynamicScissor.extent.height = m_outputSize.height;

    vkCmdSetViewport(cmdBuffer, 0, 1, &dynamicViewport);
    vkCmdSetScissor(cmdBuffer, 0, 1, &dynamicScissor);
    vkCmdBindDescriptorSets(cmdBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.rcas, 0, 1,
        &descriptorSets.rcas, 0, nullptr);
    vkCmdBindPipeline(cmdBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, pipelines.rcas);
    vkCmdDraw(cmdBuffer, 3, 1, 0, 0);

    vkCmdEndRenderPass(cmdBuffer);
}