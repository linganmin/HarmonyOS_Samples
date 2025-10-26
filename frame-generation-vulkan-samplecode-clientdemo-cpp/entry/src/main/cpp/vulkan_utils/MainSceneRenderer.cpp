/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "MainSceneRenderer.h"
#include "log.hpp"
#include <array>
#include "Utils.h"
#include "Device.h"
#include "DescriptorPool.h"
#include <glm/gtc/matrix_transform.hpp>
#include <random>
namespace VulkanFG {
constexpr uint32_t NUMBER_EIGHT = 8;
constexpr uint32_t NUMBER_SIXTEEN = 16;

void MainSceneRenderer::Init(const MainSceneRendererDescriptor &desc)
{
    m_descriptor = desc;

    CreateVertexBuffer();
    CreateTextures();
    CreateUniformBuffers();
    CreateDynamicUniformBuffers();
    CreateOpaqueRenderPass();
    CreateOpaqueDescriptorSetLayout();
    CreateOpaqueDescriptorSets();
    CreateOpaqueGraphicsPipeline();
}

void SetAttachmentDescs(VkAttachmentDescription attachmentDescs[],
    MainSceneRenderer::MainSceneRendererDescriptor &descriptor)
{
    attachmentDescs[0] = (VkAttachmentDescription) {
        .flags = 0U,
        .format = descriptor.colorFormat,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
        .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    };
    attachmentDescs[1] = (VkAttachmentDescription) {
        .flags = 0U,
        .format = descriptor.depthStencilFormat,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
        .storeOp = VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
        .stencilStoreOp = VK_ATTACHMENT_STORE_OP_STORE,
        .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
        .finalLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL
    };
}

void SetDependenciesExt(VkSubpassDependency dependenciesExt[])
{
    dependenciesExt[0] = (VkSubpassDependency) {
        .srcSubpass = VK_SUBPASS_EXTERNAL,
        .dstSubpass = 0U,

        .srcStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT | VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT |
        VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,

        .dstStageMask = VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT |
        VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,

        .srcAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
        VK_ACCESS_SHADER_READ_BIT,

        .dstAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
        VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,

        .dependencyFlags = 0U
    };
    dependenciesExt[1] = (VkSubpassDependency) {
        .srcSubpass = 0U,
        .dstSubpass = VK_SUBPASS_EXTERNAL,

        .srcStageMask = VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT |
        VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,

        .dstStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT,

        .srcAccessMask = VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT |
        VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,

        .dstAccessMask = VK_ACCESS_SHADER_READ_BIT,
        .dependencyFlags = 0U
    };
}

void MainSceneRenderer::CreateOpaqueRenderPass()
{
    VkAttachmentDescription attachmentDescs[2]{};
    SetAttachmentDescs(attachmentDescs, m_descriptor);

    constexpr static VkAttachmentReference colorReference {
        .attachment = 0U,
        .layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL
    };

    constexpr static VkAttachmentReference depthReference {
        .attachment = 1U,
        .layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL
    };

    constexpr VkSubpassDescription subpassExt {
        .flags = 0U,
        .pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS,
        .inputAttachmentCount = 0U,
        .pInputAttachments = nullptr,
        .colorAttachmentCount = 1U,
        .pColorAttachments = &colorReference,
        .pResolveAttachments = nullptr,
        .pDepthStencilAttachment = &depthReference,
        .preserveAttachmentCount = 0U,
        .pPreserveAttachments = nullptr
    };

    static VkSubpassDependency dependenciesExt[2]{};
    SetDependenciesExt(dependenciesExt);

    VkRenderPassCreateInfo const renderPassInfoExt {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .pNext = nullptr,
        .flags = 0U,
        .attachmentCount = static_cast<uint32_t>(std::size(attachmentDescs)),
        .pAttachments = attachmentDescs,
        .subpassCount = 1U,
        .pSubpasses = &subpassExt,
        .dependencyCount = static_cast<uint32_t>(std::size(dependenciesExt)),
        .pDependencies = dependenciesExt
    };

    VkDevice device = VulkanFG::Device::Instance().GetNativeDevice();
    VK_CHECK(vkCreateRenderPass(device, &renderPassInfoExt, nullptr, &m_opaqueRenderPass));
    VulkanFG::SetLabel(device, m_opaqueRenderPass, VK_OBJECT_TYPE_RENDER_PASS, "Scene");
}

void MainSceneRenderer::CreateOpaqueDescriptorSetLayout()
{
    VkDescriptorSetLayoutBinding vsUboLayoutBinding{};
    vsUboLayoutBinding.binding = 0;
    vsUboLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    vsUboLayoutBinding.descriptorCount = 1;
    vsUboLayoutBinding.stageFlags = VK_SHADER_STAGE_VERTEX_BIT;
    vsUboLayoutBinding.pImmutableSamplers = nullptr; // Optional

    VkDescriptorSetLayoutBinding vsDynamicUboLayoutBinding{};
    vsDynamicUboLayoutBinding.binding = NUMBER_FIVE;
    vsDynamicUboLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
    vsDynamicUboLayoutBinding.descriptorCount = 1;
    vsDynamicUboLayoutBinding.stageFlags = VK_SHADER_STAGE_VERTEX_BIT;
    vsDynamicUboLayoutBinding.pImmutableSamplers = nullptr; // Optional

    VkDescriptorSetLayoutBinding fsDiffuseSamplerLayoutBinding{};
    fsDiffuseSamplerLayoutBinding.binding = 1;
    fsDiffuseSamplerLayoutBinding.descriptorCount = 1;
    fsDiffuseSamplerLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    fsDiffuseSamplerLayoutBinding.pImmutableSamplers = nullptr;
    fsDiffuseSamplerLayoutBinding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;

    VkDescriptorSetLayoutBinding fsNormalSamplerLayoutBinding{};
    fsNormalSamplerLayoutBinding.binding = NUMBER_TWO;
    fsNormalSamplerLayoutBinding.descriptorCount = 1;
    fsNormalSamplerLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    fsNormalSamplerLayoutBinding.pImmutableSamplers = nullptr;
    fsNormalSamplerLayoutBinding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;

    VkDescriptorSetLayoutBinding fsUboLayoutBinding{};
    fsUboLayoutBinding.binding = NUMBER_THREE;
    fsUboLayoutBinding.descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    fsUboLayoutBinding.descriptorCount = 1;
    fsUboLayoutBinding.stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT;
    fsUboLayoutBinding.pImmutableSamplers = nullptr; // Optional

    std::array<VkDescriptorSetLayoutBinding, NUMBER_FIVE> bindings = { vsUboLayoutBinding, vsDynamicUboLayoutBinding,
        fsDiffuseSamplerLayoutBinding, fsNormalSamplerLayoutBinding, fsUboLayoutBinding };
    VkDescriptorSetLayoutCreateInfo layoutInfo{};
    layoutInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    layoutInfo.bindingCount = static_cast<uint32_t>(bindings.size());
    layoutInfo.pBindings = bindings.data();

    VK_CHECK(vkCreateDescriptorSetLayout(VulkanFG::Device::Instance().GetNativeDevice(), &layoutInfo, nullptr,
        &m_opaqueDescriptorSetLayout));
}

std::unique_ptr<VkPipelineShaderStageCreateInfo[]> MainSceneRenderer::CreateShaderStages(
    VkShaderModule vertShaderModule, VkShaderModule fragShaderModule)
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

VkPipelineColorBlendStateCreateInfo MainSceneRenderer::CreateColorBlending()
{
    static VkPipelineColorBlendAttachmentState colorBlendAttachment{};
    colorBlendAttachment.colorWriteMask =
        VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
    colorBlendAttachment.blendEnable = VK_FALSE;
    colorBlendAttachment.srcColorBlendFactor = VK_BLEND_FACTOR_ONE;  // Optional
    colorBlendAttachment.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
    colorBlendAttachment.colorBlendOp = VK_BLEND_OP_ADD;             // Optional
    colorBlendAttachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;  // Optional
    colorBlendAttachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
    colorBlendAttachment.alphaBlendOp = VK_BLEND_OP_ADD;             // Optional

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

VkPipelineRasterizationStateCreateInfo MainSceneRenderer::CreateRasterizerInfo()
{
    static VkPipelineRasterizationStateCreateInfo rasterizer{};
    rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    rasterizer.depthClampEnable = VK_FALSE;
    rasterizer.rasterizerDiscardEnable = VK_FALSE;
    rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
    rasterizer.lineWidth = 1.0f;
    rasterizer.cullMode = VK_CULL_MODE_BACK_BIT;
    rasterizer.frontFace = VK_FRONT_FACE_COUNTER_CLOCKWISE;
    rasterizer.depthBiasEnable = VK_FALSE;

    return rasterizer;
}

void MainSceneRenderer::CreatePipelineLayout(VkDevice device)
{
    VkPipelineLayoutCreateInfo pipelineLayoutInfo{};
    pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    pipelineLayoutInfo.setLayoutCount = 1;
    pipelineLayoutInfo.pSetLayouts = &m_opaqueDescriptorSetLayout;
    pipelineLayoutInfo.pushConstantRangeCount = 0;    // Optional
    pipelineLayoutInfo.pPushConstantRanges = nullptr; // Optional

    VK_CHECK(vkCreatePipelineLayout(device, &pipelineLayoutInfo, nullptr, &m_opaquePipelineLayout));
}

VkPipelineDepthStencilStateCreateInfo MainSceneRenderer::CreateDepthStencil()
{
    static VkPipelineDepthStencilStateCreateInfo depthStencil{};
    depthStencil.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO;
    depthStencil.depthTestEnable = VK_TRUE;
    depthStencil.depthWriteEnable = VK_TRUE;
    depthStencil.depthCompareOp = VK_COMPARE_OP_LESS;
    depthStencil.depthBoundsTestEnable = VK_FALSE;
    depthStencil.minDepthBounds = 0.0f; // Optional
    depthStencil.maxDepthBounds = 1.0f; // Optional
    depthStencil.stencilTestEnable = VK_TRUE;
    static VkStencilOpState stencilOpState = {
        .failOp = VK_STENCIL_OP_KEEP,
        .passOp = VK_STENCIL_OP_REPLACE,
        .depthFailOp = VK_STENCIL_OP_KEEP,
        .compareOp = VK_COMPARE_OP_ALWAYS,
        .compareMask = 0xff,
        .writeMask = 0xff,
        .reference = 0

    };
    depthStencil.front = stencilOpState; // Optional
    depthStencil.back = stencilOpState;  // Optional
    
    return depthStencil;
}

void MainSceneRenderer::CreatePipeline(VkDevice device, VkPipelineShaderStageCreateInfo *shaderStages,
    VkPipelineVertexInputStateCreateInfo &vertexInputInfo, VkPipelineInputAssemblyStateCreateInfo &inputAssembly,
    VkPipelineRasterizationStateCreateInfo &rasterizer, VkPipelineMultisampleStateCreateInfo &multisampling,
    VkPipelineDepthStencilStateCreateInfo &depthStencil, VkPipelineColorBlendStateCreateInfo &colorBlending)
{
   // =============================== mutable pipeline var ================================
    std::vector<VkDynamicState> dynamicStates = {
        VK_DYNAMIC_STATE_VIEWPORT,
        VK_DYNAMIC_STATE_SCISSOR,
        VK_DYNAMIC_STATE_STENCIL_REFERENCE,
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

    pipelineInfo.layout = m_opaquePipelineLayout;
    pipelineInfo.renderPass = m_opaqueRenderPass;
    pipelineInfo.subpass = 0;

    pipelineInfo.basePipelineHandle = VK_NULL_HANDLE; // Optional
    pipelineInfo.basePipelineIndex = -1;              // Optional

    VK_CHECK(vkCreateGraphicsPipelines(device, VK_NULL_HANDLE, 1U, &pipelineInfo, nullptr, &m_opaqueGraphicsPipeline));
    VulkanFG::SetLabel(device, m_opaqueGraphicsPipeline, VK_OBJECT_TYPE_PIPELINE, "m_opaqueGraphicsPipeline [Scene]");
}

void MainSceneRenderer::CreateOpaqueGraphicsPipeline()
{
    auto vs = VulkanFG::AAssetImporter::Instance().ImportShaderAsset("ff_opaque_vert.spv");
    if (!vs.has_value()) {
        GOLOGE("Load vs shader asset failed!");
        return;
    }
    auto fs = VulkanFG::AAssetImporter::Instance().ImportShaderAsset("ff_frag.spv");
    if (!fs.has_value()) {
        GOLOGE("Load fs shader asset failed!");
        return;
    }
    VkShaderModule vertShaderModule = VulkanFG::CreateShaderModule(vs.value().shaderData);
    VkShaderModule fragShaderModule = VulkanFG::CreateShaderModule(fs.value().shaderData);

    std::unique_ptr<VkPipelineShaderStageCreateInfo[]> shaderStages =
        CreateShaderStages(vertShaderModule, fragShaderModule);

    // =============================== vertex assembly ================================
    auto bindingDescription = VulkanFG::VertexInfo::GetBindingDescription();
    auto attributeDescriptions = VulkanFG::VertexInfo::GetAttributeDescriptions();

    VkPipelineVertexInputStateCreateInfo vertexInputInfo{};
    vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    vertexInputInfo.vertexBindingDescriptionCount = 1;
    vertexInputInfo.vertexAttributeDescriptionCount = static_cast<uint32_t>(attributeDescriptions.size());
    vertexInputInfo.pVertexBindingDescriptions = &bindingDescription;
    vertexInputInfo.pVertexAttributeDescriptions = attributeDescriptions.data();

    VkPipelineInputAssemblyStateCreateInfo inputAssembly{};
    inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
    inputAssembly.primitiveRestartEnable = VK_FALSE;

    // =============================== rasterizer ================================
    VkPipelineRasterizationStateCreateInfo rasterizer = CreateRasterizerInfo();

    // =============================== rasterizer - multisampling ================================
    VkPipelineMultisampleStateCreateInfo multisampling{};
    multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    multisampling.sampleShadingEnable = VK_FALSE;
    multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;

    // =============================== depth-stencil ================================
    VkPipelineDepthStencilStateCreateInfo depthStencil = CreateDepthStencil();

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

void MainSceneRenderer::CreateVertexBuffer()
{
    auto meshAsset = VulkanFG::AAssetImporter::Instance().ImportVertexAttributeAsset("pirate_without_beard.mesh");
    if (!meshAsset.has_value()) {
        GOLOGE("Load mesh asset failed!");
        return;
    }
    auto &mesh = meshAsset.value();
    VulkanFG::BuildVertexBuffer(&m_vertexBuffer, mesh.vertexData.data(), mesh.vertexNum * sizeof(VulkanFG::VertexInfo));
    m_vertexNum = mesh.vertexNum;
}

void MainSceneRenderer::CreateTextures()
{
    auto diffuseAsset = VulkanFG::AAssetImporter::Instance().ImportImageAsset("sp_Material.002_BaseColor.png");
    if (!diffuseAsset.has_value()) {
        GOLOGE("Load diffuse asset failed!");
        return;
    }

    auto &diffuse = diffuseAsset.value();
    uint32_t eleSize = diffuse.format == VulkanFG::AAssetImporter::ImageAsset::Format::RGBA ? 4 : 3;
    VulkanFG::BuildTexture(&m_diffuseTexture, diffuse.imageData.data(), diffuse.width, diffuse.height, eleSize);

    auto normalAsset = VulkanFG::AAssetImporter::Instance().ImportImageAsset("sp_Material.002_Normal.png");
    if (!normalAsset.has_value()) {
        GOLOGE("Load normal asset failed!");
        return;
    }

    auto &normal = normalAsset.value();
    eleSize = normal.format == VulkanFG::AAssetImporter::ImageAsset::Format::RGBA ? NUMBER_FOUR : NUMBER_THREE;
    VulkanFG::BuildTexture(&m_normalTexture, normal.imageData.data(), normal.width, normal.height, eleSize);
}

void MainSceneRenderer::CreateUniformBuffers()
{
    VulkanFG::Buffer::BufferDescriptor bufferDesc;
    bufferDesc.name = "SceneUniformBuffer";
    bufferDesc.bufferSize = sizeof(HostVsUniformBuffer);
    bufferDesc.usage = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
    bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    m_sceneBuffers.resize(m_descriptor.frameInFlightNum);
    for (auto &buffer : m_sceneBuffers) {
        buffer.Init(bufferDesc);
    }

    bufferDesc.name = "LightUniformBuffer";
    bufferDesc.bufferSize = sizeof(HostFsUniformBuffer);
    m_lightBuffers.resize(m_descriptor.frameInFlightNum);

    m_lightBufferObj.g_AmbientLightColor = glm::vec3(47.0F / 255.0F, 45.0F / 255.0F, 45.0F / 255.0F);
    m_lightBufferObj.g_SpotLightColor = glm::vec3(1.0f, 1.0f, 1.0f);
    m_lightBufferObj.g_SpotLightLocation = glm::vec3(1.0f, -1.0f, 1.0f);
    for (auto &buffer : m_lightBuffers) {
        buffer.Init(bufferDesc);
        buffer.UpdateData(&m_lightBufferObj, sizeof(HostFsUniformBuffer));
    }
}

void MainSceneRenderer::CreateDynamicUniformBuffers()
{
    m_dynamicUboAlignedSize = sizeof(PerInstanceBuffer);
    size_t mindynamicUboAlign = Device::Instance().GetPhysicalDeviceProperties().limits.minUniformBufferOffsetAlignment;
    if (mindynamicUboAlign > 0) {
        m_dynamicUboAlignedSize = (m_dynamicUboAlignedSize + mindynamicUboAlign - 1) & ~(mindynamicUboAlign - 1);
    }

    m_dynamicUboAlignedSize--;
    m_dynamicUboAlignedSize |= m_dynamicUboAlignedSize >> 1;
    m_dynamicUboAlignedSize |= m_dynamicUboAlignedSize >> NUMBER_TWO;
    m_dynamicUboAlignedSize |= m_dynamicUboAlignedSize >> NUMBER_FOUR;
    m_dynamicUboAlignedSize |= m_dynamicUboAlignedSize >> NUMBER_EIGHT;
    m_dynamicUboAlignedSize |= m_dynamicUboAlignedSize >> NUMBER_SIXTEEN;
    m_dynamicUboAlignedSize++;

    size_t bufferSize = s_instanceTotalNum * m_dynamicUboAlignedSize;
    m_perInstanceBuffersObj.instanceBuffers =
        static_cast<PerInstanceBuffer *>(AlignedAlloc(bufferSize, m_dynamicUboAlignedSize));
    if (!m_perInstanceBuffersObj.instanceBuffers) {
        GOLOGE("MainSceneRenderer::CreateDynamicUniformBuffers execution failed");
        return;
    }

    GOLOGI("minUniformBufferOffsetAlignment : %u", mindynamicUboAlign);
    GOLOGI("dynamicAlignment for perObjectBuffer : %u", m_dynamicUboAlignedSize);

    VulkanFG::Buffer::BufferDescriptor bufferDesc;
    bufferDesc.name = "PerInstanceDynamicUniformBuffers";
    bufferDesc.bufferSize = bufferSize;
    bufferDesc.usage = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
    bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    m_perInstanceBuffers.resize(m_descriptor.frameInFlightNum);

    std::random_device rd{};
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> luma(0.01F, 1.0F);
    for (int i = 0; i < s_instanceTotalNum; ++i) {
        PerInstanceBuffer *perInstanceBuffer =
            (PerInstanceBuffer *)((uint64_t)m_perInstanceBuffersObj.instanceBuffers + i * m_dynamicUboAlignedSize);
        perInstanceBuffer->modelTransform = glm::mat4(1.0f);
        glm::vec3 color = { 1.0, 1.0, 1.0 };
        color = glm::normalize(color);
        perInstanceBuffer->diffuseColor = { color.x, color.y, color.z, 1.0f };
    }

    for (auto &buffer : m_perInstanceBuffers) {
        buffer.Init(bufferDesc);
        buffer.UpdateData(m_perInstanceBuffersObj.instanceBuffers, buffer.GetSize());
    }
}

void MainSceneRenderer::WriteDescriptorSet(std::array<VkWriteDescriptorSet, NUMBER_FIVE> &descriptorWrites,
    size_t index, VkDescriptorBufferInfo &vsBufferInfo, VkDescriptorImageInfo &diffuseImageInfo,
    VkDescriptorImageInfo &normalImageInfo, VkDescriptorBufferInfo &fsBufferInfo,
    VkDescriptorBufferInfo &vsDynamicBufferInfo)
{
    descriptorWrites[0].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptorWrites[0].dstSet = m_opaqueDescriptorSets[index];
    descriptorWrites[0].dstBinding = 0;
    descriptorWrites[0].dstArrayElement = 0;
    descriptorWrites[0].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    descriptorWrites[0].descriptorCount = 1;
    descriptorWrites[0].pBufferInfo = &vsBufferInfo;

    descriptorWrites[1].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptorWrites[1].dstSet = m_opaqueDescriptorSets[index];
    descriptorWrites[1].dstBinding = 1;
    descriptorWrites[1].dstArrayElement = 0;
    descriptorWrites[1].descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    descriptorWrites[1].descriptorCount = 1;
    descriptorWrites[1].pImageInfo = &diffuseImageInfo;

    descriptorWrites[NUMBER_TWO].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptorWrites[NUMBER_TWO].dstSet = m_opaqueDescriptorSets[index];
    descriptorWrites[NUMBER_TWO].dstBinding = NUMBER_TWO;
    descriptorWrites[NUMBER_TWO].dstArrayElement = 0;
    descriptorWrites[NUMBER_TWO].descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER;
    descriptorWrites[NUMBER_TWO].descriptorCount = 1;
    descriptorWrites[NUMBER_TWO].pImageInfo = &normalImageInfo;

    descriptorWrites[NUMBER_THREE].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptorWrites[NUMBER_THREE].dstSet = m_opaqueDescriptorSets[index];
    descriptorWrites[NUMBER_THREE].dstBinding = NUMBER_THREE;
    descriptorWrites[NUMBER_THREE].dstArrayElement = 0;
    descriptorWrites[NUMBER_THREE].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER;
    descriptorWrites[NUMBER_THREE].descriptorCount = 1;
    descriptorWrites[NUMBER_THREE].pBufferInfo = &fsBufferInfo;

    descriptorWrites[NUMBER_FOUR].sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    descriptorWrites[NUMBER_FOUR].dstSet = m_opaqueDescriptorSets[index];
    descriptorWrites[NUMBER_FOUR].dstBinding = NUMBER_FIVE;
    descriptorWrites[NUMBER_FOUR].dstArrayElement = 0;
    descriptorWrites[NUMBER_FOUR].descriptorType = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC;
    descriptorWrites[NUMBER_FOUR].descriptorCount = 1;
    descriptorWrites[NUMBER_FOUR].pBufferInfo = &vsDynamicBufferInfo;
}

void MainSceneRenderer::CreateOpaqueDescriptorSets()
{
    std::vector<VkDescriptorSetLayout> layouts(m_descriptor.frameInFlightNum, m_opaqueDescriptorSetLayout);
    VkDescriptorSetAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    allocInfo.descriptorPool = DescriptorPool::Instance().GetNativeDescriptorPool();
    allocInfo.descriptorSetCount = static_cast<uint32_t>(m_descriptor.frameInFlightNum);
    allocInfo.pSetLayouts = layouts.data();

    m_opaqueDescriptorSets.resize(m_descriptor.frameInFlightNum);
    VK_CHECK(vkAllocateDescriptorSets(VulkanFG::Device::Instance().GetNativeDevice(), &allocInfo,
        m_opaqueDescriptorSets.data()));

    for (size_t i = 0; i < m_descriptor.frameInFlightNum; ++i) {
        VkDescriptorBufferInfo vsBufferInfo{};
        vsBufferInfo.buffer = m_sceneBuffers[i].GetNativeBuffer();
        vsBufferInfo.offset = 0;
        vsBufferInfo.range = sizeof(HostVsUniformBuffer);

        VkDescriptorImageInfo diffuseImageInfo{};
        diffuseImageInfo.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        diffuseImageInfo.imageView = m_diffuseTexture.GetNativeImageView();
        diffuseImageInfo.sampler = m_diffuseTexture.GetNativeSampler();

        VkDescriptorImageInfo normalImageInfo{};
        normalImageInfo.imageLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        normalImageInfo.imageView = m_normalTexture.GetNativeImageView();
        normalImageInfo.sampler = m_normalTexture.GetNativeSampler();

        VkDescriptorBufferInfo fsBufferInfo{};
        fsBufferInfo.buffer = m_lightBuffers[i].GetNativeBuffer();
        fsBufferInfo.offset = 0;
        fsBufferInfo.range = sizeof(HostFsUniformBuffer);

        VkDescriptorBufferInfo vsDynamicBufferInfo{};
        vsDynamicBufferInfo.buffer = m_perInstanceBuffers[i].GetNativeBuffer();
        vsDynamicBufferInfo.offset = 0;
        vsDynamicBufferInfo.range = m_dynamicUboAlignedSize;

        std::array<VkWriteDescriptorSet, NUMBER_FIVE> descriptorWrites{};

        WriteDescriptorSet(descriptorWrites, i, vsBufferInfo, diffuseImageInfo, normalImageInfo, fsBufferInfo,
            vsDynamicBufferInfo);

        vkUpdateDescriptorSets(VulkanFG::Device::Instance().GetNativeDevice(),
            static_cast<uint32_t>(descriptorWrites.size()), descriptorWrites.data(), 0, nullptr);
    }
}

glm::mat4 AcquireViewMatrix(float camDeltaD)
{
    glm::mat4 rY(1.0f);
    glm::mat4 rX(1.0f);
    glm::mat4 t(1.0f);
    glm::vec3 translationVector = glm::vec3(32.0F * std::cos(0.2F * camDeltaD),
        (10.0F + 6.0F * std::sin(0.3F * camDeltaD)), -(32.0F * std::sin(0.2F * camDeltaD)));

    t = glm::translate(t, translationVector);
    float angleY = -0.2F * camDeltaD;
    glm::vec3 axisY = glm::vec3(0.0f, -1.0f, 0.0f);
    rY = glm::rotate(rY, angleY, axisY);
    float angleX = 0.6F + 0.3F * std::sin(0.3F * camDeltaD);
    glm::vec3 axisX = glm::vec3(-1.0f, 0.0f, 0.0f);
    rX = glm::rotate(rX, angleX, axisX);
    glm::mat4 viewMatrix = glm::inverse(t * rY * rX);
    return viewMatrix;
}

void MainSceneRenderer::Update(uint32_t frameIdx)
{
    static float speed = 1.0f; // degree / s
    static glm::mat4 s_identity = glm::mat4(1.0f);
    static std::chrono::time_point<std::chrono::steady_clock> s_start = std::chrono::steady_clock::now();
    std::chrono::time_point<std::chrono::steady_clock> s_now = std::chrono::steady_clock::now();
    auto deltaT = std::chrono::duration_cast<std::chrono::microseconds>(s_now - s_start).count();
    float deltaD = speed * (deltaT / 1000000.f);

    // Update instance transform
    for (int i = 0; i < s_instanceRowNum; ++i) {
        for (int j = 0; j < s_instanceColumnNum; ++j) {
            uint32_t idx = i * s_instanceColumnNum + j;
            PerInstanceBuffer *perInstanceBuffer =
                (PerInstanceBuffer *)((uint64_t)m_perInstanceBuffersObj.instanceBuffers +
                idx * m_dynamicUboAlignedSize);

            constexpr float distance = DENSITY * DEFAULT_DISTANCE;
            constexpr float offset = -0.5F * distance * static_cast<float>(s_instanceRowNum);
            float angle = (float)(i * s_instanceColumnNum + j);
            glm::vec3 location = glm::vec3(offset + distance * j, 0.0f, -(offset + distance * i));

            angle += deltaD * ROTATION_SPEED;
            glm::mat4 rotation = glm::rotate(glm::mat4(1.0f), angle, ROTATION_AXIS);

            glm::mat4 scale = glm::scale(glm::mat4(1.0f), glm::vec3(SCALE));

            constexpr float wavelength = 1.0F / DENSITY;
            location.y = -WAVE_HEIGHT * std::sin(wavelength * angle);
            glm::mat4 translate = glm::translate(glm::mat4(1.0f), location);

            glm::mat4 transform = translate * rotation * scale;

            perInstanceBuffer->modelTransform = transform;
        }
    }

    m_perInstanceBuffers[frameIdx].UpdateData(m_perInstanceBuffersObj.instanceBuffers,
        m_perInstanceBuffers[frameIdx].GetSize());

    // Update camera

    m_camera.MakePerspective(60.0f, m_descriptor.frameBufferWidth / (float)m_descriptor.frameBufferHeight, 0.1f,
        10000.0f);

    glm::mat4 viewMatrix = AcquireViewMatrix(deltaD);
    m_camera.SetViewMatrix(viewMatrix);

    m_camera.MakePerspective(60.0f, m_descriptor.frameBufferWidth / (float)m_descriptor.frameBufferHeight, 0.1f,
        10000.0f);
    m_sceneBufferObj.viewTransform = m_camera.GetViewMatrix();
    m_sceneBufferObj.perspectiveTransform = m_camera.GetPerspectiveMatrix();
    m_sceneBufferObj.vpTransform = m_camera.GetViewPerspectiveMatrix();
    m_sceneBuffers[frameIdx].UpdateData(&m_sceneBufferObj, sizeof(HostVsUniformBuffer));
}

VkRenderPassBeginInfo GetRenderPassInfo(VkRenderPass &opaqueRenderPass, VkFramebuffer framebuffer,
    MainSceneRenderer::MainSceneRendererDescriptor &descriptor, VkClearValue clearValues[], uint32_t clearValueCount)
{
    VkRenderPassBeginInfo const renderPassInfo {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .pNext = nullptr,
        .renderPass = opaqueRenderPass,
        .framebuffer = framebuffer,

        .renderArea {
            .offset {
                .x = 0,
                .y = 0
            },

            .extent = {
                .width = descriptor.frameBufferWidth,
                .height = descriptor.frameBufferHeight
            }
        },

        .clearValueCount = clearValueCount,
        .pClearValues = clearValues
    };

    return renderPassInfo;
}

void MainSceneRenderer::Render(VkCommandBuffer commandBuffer, VkFramebuffer framebuffer, size_t fifIndex)
{
    VulkanFG::DebugGroup const group(commandBuffer, "Opaque scene");

    VkClearValue clearValues[] = {
        {
            .color {
                .float32{0.0F, 0.0F, 0.0F, 1.0F}
            }
        },
        {
            .depthStencil {
                .depth = 1.0F,
                .stencil = VulkanFG::MainSceneRenderer::s_instanceTotalNum
            }
        }
    };

    VkRenderPassBeginInfo renderPassInfo = GetRenderPassInfo(m_opaqueRenderPass, framebuffer, m_descriptor, clearValues,
        static_cast<uint32_t>(std::size(clearValues)));
    
    VkExtent2D const &extent = renderPassInfo.renderArea.extent;

    vkCmdBeginRenderPass(commandBuffer, &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE);
    vkCmdBindPipeline(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_opaqueGraphicsPipeline);

    VkBuffer vertexBuffer = m_vertexBuffer.GetNativeBuffer();
    constexpr VkDeviceSize offsets = 0U;
    vkCmdBindVertexBuffers(commandBuffer, 0U, 1U, &vertexBuffer, &offsets);

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
    uint32_t dynamicOffset = 0U;

    for (uint32_t i = 0U; i < s_instanceTotalNum; ++i) {
        vkCmdSetStencilReference(commandBuffer, VK_STENCIL_FACE_FRONT_AND_BACK, i);

        vkCmdBindDescriptorSets(commandBuffer, VK_PIPELINE_BIND_POINT_GRAPHICS, m_opaquePipelineLayout, 0U, 1U,
            &m_opaqueDescriptorSets[fifIndex], 1, &dynamicOffset);

        vkCmdDraw(commandBuffer, m_vertexNum, 1U, 0U, 0U);
        dynamicOffset += static_cast<uint32_t>(m_dynamicUboAlignedSize);
    }

    vkCmdEndRenderPass(commandBuffer);
}

VkRenderPass MainSceneRenderer::GetRenderPass() const
{
    return m_opaqueRenderPass;
}

void MainSceneRenderer::Destroy()
{
    VkDevice device = Device::Instance().GetNativeDevice();

    vkDestroyPipeline(device, m_opaqueGraphicsPipeline, nullptr);
    vkDestroyPipelineLayout(device, m_opaquePipelineLayout, nullptr);
    vkFreeDescriptorSets(device, DescriptorPool::Instance().GetNativeDescriptorPool(), m_opaqueDescriptorSets.size(),
        m_opaqueDescriptorSets.data());
    m_opaqueDescriptorSets.clear();
    vkDestroyDescriptorSetLayout(device, m_opaqueDescriptorSetLayout, nullptr);

    if (m_opaqueRenderPass != VK_NULL_HANDLE) {
        vkDestroyRenderPass(device, m_opaqueRenderPass, nullptr);
        m_opaqueRenderPass = VK_NULL_HANDLE;
    }

    for (auto &buffer : m_perInstanceBuffers) {
        buffer.Destroy();
    }
    m_perInstanceBuffers.clear();

    if (m_perInstanceBuffersObj.instanceBuffers) {
        AlignedFree(m_perInstanceBuffersObj.instanceBuffers);
        m_perInstanceBuffersObj.instanceBuffers = nullptr;
    }

    for (auto &buffer : m_sceneBuffers) {
        buffer.Destroy();
    }
    m_sceneBuffers.clear();

    for (auto &buffer : m_lightBuffers) {
        buffer.Destroy();
    }
    m_lightBuffers.clear();

    m_vertexBuffer.Destroy();
    m_vertexNum = 0;

    m_descriptor = MainSceneRendererDescriptor();
}
} // namespace VulkanFG
