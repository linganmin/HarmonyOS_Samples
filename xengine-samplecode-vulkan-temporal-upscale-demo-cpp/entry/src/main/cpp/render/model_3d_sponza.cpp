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

#include "model_3d_sponza.h"
#include <dlfcn.h>

VulkanExample::~VulkanExample()
{
    LOGI("VulkanExample destory.");
    DestroyFrameBuffers();

    vkDestroyPipeline(device, pipelines.gBufferLight, nullptr);
    vkDestroyPipeline(device, pipelines.light, nullptr);
    vkDestroyPipeline(device, pipelines.swap, nullptr);

    vkDestroyPipeline(device, upscalePipelines.gBufferLight, nullptr);
    vkDestroyPipeline(device, upscalePipelines.light, nullptr);
    vkDestroyPipeline(device, upscalePipelines.swapUpscale, nullptr);

    vkDestroyPipelineLayout(device, pipelineLayouts.gBufferLight, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.light, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.swap, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.copyDepth, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.cameraMotionVector, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.objectMotionVector, nullptr);

    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.gBufferLight, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.light, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.swap, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.copyDepth, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.cameraMotionVector, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.objectMotionVector, nullptr);

    DestroyXegHandles();
    m_scene.Destroy();
    uniformBuffers.sceneParams.destroy();
    uniformBuffers.lightParams.destroy();
    uniformBuffers.cameraMVParams.destroy();

    if (fsr != nullptr) {
        delete fsr;
    }
}

void VulkanExample::DestroyFrameBuffers()
{
    frameBuffers.gBufferLight.position.Destroy(device);
    frameBuffers.gBufferLight.normal.Destroy(device);
    frameBuffers.gBufferLight.viewNormal.Destroy(device);
    frameBuffers.gBufferLight.albedo.Destroy(device);
    frameBuffers.gBufferLight.depth.Destroy(device);
    frameBuffers.light.color.Destroy(device);
    frameBuffers.gBufferLight.destroy(device);
    frameBuffers.light.destroy(device);

    upscaleFrameBuffers.gBufferLight.position.Destroy(device);
    upscaleFrameBuffers.gBufferLight.normal.Destroy(device);
    upscaleFrameBuffers.gBufferLight.viewNormal.Destroy(device);
    upscaleFrameBuffers.gBufferLight.albedo.Destroy(device);
    upscaleFrameBuffers.gBufferLight.depth.Destroy(device);
    upscaleFrameBuffers.light.color.Destroy(device);
    upscaleFrameBuffers.upscale.color.Destroy(device);
    upscaleFrameBuffers.gBufferLight.destroy(device);
    upscaleFrameBuffers.light.destroy(device);
    upscaleFrameBuffers.copyDepth.depth.Destroy(device);
    upscaleFrameBuffers.motionVector.mv.Destroy(device);
    upscaleFrameBuffers.motionVector.dynamicMask.Destroy(device);
    upscaleFrameBuffers.copyDepth.destroy(device);
    upscaleFrameBuffers.motionVector.destroy(device);
}

void VulkanExample::DestroyXegHandles()
{
    if (xegSpatialUpscale) {
        HMS_XEG_DestroySpatialUpscale(xegSpatialUpscale);
    }

    if (xegTemporalUpscale) {
        HMS_XEG_DestroyTemporalUpscale(xegTemporalUpscale);
    }

    if (xeg_adaptiveVRS) {
        HMS_XEG_DestroyAdaptiveVRS(xeg_adaptiveVRS);
    }

    if (xeg_adaptiveVRS4Upscale) {
        HMS_XEG_DestroyAdaptiveVRS(xeg_adaptiveVRS4Upscale);
    }
}

void VulkanExample::GetEnabledFeatures()
{
    LOGI("VulkanExample Enable Features.");
    enabledFeatures.samplerAnisotropy = deviceFeatures.samplerAnisotropy;
    enabledPhysicalDeviceShadingRateImageFeaturesKHR.sType =
        VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR;
    enabledPhysicalDeviceShadingRateImageFeaturesKHR.attachmentFragmentShadingRate = VK_TRUE;
    enabledPhysicalDeviceShadingRateImageFeaturesKHR.pipelineFragmentShadingRate = VK_TRUE;
    enabledPhysicalDeviceShadingRateImageFeaturesKHR.primitiveFragmentShadingRate = VK_FALSE;
    deviceCreatepNextChain = &enabledPhysicalDeviceShadingRateImageFeaturesKHR;
}

void VulkanExample::CreateAttachment(VkFormat format, VkImageUsageFlagBits usage, FrameBufferAttachment *attachment,
    uint32_t width, uint32_t height)
{
    VkImageAspectFlags aspectMask = 0;

    attachment->format = format;

    if (usage & VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT) {
        aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    }
    if (usage & VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT) {
        aspectMask = VK_IMAGE_ASPECT_DEPTH_BIT;
        if (format >= VK_FORMAT_D16_UNORM_S8_UINT) {
            aspectMask |= VK_IMAGE_ASPECT_STENCIL_BIT;
        }
    }
    assert(aspectMask > 0);

    VkImageCreateInfo image = vks::initializers::imageCreateInfo();
    image.imageType = VK_IMAGE_TYPE_2D;
    image.format = format;
    image.extent.width = width;
    image.extent.height = height;
    image.extent.depth = 1;
    image.mipLevels = 1;
    image.arrayLayers = 1;
    image.samples = VK_SAMPLE_COUNT_1_BIT;
    image.tiling = VK_IMAGE_TILING_OPTIMAL;
    image.usage = usage | VK_IMAGE_USAGE_SAMPLED_BIT;

    VkMemoryAllocateInfo memAlloc = vks::initializers::memoryAllocateInfo();
    VkMemoryRequirements memReqs;

    VK_CHECK_RESULT(vkCreateImage(device, &image, nullptr, &attachment->image));
    vkGetImageMemoryRequirements(device, attachment->image, &memReqs);
    memAlloc.allocationSize = memReqs.size;
    memAlloc.memoryTypeIndex = vulkanDevice->getMemoryType(memReqs.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VK_CHECK_RESULT(vkAllocateMemory(device, &memAlloc, nullptr, &attachment->mem));
    VK_CHECK_RESULT(vkBindImageMemory(device, attachment->image, attachment->mem, 0));

    VkImageViewCreateInfo imageView = vks::initializers::imageViewCreateInfo();
    imageView.viewType = VK_IMAGE_VIEW_TYPE_2D;
    imageView.format = format;
    imageView.subresourceRange = {};
    imageView.subresourceRange.aspectMask = aspectMask;
    imageView.subresourceRange.baseMipLevel = 0;
    imageView.subresourceRange.levelCount = 1;
    imageView.subresourceRange.baseArrayLayer = 0;
    imageView.subresourceRange.layerCount = 1;
    imageView.image = attachment->image;
    VK_CHECK_RESULT(vkCreateImageView(device, &imageView, nullptr, &attachment->view));
}

void VulkanExample::PrepareShadingRateImage(uint32_t sriWidth, uint32_t sriHeight, FrameBufferAttachment *attachment)
{
    physicalDeviceShadingRateImageProperties.sType =
        VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_PROPERTIES_KHR;
    VkPhysicalDeviceProperties2 deviceProperties2{};
    deviceProperties2.sType = VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2;
    deviceProperties2.pNext = &physicalDeviceShadingRateImageProperties;
    vkGetPhysicalDeviceProperties2(physicalDevice, &deviceProperties2);
    const VkFormat imageFormat = VK_FORMAT_R8_UINT;
    VkFormatProperties formatProperties;
    vkGetPhysicalDeviceFormatProperties(physicalDevice, imageFormat, &formatProperties);
    if (!(formatProperties.optimalTilingFeatures & VK_FORMAT_FEATURE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR)) {
        LOGE("VulkanExample Selected shading rate attachment image format does not fragment shading rate.");
        return;
    }

    VkImageCreateInfo imageCI{};
    imageCI.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    imageCI.imageType = VK_IMAGE_TYPE_2D;
    imageCI.format = imageFormat;
    imageCI.extent.width = sriWidth;
    imageCI.extent.height = sriHeight;
    imageCI.extent.depth = 1;
    imageCI.mipLevels = 1;
    imageCI.arrayLayers = 1;
    imageCI.samples = VK_SAMPLE_COUNT_1_BIT;
    imageCI.tiling = VK_IMAGE_TILING_LINEAR;
    imageCI.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    imageCI.sharingMode = VK_SHARING_MODE_EXCLUSIVE;
    imageCI.usage = VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR | VK_IMAGE_USAGE_TRANSFER_DST_BIT |
                    VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_STORAGE_BIT;

    VK_CHECK_RESULT(vkCreateImage(device, &imageCI, nullptr, &attachment->image));
    VkMemoryRequirements memReqs{};
    vkGetImageMemoryRequirements(device, attachment->image, &memReqs);
    VkMemoryAllocateInfo memAllloc{};
    memAllloc.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    memAllloc.allocationSize = memReqs.size;
    memAllloc.memoryTypeIndex = vulkanDevice->getMemoryType(memReqs.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    VK_CHECK_RESULT(vkAllocateMemory(device, &memAllloc, nullptr, &attachment->mem));
    VK_CHECK_RESULT(vkBindImageMemory(device, attachment->image, attachment->mem, 0));
    VkImageViewCreateInfo imageViewCI{};
    imageViewCI.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    imageViewCI.viewType = VK_IMAGE_VIEW_TYPE_2D;
    imageViewCI.image = attachment->image;
    imageViewCI.format = imageFormat;
    imageViewCI.subresourceRange.baseMipLevel = 0;
    imageViewCI.subresourceRange.levelCount = 1;
    imageViewCI.subresourceRange.baseArrayLayer = 0;
    imageViewCI.subresourceRange.layerCount = 1;
    imageViewCI.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    VK_CHECK_RESULT(vkCreateImageView(device, &imageViewCI, nullptr, &attachment->view));
}

void VulkanExample::ResizeFrameBuffers()
{
    frameBuffers.gBufferLight.setSize(highResWidth, highResHeight);
    frameBuffers.light.setSize(highResWidth, highResHeight);
    frameBuffers.shadingRate.setSize(highResWidth, highResHeight);

    upscaleFrameBuffers.gBufferLight.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.light.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.upscale.setSize(highResWidth, highResHeight);
    upscaleFrameBuffers.shadingRate.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.copyDepth.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.motionVector.setSize(lowResWidth, lowResHeight);
}

void VulkanExample::CreateRenderPassAttachment()
{
    VkFormat attDepthFormat;
    VkBool32 validDepthFormat = vks::tools::getSupportedDepthFormat(physicalDevice, &attDepthFormat);
    assert(validDepthFormat);
    // G-Buffer Attachment
    CreateAttachment(VK_FORMAT_R32G32B32A32_SFLOAT, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &frameBuffers.gBufferLight.position, highResWidth, highResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &frameBuffers.gBufferLight.normal,
                     highResWidth, highResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &frameBuffers.gBufferLight.viewNormal, highResWidth, highResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &frameBuffers.gBufferLight.albedo,
                     highResWidth, highResHeight);
    CreateAttachment(attDepthFormat, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, &frameBuffers.gBufferLight.depth,
                     highResWidth, highResHeight);

    CreateAttachment(VK_FORMAT_R32G32B32A32_SFLOAT, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &upscaleFrameBuffers.gBufferLight.position, lowResWidth, lowResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &upscaleFrameBuffers.gBufferLight.normal, lowResWidth, lowResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &upscaleFrameBuffers.gBufferLight.viewNormal, lowResWidth, lowResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
                     &upscaleFrameBuffers.gBufferLight.albedo, lowResWidth, lowResHeight);
    CreateAttachment(attDepthFormat, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT,
                     &upscaleFrameBuffers.gBufferLight.depth, lowResWidth, lowResHeight);

    // Light Attachment
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &frameBuffers.light.color,
                     highResWidth, highResHeight);
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &upscaleFrameBuffers.light.color,
                     lowResWidth, lowResHeight);

    // Upscale Attachment
    CreateAttachment(VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &upscaleFrameBuffers.upscale.color,
                     highResWidth, highResHeight);

    CreateAttachment(VK_FORMAT_R16G16_SFLOAT, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT, &upscaleFrameBuffers.motionVector.mv,
                     lowResWidth, lowResHeight);
    CreateAttachment(VK_FORMAT_R8_UNORM, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        &upscaleFrameBuffers.motionVector.dynamicMask, lowResWidth, lowResHeight);

    // copy depth
    CreateAttachment(attDepthFormat, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, &upscaleFrameBuffers.copyDepth.depth,
                     lowResWidth, lowResHeight);
}

VkAttachmentDescription VulkanExample::CreateVkAttachmentDescription(VkImageLayout finalLayout, VkFormat format)
{
    VkAttachmentDescription attachmentDesc;
    attachmentDesc.samples = VK_SAMPLE_COUNT_1_BIT;
    attachmentDesc.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
    attachmentDesc.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
    attachmentDesc.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    attachmentDesc.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
    attachmentDesc.finalLayout = finalLayout;
    attachmentDesc.format = format;
    return attachmentDesc;
}

std::vector<VkSubpassDependency> VulkanExample::CreateSubpassDependency(
    VkPipelineStageFlags dstStageMask, VkAccessFlags dstAccessMask)
{
    std::vector<VkSubpassDependency> dependencies(2);
    dependencies[0].srcSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[0].dstSubpass = 0;
    dependencies[0].srcStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
    dependencies[0].dstStageMask = dstStageMask;
    dependencies[0].srcAccessMask = VK_ACCESS_SHADER_READ_BIT;
    dependencies[0].dstAccessMask = dstAccessMask;
    dependencies[0].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

    dependencies[1].srcSubpass = 0;
    dependencies[1].dstSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[1].srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    dependencies[1].dstStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
    dependencies[1].srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    dependencies[1].dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
    dependencies[1].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;
    return dependencies;
}

VkRenderPassCreateInfo VulkanExample::CreateRenderPassInfo(VkAttachmentDescription* pAttachments,
    uint32_t attachmentCount, VkSubpassDescription &subpass, VkSubpassDependency* pDependencies)
{
    VkRenderPassCreateInfo renderPassInfo = {};
    renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
    renderPassInfo.pAttachments = pAttachments;
    renderPassInfo.attachmentCount = attachmentCount;
    renderPassInfo.subpassCount = 1;
    renderPassInfo.pSubpasses = &subpass;
    renderPassInfo.dependencyCount = 2;
    renderPassInfo.pDependencies = pDependencies;
    return renderPassInfo;
}

VkFramebufferCreateInfo VulkanExample::CreateFrameBufferInfo(VkRenderPass, uint32_t width,
    uint32_t height, VkImageView* date, uint32_t size)
{
    VkFramebufferCreateInfo fbufCreateInfo{};
    fbufCreateInfo.renderPass = frameBuffers.gBufferLight.renderPass;
    fbufCreateInfo.pAttachments = date;
    fbufCreateInfo.attachmentCount = size;
    fbufCreateInfo.width = width;
    fbufCreateInfo.height = height;
    fbufCreateInfo.layers = 1;
    return fbufCreateInfo;
}

VkAttachmentDescription2KHR VulkanExample::CreateVkAttachmentDescription2KHR(VkImageLayout finalLayout, VkFormat format)
{
    VkAttachmentDescription2KHR attachments;
    attachments.sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
    attachments.format = frameBuffers.light.color.format;
    attachments.samples = VK_SAMPLE_COUNT_1_BIT;
    attachments.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
    attachments.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
    attachments.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    attachments.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
    attachments.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    attachments.finalLayout = finalLayout;
    attachments.format = format;
    return attachments;
}

VkSubpassDescription2KHR VulkanExample::CreateSunbpassDescription2KHRInfo(VkAttachmentReference2KHR &colorReference,
    VkFragmentShadingRateAttachmentInfoKHR &fragmentShadingRateAttachmentInfo)
{
    VkSubpassDescription2KHR subpassDescription = {};
    subpassDescription.sType = VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2;
    subpassDescription.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpassDescription.colorAttachmentCount = 1;
    subpassDescription.pColorAttachments = &colorReference;
    subpassDescription.inputAttachmentCount = 0;
    subpassDescription.pInputAttachments = nullptr;
    subpassDescription.preserveAttachmentCount = 0;
    subpassDescription.pPreserveAttachments = nullptr;
    subpassDescription.pResolveAttachments = nullptr;
    subpassDescription.pNext = &fragmentShadingRateAttachmentInfo;
    return subpassDescription;
}

std::array<VkSubpassDependency2KHR, 2> VulkanExample::CreateSubpassDependencies()
{
    std::array<VkSubpassDependency2KHR, 2> dependencies = {};

    dependencies[0].sType = VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2;
    dependencies[0].srcSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[0].dstSubpass = 0;
    dependencies[0].srcStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    dependencies[0].dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
                                   VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT |
                                   VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
    dependencies[0].srcAccessMask = VK_ACCESS_MEMORY_READ_BIT;
    dependencies[0].dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
                                    VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
                                    VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
    dependencies[0].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

    dependencies[1].sType = VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2;
    dependencies[1].srcSubpass = 0;
    dependencies[1].dstSubpass = VK_SUBPASS_EXTERNAL;
    dependencies[1].srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT |
                                   VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT |
                                   VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT;
    dependencies[1].dstStageMask = VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT;
    dependencies[1].srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT |
                                    VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT |
                                    VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT;
    dependencies[1].dstAccessMask = VK_ACCESS_MEMORY_READ_BIT;
    dependencies[1].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;
    return dependencies;
}

VkRenderPassCreateInfo2KHR VulkanExample::CreateRenderPassCI(uint32_t attachmentCount, VkAttachmentDescription2* date,
    uint32_t dependencyCount, VkSubpassDependency2* pDependencies, VkSubpassDescription2KHR &subpassDescription)
{
    VkRenderPassCreateInfo2KHR renderPassCI = {};
    renderPassCI.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2;
    renderPassCI.attachmentCount = attachmentCount;
    renderPassCI.pAttachments = date;
    renderPassCI.subpassCount = 1;
    renderPassCI.pSubpasses = &subpassDescription;
    renderPassCI.dependencyCount = dependencyCount;
    renderPassCI.pDependencies = pDependencies;
    return renderPassCI;
}

template<typename T>
std::vector<VkImageView> VulkanExample::CreateImageViewAttachment(const T& fb)
{
    std::vector<VkImageView> attachments(5);
    attachments[0] = fb.gBufferLight.position.view;
    attachments[1] = fb.gBufferLight.normal.view;
    attachments[2] = fb.gBufferLight.albedo.view;
    attachments[3] = fb.gBufferLight.depth.view;
    attachments[4] = fb.gBufferLight.viewNormal.view;
    return attachments;
}

template<typename T>
std::vector<VkAttachmentDescription> VulkanExample::SetAttachmentDescriptionformat(
    const T& fb, std::vector<VkAttachmentDescription> attachmentDescs)
{
    attachmentDescs[0].format = fb.gBufferLight.position.format;
    attachmentDescs[1].format = fb.gBufferLight.normal.format;
    attachmentDescs[2].format = fb.gBufferLight.albedo.format;
    attachmentDescs[3].format = fb.gBufferLight.depth.format;
    attachmentDescs[4].format = fb.gBufferLight.viewNormal.format;
    return attachmentDescs;
}

void VulkanExample::PrepareGBufferRenderPass()
{
    std::vector<VkAttachmentDescription> attachmentDescs(5);
    for (uint32_t i = 0; i < static_cast<uint32_t>(attachmentDescs.size()); i++) {
        attachmentDescs[i] = CreateVkAttachmentDescription(
            (i == 3) ?VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL :
            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_FORMAT_R8G8B8A8_UNORM);
    }
    attachmentDescs = SetAttachmentDescriptionformat(frameBuffers, attachmentDescs);
    std::vector<VkAttachmentReference> colorReferences;
    colorReferences.push_back({0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});
    colorReferences.push_back({1, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});
    colorReferences.push_back({2, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});
    colorReferences.push_back({4, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});

    VkAttachmentReference depthReference = {};
    depthReference.attachment = 3;
    depthReference.layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

    VkSubpassDescription subpass = {};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.pColorAttachments = colorReferences.data();
    subpass.colorAttachmentCount = static_cast<uint32_t>(colorReferences.size());
    subpass.pDepthStencilAttachment = &depthReference;
    std::vector<VkSubpassDependency> dependencies = CreateSubpassDependency(
        VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
    VkRenderPassCreateInfo renderPassInfo = CreateRenderPassInfo(
        attachmentDescs.data(), static_cast<uint32_t>(attachmentDescs.size()), subpass, dependencies.data());
    VK_CHECK_RESULT(vkCreateRenderPass(device, &renderPassInfo, nullptr, &frameBuffers.gBufferLight.renderPass));
    std::vector<VkImageView> attachments = CreateImageViewAttachment(frameBuffers);
    VkFramebufferCreateInfo fbufCreateInfo = vks::initializers::framebufferCreateInfo();
    fbufCreateInfo = CreateFrameBufferInfo(
        frameBuffers.gBufferLight.renderPass, frameBuffers.gBufferLight.width,
        frameBuffers.gBufferLight.height, attachments.data(), static_cast<uint32_t>(attachments.size()));
    VK_CHECK_RESULT(vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &frameBuffers.gBufferLight.frameBuffer));
    attachmentDescs = SetAttachmentDescriptionformat(upscaleFrameBuffers, attachmentDescs);
    renderPassInfo = CreateRenderPassInfo(attachmentDescs.data(), static_cast<uint32_t>(attachmentDescs.size()),
        subpass,  dependencies.data());
    VK_CHECK_RESULT(
        vkCreateRenderPass(device, &renderPassInfo, nullptr, &upscaleFrameBuffers.gBufferLight.renderPass));
    attachments = CreateImageViewAttachment(upscaleFrameBuffers);
    fbufCreateInfo = CreateFrameBufferInfo(
        upscaleFrameBuffers.gBufferLight.renderPass, upscaleFrameBuffers.gBufferLight.width,
        upscaleFrameBuffers.gBufferLight.height, attachments.data(), static_cast<uint32_t>(attachments.size()));
    VK_CHECK_RESULT(
        vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &upscaleFrameBuffers.gBufferLight.frameBuffer));
}

void VulkanExample::PrepareLightRenderPass()
{
    // need 2 attachment, light and shading rate image
    std::vector<VkAttachmentDescription2KHR> attachments(2);
    attachments[0] = CreateVkAttachmentDescription2KHR(
        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_FORMAT_R8G8B8A8_UNORM);
    attachments[1]= CreateVkAttachmentDescription2KHR(
        VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR, VK_FORMAT_R8G8B8A8_UNORM);

    VkAttachmentReference2KHR colorReference = {};
    colorReference.sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
    colorReference.attachment = 0;
    colorReference.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    colorReference.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;

    VkAttachmentReference2 fragmentShadingRateReference{};
    fragmentShadingRateReference.sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
    fragmentShadingRateReference.attachment = 1;
    fragmentShadingRateReference.layout = VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;

    VkFragmentShadingRateAttachmentInfoKHR fragmentShadingRateAttachmentInfo{};
    fragmentShadingRateAttachmentInfo.sType = VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR;
    fragmentShadingRateAttachmentInfo.pFragmentShadingRateAttachment = &fragmentShadingRateReference;
    fragmentShadingRateAttachmentInfo.shadingRateAttachmentTexelSize.width = VRS_TILE_SIZE;
    fragmentShadingRateAttachmentInfo.shadingRateAttachmentTexelSize.height = VRS_TILE_SIZE;

    VkSubpassDescription2KHR subpassDescription = CreateSunbpassDescription2KHRInfo(colorReference,
        fragmentShadingRateAttachmentInfo);

    std::array<VkSubpassDependency2KHR, 2> dependencies = CreateSubpassDependencies();
    
    VkRenderPassCreateInfo2KHR renderPassCI = CreateRenderPassCI(static_cast<uint32_t>(attachments.size()),
        attachments.data(), static_cast<uint32_t>(dependencies.size()), dependencies.data(), subpassDescription);
    if (vkCreateRenderPass2KHR == nullptr) {
        LOGE("VulkanExample vkCreateRenderPass2KHR get failed");
    }

    vkCreateRenderPass2KHR(device, &renderPassCI, nullptr, &frameBuffers.shadingRate.renderPass);

    VkImageView attachmentsView[2];
    attachmentsView[0] = frameBuffers.light.color.view;
    attachmentsView[1] = frameBuffers.shadingRate.color.view;

    VkFramebufferCreateInfo frameBufferCreateInfo = CreateFrameBufferInfo(
        frameBuffers.shadingRate.renderPass, frameBuffers.light.width,
        frameBuffers.light.height, attachmentsView ,2);
    VK_CHECK_RESULT(
        vkCreateFramebuffer(device, &frameBufferCreateInfo, nullptr, &frameBuffers.shadingRate.frameBuffer));
}

void VulkanExample::PrepareUpscaleRenderpass()
{
    std::vector<VkAttachmentDescription2KHR> attachments(2);
    attachments[0] = CreateVkAttachmentDescription2KHR(
        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_FORMAT_R8G8B8A8_UNORM);
    attachments[1]= CreateVkAttachmentDescription2KHR(
        VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR, VK_FORMAT_R8G8B8A8_UNORM);
    VkAttachmentReference2KHR colorReference = {};
    colorReference.sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
    colorReference.attachment = 0;
    colorReference.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    colorReference.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;

    VkAttachmentReference2 fragmentShadingRateReference{};
    fragmentShadingRateReference.sType = VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2;
    fragmentShadingRateReference.attachment = 1;
    fragmentShadingRateReference.layout = VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;

    VkFragmentShadingRateAttachmentInfoKHR fragmentShadingRateAttachmentInfo{};
    fragmentShadingRateAttachmentInfo.sType = VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR;
    fragmentShadingRateAttachmentInfo.pFragmentShadingRateAttachment = &fragmentShadingRateReference;
    fragmentShadingRateAttachmentInfo.shadingRateAttachmentTexelSize.width = VRS_TILE_SIZE;
    fragmentShadingRateAttachmentInfo.shadingRateAttachmentTexelSize.height = VRS_TILE_SIZE;

    VkSubpassDescription2KHR subpassDescription =  CreateSunbpassDescription2KHRInfo(colorReference,
        fragmentShadingRateAttachmentInfo);

    std::array<VkSubpassDependency2KHR, 2> dependencies = CreateSubpassDependencies();

    VkRenderPassCreateInfo2KHR renderPassCI = CreateRenderPassCI(static_cast<uint32_t>(attachments.size()),
        attachments.data(), static_cast<uint32_t>(dependencies.size()), dependencies.data(), subpassDescription);;
    VK_CHECK_RESULT(
        vkCreateRenderPass2KHR(device, &renderPassCI, nullptr, &upscaleFrameBuffers.shadingRate.renderPass));

    VkImageView attachmentsView[2];
    attachmentsView[0] = upscaleFrameBuffers.light.color.view;
    attachmentsView[1] = upscaleFrameBuffers.shadingRate.color.view;

    VkFramebufferCreateInfo frameBufferCreateInfo = CreateFrameBufferInfo(
        frameBuffers.shadingRate.renderPass, frameBuffers.light.width, frameBuffers.light.height, attachmentsView , 2);
    VK_CHECK_RESULT(
        vkCreateFramebuffer(device, &frameBufferCreateInfo, nullptr, &upscaleFrameBuffers.shadingRate.frameBuffer));
}

void VulkanExample::PrepareMVRenderPass()
{
    std::vector<VkAttachmentDescription> attachmentDescs(3);
    for (uint32_t i = 0; i < static_cast<uint32_t>(attachmentDescs.size()); i++) {
        attachmentDescs[i] = CreateVkAttachmentDescription(
            (i == 2) ? VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL :
            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_FORMAT_R8G8B8A8_UNORM);
    }
    attachmentDescs[2].loadOp = VK_ATTACHMENT_LOAD_OP_LOAD;
    attachmentDescs[2].initialLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL;
    attachmentDescs[0].format = upscaleFrameBuffers.motionVector.mv.format;
    attachmentDescs[1].format = upscaleFrameBuffers.motionVector.dynamicMask.format;
    attachmentDescs[2].format = upscaleFrameBuffers.gBufferLight.depth.format;
    
    std::vector<VkAttachmentReference> colorReferences;
    colorReferences.push_back({0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});
    colorReferences.push_back({1, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL});

    VkAttachmentReference depthReference = {};
    depthReference.attachment = 2;
    depthReference.layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;

    VkSubpassDescription subpass = {};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.pColorAttachments = colorReferences.data();
    subpass.colorAttachmentCount = static_cast<uint32_t>(colorReferences.size());
    subpass.pDepthStencilAttachment = &depthReference;

    // Use subpass dependencies for attachment layout transitions
    VkAccessFlags dstStageMask =
        VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT | VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT;
    VkAccessFlags dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT;
    std::vector<VkSubpassDependency> dependencies = CreateSubpassDependency(
        dstStageMask, dstAccessMask);
    
    // upscale
    VkRenderPassCreateInfo renderPassInfo = CreateRenderPassInfo(
        attachmentDescs.data(), static_cast<uint32_t>(attachmentDescs.size()), subpass, dependencies.data());
    VK_CHECK_RESULT(
        vkCreateRenderPass(device, &renderPassInfo, nullptr, &upscaleFrameBuffers.motionVector.renderPass));
    
    std::array<VkImageView, 3> attachments;
    attachments[0] = upscaleFrameBuffers.motionVector.mv.view;
    attachments[1] = upscaleFrameBuffers.motionVector.dynamicMask.view;
    attachments[2] = upscaleFrameBuffers.gBufferLight.depth.view;

    VkFramebufferCreateInfo fbufCreateInfo = vks::initializers::framebufferCreateInfo();
    fbufCreateInfo = CreateFrameBufferInfo(
        upscaleFrameBuffers.motionVector.renderPass, upscaleFrameBuffers.motionVector.width,
    upscaleFrameBuffers.motionVector.height, attachments.data(), static_cast<uint32_t>(attachments.size()));
    VK_CHECK_RESULT(
        vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &upscaleFrameBuffers.motionVector.frameBuffer));
}

void VulkanExample::PrepareCopyRenderPass()
{
    std::array<VkAttachmentDescription, 1> attachmentDescs = {};
    attachmentDescs[0] = CreateVkAttachmentDescription(VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL,
        upscaleFrameBuffers.copyDepth.depth.format);
    VkAttachmentReference depthReference = {};
    depthReference.attachment = 0;
    depthReference.layout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL;
    VkSubpassDescription subpass = {};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.pDepthStencilAttachment = &depthReference;
    
    // Use subpass dependencies for attachment layout transitions
    std::vector<VkSubpassDependency> dependencies = CreateSubpassDependency(
        VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT, VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT);
    
    VkRenderPassCreateInfo renderPassInfo = CreateRenderPassInfo(
        attachmentDescs.data(), static_cast<uint32_t>(attachmentDescs.size()), subpass, dependencies.data());
    
    // upscale
    VK_CHECK_RESULT(
        vkCreateRenderPass(device, &renderPassInfo, nullptr, &upscaleFrameBuffers.copyDepth.renderPass));
    
    std::array<VkImageView, 1> attachments;
    attachments[0] = upscaleFrameBuffers.copyDepth.depth.view;
    
    VkFramebufferCreateInfo fbufCreateInfo = vks::initializers::framebufferCreateInfo();
    fbufCreateInfo = CreateFrameBufferInfo(
        upscaleFrameBuffers.copyDepth.renderPass, upscaleFrameBuffers.copyDepth.width,
        upscaleFrameBuffers.copyDepth.height, attachments.data(), static_cast<uint32_t>(attachments.size()));
    VK_CHECK_RESULT(
        vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &upscaleFrameBuffers.copyDepth.frameBuffer));
}


void VulkanExample::PrepareOffscreenFrameBuffers()
{
    ResizeFrameBuffers();
    CreateRenderPassAttachment();

    PrepareShadingRateImage((uint32_t)lowResWidth / VRS_TILE_SIZE, (uint32_t)lowResHeight / VRS_TILE_SIZE,
                            &upscaleFrameBuffers.shadingRate.color);
    PrepareShadingRateImage((uint32_t)highResWidth / VRS_TILE_SIZE, (uint32_t)highResHeight / VRS_TILE_SIZE,
                            &frameBuffers.shadingRate.color);

    LOGI("VulkanExample Before UpScale Size: %{public}d, %{public}d", lowResWidth, lowResHeight);
    LOGI("VulkanExample After UpScale Size: %{public}d, %{public}d", highResWidth, highResHeight);

    PrepareGBufferRenderPass();
    // Light Render Pass And FrameBuffer, Support VRS
    PrepareLightRenderPass();
    PrepareUpscaleRenderpass();
    // motion vector
    PrepareMVRenderPass();
    // copy depth
    PrepareCopyRenderPass();
    // Sampler
    // Sampler
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
    sampler.maxLod = 8.0f;
    sampler.borderColor = VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE;
    VK_CHECK_RESULT(vkCreateSampler(device, &sampler, nullptr, &colorSampler));
}

void VulkanExample::LoadAssets()
{
    std::string modelPath = FileOperator::GetInstance()->GetFileAbsolutePath("Sponza/sponza.obj");
    m_scene.LoadFromFile(modelPath, vulkanDevice, queue);
}

std::vector<VkClearValue> VulkanExample::GetClearValues()
{
    std::vector<VkClearValue> clearValues(5);
    clearValues[0].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
    clearValues[1].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
    clearValues[2].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
    clearValues[3].depthStencil = {1.0f, 0};
    clearValues[4].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
    return clearValues;
}

void VulkanExample::BuildCommandBuffers()
{
    if (use_method != 0) {
        BuildUpscaleCommandBuffers();
        return;
    }
    frameNum = 0;
    VkCommandBufferBeginInfo cmdBufInfo = vks::initializers::commandBufferBeginInfo();
    VkExtent2D fragmentSize = {1, 1};
    VkFragmentShadingRateCombinerOpKHR combinerOps[2];
    
    LOGI("VulkanExample Do not use Upscale.");
    VK_CHECK_RESULT(vkBeginCommandBuffer(drawCmdBuffers[currentBuffer], &cmdBufInfo));

    // First Pass: GBuffer
    std::vector<VkClearValue> clearValues = GetClearValues();
    SetBeginRenderPass(clearValues, frameBuffers.gBufferLight, pipelineLayouts.gBufferLight,
        pipelines.gBufferLight, descriptorSets.gBufferLight);
    m_scene.Draw(drawCmdBuffers[currentBuffer], 0x00000001, pipelineLayouts.gBufferLight, 1);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);

    // When use vrs, Dispatch vrs to compute sri
    if (use_vrs) {
        DispatchVRS(false, drawCmdBuffers[currentBuffer]);
    } else {
        LOGI("VulkanExample do not use vrs.");
    }

    // Second Pass: Light Pass, Support VRS
    clearValues[0].color = defaultClearColor;
    clearValues[1].depthStencil = {1.0f, 0};
    SetBeginRenderPass(clearValues, frameBuffers.shadingRate, pipelineLayouts.light,
        pipelines.light, descriptorSets.light);
    if (use_vrs) {
        // If shading rate from attachment is enabled, we set the combiner, so that the values from the attachment
        // are used Combiner for pipeline (A) and primitive (B) - Not used in this sample
        combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
        // Combiner for pipeline (A) and attachment (B), replace the pipeline default value (fragment_size) with the
        // fragment sizes stored in the attachment
        combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
    } else {
        // If shading rate from attachment is disabled, we keep the value set via the dynamic state
        combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
        combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
    }
    vkCmdSetFragmentShadingRateKHR(drawCmdBuffers[currentBuffer], &fragmentSize, combinerOps);
    vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);

    // Final Pass: To Full Screen
    clearValues[0].color = defaultClearColor;
    clearValues[1].depthStencil = {1.0f, 0};

    FrameBuffer submitFb = {screenWidth, screenHeight, VulkanExampleBase::frameBuffers[currentBuffer], renderPass};
    SetBeginRenderPass(clearValues, submitFb, pipelineLayouts.swap, pipelines.swap, descriptorSets.swap);
    vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);
    VK_CHECK_RESULT(vkEndCommandBuffer(drawCmdBuffers[currentBuffer]));
}

void VulkanExample::SetBeginRenderPass(
    std::vector<VkClearValue> &clearValues, FrameBuffer &fb, VkPipelineLayout &layout, VkPipeline &pipeline,
    VkDescriptorSet &descriptorSet)
{
    VkRenderPassBeginInfo renderPassBeginInfo = vks::initializers::renderPassBeginInfo();
    renderPassBeginInfo.renderPass = fb.renderPass;
    renderPassBeginInfo.framebuffer = fb.frameBuffer;
    renderPassBeginInfo.renderArea.extent.width = fb.width;
    renderPassBeginInfo.renderArea.extent.height = fb.height;
    renderPassBeginInfo.clearValueCount = static_cast<uint32_t>(clearValues.size());
    renderPassBeginInfo.pClearValues = clearValues.data();
    vkCmdBeginRenderPass(drawCmdBuffers[currentBuffer], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);
    VkViewport viewport = vks::initializers::viewport((float)fb.width, (float)fb.height, 0.0f, 1.0f);
    vkCmdSetViewport(drawCmdBuffers[currentBuffer], 0, 1, &viewport);
    VkRect2D scissor = vks::initializers::rect2D(fb.width, fb.height, 0, 0);
    vkCmdSetScissor(drawCmdBuffers[currentBuffer], 0, 1, &scissor);
    
    vkCmdBindPipeline(drawCmdBuffers[currentBuffer], VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline);
    vkCmdBindDescriptorSets(drawCmdBuffers[currentBuffer], VK_PIPELINE_BIND_POINT_GRAPHICS, layout, 0, 1,
                            &descriptorSet, 0, NULL);
}

void VulkanExample::RecordTURenderPass(std::vector<VkClearValue> &clearValues)
{
    if (use_method != 3 || xegTemporalUpscale == nullptr) {
        return;
    }

    // copy depth
    clearValues[0].depthStencil = {1.0f, 0};
    SetBeginRenderPass(
        clearValues, upscaleFrameBuffers.copyDepth, pipelineLayouts.copyDepth, upscalePipelines.copyDepth,
        upscaleDescriptorSets.copyDepth);
    vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);

    // motion vector
    if (frameNum > 0) {
        clearValues[0].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[1].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        SetBeginRenderPass(clearValues, upscaleFrameBuffers.motionVector, pipelineLayouts.cameraMotionVector,
            upscalePipelines.cameraMotionVector, upscaleDescriptorSets.cameraMotionVector);
        vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
        vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);
    }
    
    LOGI("VulkanExample example use temporal upscale.");
    XEG_TemporalUpscaleDescription xegDescription;
    xegDescription.inputImage = upscaleFrameBuffers.light.color.view;
    xegDescription.depthImage = upscaleFrameBuffers.gBufferLight.depth.view;
    xegDescription.motionVectorImage = upscaleFrameBuffers.motionVector.mv.view;
    xegDescription.dynamicMaskImage = upscaleFrameBuffers.motionVector.dynamicMask.view;
    xegDescription.outputImage = upscaleFrameBuffers.upscale.color.view;
    xegDescription.jitterX = -jitterX;
    xegDescription.jitterY = -jitterY;
    xegDescription.resetHistory = (frameNum == 0) ? true : false;
    xegDescription.steadyLevel = 0.5;
    HMS_XEG_CmdRenderTemporalUpscale(drawCmdBuffers[currentBuffer], xegTemporalUpscale, &xegDescription);
}

void VulkanExample::BuildUpscaleCommandBuffers()
{
    VkCommandBufferBeginInfo cmdBufInfo = vks::initializers::commandBufferBeginInfo();
    VK_CHECK_RESULT(vkBeginCommandBuffer(drawCmdBuffers[currentBuffer], &cmdBufInfo));

    // First Pass: GBuffer
    std::vector<VkClearValue> clearValues = GetClearValues();
    SetBeginRenderPass(clearValues, upscaleFrameBuffers.gBufferLight, pipelineLayouts.gBufferLight,
        upscalePipelines.gBufferLight, descriptorSets.gBufferLight);
    m_scene.Draw(drawCmdBuffers[currentBuffer], 0x00000001, pipelineLayouts.gBufferLight, 1);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);

    // when use vrs, dispatchvrs to compute sri
    if (use_vrs) {
        DispatchVRS(true, drawCmdBuffers[currentBuffer]);
    } else {
        LOGI("VulkanExample not use vrs");
    }

    // Second Pass: Light Pass, Support VRS
    clearValues[0].color = defaultClearColor;
    clearValues[1].depthStencil = {1.0f, 0};

    SetBeginRenderPass(clearValues, upscaleFrameBuffers.shadingRate, pipelineLayouts.light,
        upscalePipelines.light, upscaleDescriptorSets.light);
    VkFragmentShadingRateCombinerOpKHR combinerOps[2];
    if (use_vrs) {
        // If shading rate from attachment is enabled, we set the combiner, so that the values from the attachment
        // are used Combiner for pipeline (A) and primitive (B) - Not used in this sample
        combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
        // Combiner for pipeline (A) and attachment (B), replace the pipeline default value (fragment_size) with the
        // fragment sizes stored in the attachment
        combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
    } else {
        // If shading rate from attachment is disabled, we keep the value set via the dynamic state
        combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
        combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
    }
    VkExtent2D fragmentSize = {1, 1};
    vkCmdSetFragmentShadingRateKHR(drawCmdBuffers[currentBuffer], &fragmentSize, combinerOps);
    vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);

    RecordTURenderPass(clearValues);

    if (use_method == 1 && xegSpatialUpscale) {
        frameNum = 0;
        LOGI("VulkanExample example use spatial upscale.");
        XEG_SpatialUpscaleDescription xegDescription{0};
        xegDescription.inputImage = upscaleFrameBuffers.light.color.view;
        xegDescription.outputImage = upscaleFrameBuffers.upscale.color.view;
        HMS_XEG_CmdRenderSpatialUpscale(drawCmdBuffers[currentBuffer], xegSpatialUpscale, &xegDescription);
    } else if (use_method == 2) {
        frameNum = 0;
        LOGI("VulkanExample example use fsr upscale.");
        fsr->Render(drawCmdBuffers[currentBuffer]);
    }

    clearValues[0].color = defaultClearColor;
    clearValues[1].depthStencil = {1.0f, 0};
    FrameBuffer submitFb = {screenWidth, screenHeight, VulkanExampleBase::frameBuffers[currentBuffer], renderPass};
    SetBeginRenderPass( clearValues, submitFb, pipelineLayouts.swap,
        upscalePipelines.swapUpscale, upscaleDescriptorSets.swapUpscale);
    vkCmdDraw(drawCmdBuffers[currentBuffer], 3, 1, 0, 0);
    vkCmdEndRenderPass(drawCmdBuffers[currentBuffer]);
    VK_CHECK_RESULT(vkEndCommandBuffer(drawCmdBuffers[currentBuffer]));
}

void VulkanExample::SetupDescriptorPool()
{
    std::vector<VkDescriptorPoolSize> poolSizes = {
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 60),
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 60)};
    VkDescriptorPoolCreateInfo descriptorPoolInfo = vks::initializers::descriptorPoolCreateInfo(poolSizes, 120);
    VK_CHECK_RESULT(vkCreateDescriptorPool(device, &descriptorPoolInfo, nullptr, &descriptorPool));
}

void VulkanExample::CreatePipelineLayout(std::vector<VkDescriptorSetLayoutBinding> &setLayoutBindings,
    VkDescriptorSetLayout &setLayout, VkPipelineLayout &pipelineLayout, bool needScene)
{
    VkDescriptorSetLayoutCreateInfo setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(
        setLayoutBindings.data(), static_cast<uint32_t>(setLayoutBindings.size()));
    VK_CHECK_RESULT(vkCreateDescriptorSetLayout(device, &setLayoutCreateInfo, nullptr, &setLayout));

    std::vector<VkDescriptorSetLayout> setLayouts = {setLayout};
    if (needScene) {
        setLayouts = {setLayout, m_scene.m_descriptorSetLayoutImage};
    }
    VkPipelineLayoutCreateInfo pipelineLayoutCreateInfo = vks::initializers::pipelineLayoutCreateInfo();
    pipelineLayoutCreateInfo.pSetLayouts = setLayouts.data();
    pipelineLayoutCreateInfo.setLayoutCount = static_cast<uint32_t>(setLayouts.size());
    VK_CHECK_RESULT(vkCreatePipelineLayout(device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayout));
}

void VulkanExample::SetupLayouts()
{
    std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings;

    // Light G-Buffer creation
    setLayoutBindings = {vks::initializers::descriptorSetLayoutBinding(
        VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT, 0)};
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.gBufferLight, pipelineLayouts.gBufferLight, true);

    // Light creation
    setLayoutBindings = {
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 0),
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 1),
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 2),
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 3),
    };
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.light, pipelineLayouts.light, false);

    setLayoutBindings = {vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        VK_SHADER_STAGE_FRAGMENT_BIT, 0)};
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.swap, pipelineLayouts.swap, false);

    //  Camera Motion Vector
    setLayoutBindings = {
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 0),
        vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            VK_SHADER_STAGE_FRAGMENT_BIT, 1)};
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.cameraMotionVector,
        pipelineLayouts.cameraMotionVector, false);

    // Object Motion Vector
    setLayoutBindings = {vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
        VK_SHADER_STAGE_VERTEX_BIT, 0)};
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.objectMotionVector,
        pipelineLayouts.objectMotionVector, false);

    // Copy Depth
    setLayoutBindings = {vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        VK_SHADER_STAGE_FRAGMENT_BIT, 0)};
    CreatePipelineLayout(setLayoutBindings, descriptorSetLayouts.copyDepth, pipelineLayouts.copyDepth, false);
}

void VulkanExample::AllocateAndUpdateDescriptorSets(VkDescriptorSetLayout &layout, VkDescriptorSet &vkDescriptorSet)
{
    VkDescriptorSetAllocateInfo descriptorAllocInfo =
        vks::initializers::descriptorSetAllocateInfo(descriptorPool, nullptr, 1);
    descriptorAllocInfo.pSetLayouts = &layout;
    if (vkDescriptorSet == VK_NULL_HANDLE) {
        VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &vkDescriptorSet));
    }

    std::vector<VkWriteDescriptorSet> writeDescriptorSets;
    uint size = descriptorSetInfo.imageViews.size();
    std::vector<VkDescriptorImageInfo> imageDescriptors(size);
    for (u_int i = 0; i < size; i++) {
        imageDescriptors[i] = vks::initializers::descriptorImageInfo(colorSampler, descriptorSetInfo.imageViews[i],
            descriptorSetInfo.imageLayout);
        VkWriteDescriptorSet descriptorSet = vks::initializers::writeDescriptorSet(
            vkDescriptorSet, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, i, &imageDescriptors[i]);
        writeDescriptorSets.push_back(descriptorSet);
    }

    VkWriteDescriptorSet writeDescriptorSet;
    if (descriptorSetInfo.needUbo) {
        writeDescriptorSet = vks::initializers::writeDescriptorSet(vkDescriptorSet,
            VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, size, &descriptorSetInfo.uniformDescriptor);
        writeDescriptorSets.push_back(writeDescriptorSet);
    }

    vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
        NULL);
}

void VulkanExample::SetupDescriptors()
{
    // G-Buffer descriptor
    descriptorSetInfo = {{}, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, uniformBuffers.sceneParams.descriptor, true};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.gBufferLight, descriptorSets.gBufferLight);

    // Light descriptor
    descriptorSetInfo = {{frameBuffers.gBufferLight.position.view, frameBuffers.gBufferLight.normal.view,
        frameBuffers.gBufferLight.albedo.view},
        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, uniformBuffers.lightParams.descriptor, true};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.light, descriptorSets.light);

    descriptorSetInfo = {{upscaleFrameBuffers.gBufferLight.position.view, upscaleFrameBuffers.gBufferLight.normal.view,
            upscaleFrameBuffers.gBufferLight.albedo.view},
            VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, uniformBuffers.lightParams.descriptor, true};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.light, upscaleDescriptorSets.light);

    // FINAL
    descriptorSetInfo = {{frameBuffers.light.color.view}, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, {}, false};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.swap, descriptorSets.swap);

    descriptorSetInfo = {{upscaleFrameBuffers.upscale.color.view},
        VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, {}, false};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.swap, upscaleDescriptorSets.swapUpscale);

    // camera motion vector
    descriptorSetInfo = {{upscaleFrameBuffers.copyDepth.depth.view},
        VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL, uniformBuffers.cameraMVParams.descriptor, true};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.cameraMotionVector, upscaleDescriptorSets.cameraMotionVector);

    // object motion vector
    descriptorSetInfo = {{},
        VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL, uniformBuffers.objectMVParams.descriptor, true};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.objectMotionVector, upscaleDescriptorSets.objectMotionVector);

    // copy depth (upscale)
    descriptorSetInfo = {{upscaleFrameBuffers.gBufferLight.depth.view},
        VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL, {}, false};
    AllocateAndUpdateDescriptorSets(descriptorSetLayouts.copyDepth, upscaleDescriptorSets.copyDepth);
}

void VulkanExample::CreateCopyDepthPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
    VkPipelineDepthStencilStateCreateInfo &depthStencilState,
    std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
    VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
    VkPipelineVertexInputStateCreateInfo &emptyVertInputState)
{
    pipelineCreateInfo.pVertexInputState = &emptyVertInputState;
    rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

    depthStencilState =
        vks::initializers::pipelineDepthStencilStateCreateInfo(VK_TRUE, VK_TRUE, VK_COMPARE_OP_ALWAYS);
    pipelineCreateInfo.pDepthStencilState = &depthStencilState;
    pipelineCreateInfo.layout = pipelineLayouts.copyDepth;

    std::string vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/fullscreen.vert.spv");
    std::string fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("tu/copyDepth.frag.spv");
    shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
    shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);

    pipelineCreateInfo.renderPass = upscaleFrameBuffers.copyDepth.renderPass;
    VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
        &upscalePipelines.copyDepth));
}

void VulkanExample::PreparePipelines()
{
    VkPipelineInputAssemblyStateCreateInfo inputAssemblyState =
        vks::initializers::pipelineInputAssemblyStateCreateInfo(VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST, 0, VK_FALSE);
    VkPipelineRasterizationStateCreateInfo rasterizationState = vks::initializers::pipelineRasterizationStateCreateInfo(
        VK_POLYGON_MODE_FILL, VK_CULL_MODE_BACK_BIT, VK_FRONT_FACE_COUNTER_CLOCKWISE, 0);
    VkPipelineColorBlendAttachmentState blendAttachmentState =
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
    VkPipelineColorBlendStateCreateInfo colorBlendState =
        vks::initializers::pipelineColorBlendStateCreateInfo(1, &blendAttachmentState);
    VkPipelineDepthStencilStateCreateInfo depthStencilState =
        vks::initializers::pipelineDepthStencilStateCreateInfo(VK_TRUE, VK_TRUE, VK_COMPARE_OP_LESS_OR_EQUAL);
    VkPipelineViewportStateCreateInfo viewportState = vks::initializers::pipelineViewportStateCreateInfo(1, 1, 0);
    VkPipelineMultisampleStateCreateInfo multisampleState =
        vks::initializers::pipelineMultisampleStateCreateInfo(VK_SAMPLE_COUNT_1_BIT, 0);
    std::vector<VkDynamicState> dynamicStateEnables = {VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR,
                                                       VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR};
    VkPipelineDynamicStateCreateInfo dynamicState =
        vks::initializers::pipelineDynamicStateCreateInfo(dynamicStateEnables);
    std::array<VkPipelineShaderStageCreateInfo, 2> shaderStages;

    VkGraphicsPipelineCreateInfo pipelineCreateInfo =
        vks::initializers::pipelineCreateInfo(pipelineLayouts.swap, renderPass, 0);
    pipelineCreateInfo.pInputAssemblyState = &inputAssemblyState;
    pipelineCreateInfo.pRasterizationState = &rasterizationState;
    pipelineCreateInfo.pColorBlendState = &colorBlendState;
    pipelineCreateInfo.pMultisampleState = &multisampleState;
    pipelineCreateInfo.pViewportState = &viewportState;
    pipelineCreateInfo.pDepthStencilState = &depthStencilState;
    pipelineCreateInfo.pDynamicState = &dynamicState;
    pipelineCreateInfo.stageCount = static_cast<uint32_t>(shaderStages.size());
    pipelineCreateInfo.pStages = shaderStages.data();

    // Empty vertex input state for fullscreen passes
    VkPipelineVertexInputStateCreateInfo emptyVertInputState = vks::initializers::pipelineVertexInputStateCreateInfo();
    pipelineCreateInfo.pVertexInputState = &emptyVertInputState;
    rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

    // Final TO window pipeline
    std::string vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/fullscreen.vert.spv");
    std::string fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/swapChain.frag.spv");
    shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
    shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
    VK_CHECK_RESULT(
        vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.swap));
    VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
        &upscalePipelines.swapUpscale));

    CreateLightPipeline(rasterizationState, colorBlendState, shaderStages, pipelineCreateInfo,
        emptyVertInputState);
    CreateGBufferPipeline(rasterizationState, colorBlendState, shaderStages, pipelineCreateInfo);
    CreateMvPipeline(rasterizationState, colorBlendState, shaderStages, pipelineCreateInfo,
        emptyVertInputState);
    CreateCopyDepthPipeline(rasterizationState, depthStencilState, shaderStages, pipelineCreateInfo,
        emptyVertInputState);
}

void VulkanExample::CreateGBufferPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
    VkPipelineColorBlendStateCreateInfo &colorBlendState,
    std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
    VkGraphicsPipelineCreateInfo &pipelineCreateInfo)
{
    auto ppattributeDescriptions = GetAttributeDescriptions();
    m_vertexInputBindingDescription.binding = 0;
    m_vertexInputBindingDescription.stride = sizeof(vkOBJ::Vertex);
    m_vertexInputBindingDescription.inputRate = VK_VERTEX_INPUT_RATE_VERTEX;
    m_pipelineVertexInputStateCreateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    m_pipelineVertexInputStateCreateInfo.vertexBindingDescriptionCount = 1;
    m_pipelineVertexInputStateCreateInfo.vertexAttributeDescriptionCount =
        static_cast<uint32_t>(ppattributeDescriptions.size());
    m_pipelineVertexInputStateCreateInfo.pVertexBindingDescriptions = &m_vertexInputBindingDescription;
    m_pipelineVertexInputStateCreateInfo.pVertexAttributeDescriptions = ppattributeDescriptions.data();

    pipelineCreateInfo.pVertexInputState = &m_pipelineVertexInputStateCreateInfo;
    pipelineCreateInfo.renderPass = frameBuffers.gBufferLight.renderPass;
    pipelineCreateInfo.layout = pipelineLayouts.gBufferLight;

    std::array<VkPipelineColorBlendAttachmentState, 4> blendAttachmentStates = {
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE),
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE),
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE),
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE)};
    colorBlendState.attachmentCount = static_cast<uint32_t>(blendAttachmentStates.size());
    colorBlendState.pAttachments = blendAttachmentStates.data();
    rasterizationState.cullMode = VK_CULL_MODE_BACK_BIT;

    std::string vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/gbuffer.vert.spv");
    std::string fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/gbuffer.frag.spv");

    shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
    shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
    VK_CHECK_RESULT(
        vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.gBufferLight));

    pipelineCreateInfo.renderPass = upscaleFrameBuffers.gBufferLight.renderPass;
    VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
                                              &upscalePipelines.gBufferLight));
}

void VulkanExample::CreateMvPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
    VkPipelineColorBlendStateCreateInfo &colorBlendState,
    std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
    VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
    VkPipelineVertexInputStateCreateInfo &emptyVertexInputState)
{
    pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
    rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;
    // camera motion vector
    VkPipelineDepthStencilStateCreateInfo depthStencilState =
        vks::initializers::pipelineDepthStencilStateCreateInfo(VK_TRUE, VK_FALSE, VK_COMPARE_OP_ALWAYS);
    pipelineCreateInfo.pDepthStencilState = &depthStencilState;
    pipelineCreateInfo.layout = pipelineLayouts.cameraMotionVector;
    pipelineCreateInfo.renderPass = upscaleFrameBuffers.motionVector.renderPass;

    std::array<VkPipelineColorBlendAttachmentState, 2> blendAttachmentStates = {
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE),
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE)};
    colorBlendState.attachmentCount = static_cast<uint32_t>(blendAttachmentStates.size());
    colorBlendState.pAttachments = blendAttachmentStates.data();

    std::string cameraVsShader = FileOperator::GetInstance()->GetFileAbsolutePath("tu/cameraMotion.vert.spv");
    shaderStages[0] = loadShader(cameraVsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
    std::string cameraFsShader = FileOperator::GetInstance()->GetFileAbsolutePath("tu/cameraMotion.frag.spv");
    shaderStages[1] = loadShader(cameraFsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
    VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
                                              &upscalePipelines.cameraMotionVector));
}

void VulkanExample::CreateLightPipeline(VkPipelineRasterizationStateCreateInfo &rasterizationState,
    VkPipelineColorBlendStateCreateInfo &colorBlendState,
    std::array<VkPipelineShaderStageCreateInfo, 2> &shaderStages,
    VkGraphicsPipelineCreateInfo &pipelineCreateInfo,
    VkPipelineVertexInputStateCreateInfo &emptyVertexInputState)
{
    VkPipelineFragmentShadingRateStateCreateInfoKHR shadingRateInfo = {
        VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR};
    shadingRateInfo.fragmentSize = {1, 1};
    shadingRateInfo.combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
    shadingRateInfo.combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
    pipelineCreateInfo.pNext = &shadingRateInfo;
    pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
    pipelineCreateInfo.renderPass = frameBuffers.shadingRate.renderPass;
    pipelineCreateInfo.layout = pipelineLayouts.light;
    rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

    VkPipelineColorBlendAttachmentState blendAttachmentState =
        vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
    colorBlendState.attachmentCount = 1;
    colorBlendState.pAttachments = &blendAttachmentState;
    
    std::string vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/fullscreen.vert.spv");
    std::string fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/light.frag.spv");
    shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
    shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
    VK_CHECK_RESULT(
        vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.light));
    pipelineCreateInfo.renderPass = upscaleFrameBuffers.shadingRate.renderPass;
    VK_CHECK_RESULT(
        vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &upscalePipelines.light));
    pipelineCreateInfo.pNext = nullptr;
}

void VulkanExample::PrepareUniformBuffers()
{
    // gbuffer matrices
    vulkanDevice->createBuffer(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
                               VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
                               &uniformBuffers.sceneParams, sizeof(uboSceneParams));

    // light params
    VK_CHECK_RESULT(vulkanDevice->createBuffer(
        VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
        &uniformBuffers.lightParams, sizeof(uboLightParams)));
    
    // cameraMV parameters
    vulkanDevice->createBuffer(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
                               VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
                               &uniformBuffers.cameraMVParams, sizeof(uboCameraMVParams));

    // objectMV parameters
    vulkanDevice->createBuffer(VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT,
                               VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT,
                               &uniformBuffers.objectMVParams, sizeof(uboObjectMVParams));

    // Update
    UpdateUniformBufferMatrices();
    UpdateLightUniformBufferParams();
}

void VulkanExample::InitLight()
{
    dirLight.ambient = glm::vec3(0.05f, 0.05f, 0.05f);
    dirLight.diffuse = glm::vec3(0.8f, 0.8f, 0.8f);
    dirLight.lightDir = m_lightDir;
    dirLight.specular = glm::vec3(0.5f, 0.5f, 0.5f);
}

float VulkanExample::GetHaltonSequence(uint32_t index, uint32_t base)
{
    float result = 0.0;
    float fraction = 1.0 / base;

    while (index > 0) {
        result += fraction * (index % base);
        index /= base;
        fraction /= base;
    }
    return result;
}

glm::mat4 VulkanExample::GetJitterMat()
{
    glm::mat4 jitterMat;
    jitterX = GetHaltonSequence((frameNum % jitterNum) + 1, 2) - 0.5;
    jitterY = GetHaltonSequence((frameNum % jitterNum) + 1, 3) - 0.5;
    jitterX = jitterX / lowResWidth;
    jitterY = jitterY / lowResHeight;
    jitterMat = glm::translate(glm::mat4(1.0f), glm::vec3(jitterX, jitterY, 0.0));
    return jitterMat;
}

void VulkanExample::UpdateLightUniformBufferParams()
{
    InitLight();
    uboLightParams.dirLight = dirLight;
    uboLightParams.lightSpaceMatrix = m_lightSpaceMatrix;
    uboLightParams.viewPos = camera.position;
    for (int i = 0; i < LIGHT_NUM; i++) {
        uboLightParams.pointLights[i].position = pointLightPositions[i];
        uboLightParams.pointLights[i].ambient = glm::vec3(0.05f, 0.05f, 0.05f);
        uboLightParams.pointLights[i].diffuse = glm::vec3(0.4f, 0.4f, 0.4f);
        uboLightParams.pointLights[i].specular = glm::vec3(0.5f, 0.5f, 0.5f);
        uboLightParams.pointLights[i].constant = 20.0f;
        uboLightParams.pointLights[i].linear = 0.15f;
        uboLightParams.pointLights[i].quadratic = 0.32f;
    }
    VK_CHECK_RESULT(uniformBuffers.lightParams.map());
    uniformBuffers.lightParams.copyTo(&uboLightParams, sizeof(uboLightParams));
    uniformBuffers.lightParams.unmap();
}

void VulkanExample::UpdateUniformBufferMatrices()
{
    glm::mat4 projJittered = GetJitterMat() * camera.matrices.perspective; // camera.matrices.perspective;
    glm::mat4 projNonJittered = camera.matrices.perspective;

    uboSceneParams.projection = (use_method == 3) ? projJittered : projNonJittered;
    uboSceneParams.view = camera.matrices.view;
    uboSceneParams.model = glm::scale(m_model, glm::vec3(0.01f, 0.01f, 0.01f));
    VK_CHECK_RESULT(uniformBuffers.sceneParams.map());
    uniformBuffers.sceneParams.copyTo(&uboSceneParams, sizeof(uboSceneParams));
    uniformBuffers.sceneParams.unmap();

    uboCameraMVParams.vpMatInv = glm::inverse(projJittered * camera.matrices.view);
    uboCameraMVParams.prevVPMatNonJittered = (frameNum == 0) ? glm::mat4(1.0f) : uboCameraMVParams.vpMatNonJittered;
    uboCameraMVParams.vpMatNonJittered = projNonJittered * camera.matrices.view;
    VK_CHECK_RESULT(uniformBuffers.cameraMVParams.map());
    uniformBuffers.cameraMVParams.copyTo(&uboCameraMVParams, sizeof(uboCameraMVParams));
    uniformBuffers.cameraMVParams.unmap();
}

void VulkanExample::Draw()
{
    BuildCommandBuffers();
    
    if (cur_method != use_method || cur_vrs != use_vrs) {
        cur_method = use_method;
        cur_vrs = use_vrs;
    }

    submitInfo.waitSemaphoreCount = 1;
    VkSemaphore waitSemaphores[] = {presentCompleteSemaphores[currentBuffer]};
    submitInfo.pWaitSemaphores = waitSemaphores;
    submitInfo.signalSemaphoreCount = 1;
    VkSemaphore signalSemaphores[] = {renderCompleteSemaphores[currentBuffer]};
    submitInfo.pSignalSemaphores = signalSemaphores;
    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &drawCmdBuffers[currentBuffer];
    VkResult res = vkQueueSubmit(queue, 1, &submitInfo, waitFrameFences[activeIndex]);
    if (res != VK_SUCCESS) {
        LOGE("VulkanExample Fatal : VkResult is %s", vks::tools::errorString(res).c_str());
    }
    VulkanExampleBase::submitFrame();
}

void VulkanExample::InitFSR()
{
    VkRect2D inputRegion = vks::initializers::rect2D(screenWidth * useUpScale, screenHeight * useUpScale, 0, 0);
    VkRect2D outputRegion = vks::initializers::rect2D(highResWidth, highResHeight, 0, 0);
    VkExtent2D outputSize = {highResWidth, highResHeight};
    FSR::InitParams params;
    params.format = VK_FORMAT_R8G8B8A8_UNORM;
    params.device = device;
    params.physicalDevice = physicalDevice;

    params.inputRegion = inputRegion;
    params.inputView = upscaleFrameBuffers.light.color.view;
    params.outputView = upscaleFrameBuffers.upscale.color.view;
    params.outputSize = outputSize;
    params.outputRegion = outputRegion;
    params.sharpness = 0.4f;
    params.vulkanDevice = vulkanDevice;
    fsr = new FSR();
    fsr->Init(params);
}

void VulkanExample::InitSpatialUpscale()
{
    if (!isSupportSpatial) {
        LOGE("SpatialUpscale is not support.");
        return;
    }
    VkRect2D srcRect2D;
    srcRect2D.offset.x = 0;
    srcRect2D.offset.y = 0;
    srcRect2D.extent.width = lowResWidth;
    srcRect2D.extent.height = lowResHeight;

    VkRect2D dstRect2D;
    dstRect2D.offset.x = 0;
    dstRect2D.offset.y = 0;
    dstRect2D.extent.width = highResWidth;
    dstRect2D.extent.height = highResHeight;

    XEG_SpatialUpscaleCreateInfo createInfo;
    createInfo.format = VK_FORMAT_R8G8B8A8_UNORM;
    createInfo.sharpness = 0.2f;
    createInfo.outputSize = dstRect2D.extent;
    createInfo.inputRegion = srcRect2D;
    createInfo.inputSize = srcRect2D.extent;
    createInfo.outputRegion = dstRect2D;
    HMS_XEG_CreateSpatialUpscale(device, &createInfo, &xegSpatialUpscale);
}

void VulkanExample::InitXegTemporalUpscale()
{
    if (!isSupportTemporal) {
        LOGE("TemporalUpscale is not support");
        return;
    }
    VkRect2D srcRect2D;
    srcRect2D.offset.x = 0;
    srcRect2D.offset.y = 0;
    srcRect2D.extent.width = lowResWidth;
    srcRect2D.extent.height = lowResHeight;

    VkRect2D dstRect2D;
    dstRect2D.offset.x = 0;
    dstRect2D.offset.y = 0;
    dstRect2D.extent.width = highResWidth;
    dstRect2D.extent.height = highResHeight;

    XEG_TemporalUpscaleCreateInfo createInfo;
    createInfo.inputSize = srcRect2D.extent;
    createInfo.outputSize = dstRect2D.extent;
    createInfo.outputRegion = dstRect2D;
    createInfo.outputFormat = VK_FORMAT_R8G8B8A8_UNORM;
    createInfo.jitterNum = jitterNum;
    createInfo.isDepthReversed = false;
    VkResult res = HMS_XEG_CreateTemporalUpscale(device, &createInfo, &xegTemporalUpscale);
    if (res != VK_SUCCESS) {
        LOGE("Temporal upscale init fail: VkResult: %{public}d", res);
    }
}

void VulkanExample::InitXEGVRS()
{
    if (!isSupportVRS) {
        LOGE("VRS is not support");
        return;
    }
    VkExtent2D inputSize;
    VkRect2D inputRegion{};

    inputSize.width = highResWidth;
    inputSize.height = highResHeight;
    inputRegion.extent.width = highResWidth;
    inputRegion.extent.height = highResHeight;
    inputRegion.offset.x = 0;
    inputRegion.offset.y = 0;

    xeg_createInfo.inputSize = inputSize;
    xeg_createInfo.inputRegion = inputRegion;
    xeg_createInfo.adaptiveTileSize = VRS_TILE_SIZE;
    xeg_createInfo.errorSensitivity = SENSITIVITY;
    xeg_createInfo.flip = false;
    VkResult res = HMS_XEG_CreateAdaptiveVRS(device, &xeg_createInfo, &xeg_adaptiveVRS);
    if (res != VK_SUCCESS) {
        LOGE("VulkanExample xeg_adaptiveVRS create failed");
    }

    inputSize.width = lowResWidth;
    inputSize.height = lowResHeight;
    inputRegion.extent.width = lowResWidth;
    inputRegion.extent.height = lowResHeight;
    inputRegion.offset.x = 0;
    inputRegion.offset.y = 0;

    xeg_createInfo.inputSize = inputSize;
    xeg_createInfo.inputRegion = inputRegion;
    xeg_createInfo.adaptiveTileSize = VRS_TILE_SIZE;
    xeg_createInfo.errorSensitivity = SENSITIVITY;
    xeg_createInfo.flip = false;
    res = HMS_XEG_CreateAdaptiveVRS(device, &xeg_createInfo, &xeg_adaptiveVRS4Upscale);
    if (res != VK_SUCCESS) {
        LOGE("VulkanExample xeg_adaptiveVRS create failed");
    }
}

void VulkanExample::DispatchVRS(bool upscale, VkCommandBuffer commandBuffer)
{
    LOGI("dispatch vrs, is upscale %{public}d", upscale);
    XEG_AdaptiveVRSDescription xeg_description;
    xeg_description.inputColorImage = upscale ? upscaleFrameBuffers.light.color.view : frameBuffers.light.color.view;
    xeg_description.inputDepthImage =
        upscale ? upscaleFrameBuffers.gBufferLight.depth.view : frameBuffers.gBufferLight.depth.view;
    xeg_description.outputShadingRateImage =
        upscale ? upscaleFrameBuffers.shadingRate.color.view : frameBuffers.shadingRate.color.view;
    if (use_reprojectionMatrix) {
        if (camera.curVP.perspective == glm::mat4(0)) {
            xeg_description.reprojectionMatrix = (float *)glm::value_ptr(glm::mat4(0));
        } else {
            glm::mat4 currVP = camera.curVP.perspective * camera.curVP.view;
            glm::mat4 inv = glm::inverse(currVP);
            glm::mat4 preVP = camera.preVP.perspective * camera.preVP.view;
            glm::mat4 reproject = preVP * inv;
            xeg_description.reprojectionMatrix = (float *)glm::value_ptr(reproject);
        }
    } else {
        xeg_description.reprojectionMatrix = nullptr;
    }
// Synchronize the color image.
    VkImageSubresourceRange subresource_range{};
    subresource_range.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    subresource_range.baseMipLevel = 0;
    subresource_range.levelCount = 1;
    subresource_range.baseArrayLayer = 0;
    subresource_range.layerCount = 1;

    VkImageMemoryBarrier imageMemoryBarrier{};
    imageMemoryBarrier.sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    imageMemoryBarrier.image = upscale ? upscaleFrameBuffers.light.color.image : frameBuffers.light.color.image;
    imageMemoryBarrier.subresourceRange = subresource_range;
    imageMemoryBarrier.srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
    imageMemoryBarrier.dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
    imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;
    imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL;

    vkCmdPipelineBarrier(commandBuffer, VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, 0, 0, nullptr, 0, nullptr, 1, &imageMemoryBarrier);
    if (upscale && xeg_adaptiveVRS4Upscale) {
        HMS_XEG_CmdDispatchAdaptiveVRS(commandBuffer, xeg_adaptiveVRS4Upscale, &xeg_description);
    } else if (xeg_adaptiveVRS) {
        HMS_XEG_CmdDispatchAdaptiveVRS(commandBuffer, xeg_adaptiveVRS, &xeg_description);
    }
    // Synchronize ShadingRateImage.
    imageMemoryBarrier.image = upscale ? upscaleFrameBuffers.shadingRate.color.image
        : frameBuffers.shadingRate.color.image;
    imageMemoryBarrier.subresourceRange = subresource_range;
    imageMemoryBarrier.srcAccessMask = VK_ACCESS_SHADER_WRITE_BIT;
    imageMemoryBarrier.dstAccessMask = VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR;
    imageMemoryBarrier.oldLayout = VK_IMAGE_LAYOUT_GENERAL;
    imageMemoryBarrier.newLayout = VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;

    vkCmdPipelineBarrier(commandBuffer, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT,
        VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR, 0, 0, nullptr, 0, nullptr, 1, &imageMemoryBarrier);
}

std::array<VkVertexInputAttributeDescription, 3> VulkanExample::GetAttributeDescriptions()
{
    std::array<VkVertexInputAttributeDescription, 3> attributeDescriptions = {};
    attributeDescriptions[0].binding = 0;
    attributeDescriptions[0].location = 0;
    attributeDescriptions[0].format = VK_FORMAT_R32G32B32_SFLOAT;
    attributeDescriptions[0].offset = offsetof(vkOBJ::Vertex, Position);

    attributeDescriptions[1].binding = 0;
    attributeDescriptions[1].location = 1;
    attributeDescriptions[1].format = VK_FORMAT_R32G32_SFLOAT;
    attributeDescriptions[1].offset = offsetof(vkOBJ::Vertex, TexCoords);

    attributeDescriptions[2].binding = 0;
    attributeDescriptions[2].location = 2;
    attributeDescriptions[2].format = VK_FORMAT_R32G32B32_SFLOAT;
    attributeDescriptions[2].offset = offsetof(vkOBJ::Vertex, Normal);

    return attributeDescriptions;
}

bool VulkanExample::CheckXEngine()
{
    std::vector<std::string> supportedExtensions;
    uint32_t pPropertyCount;
    HMS_XEG_EnumerateDeviceExtensionProperties(physicalDevice, &pPropertyCount, nullptr);
    if (pPropertyCount > 0) {
        std::vector<XEG_ExtensionProperties> pProperties(pPropertyCount);
        if (HMS_XEG_EnumerateDeviceExtensionProperties(physicalDevice, &pPropertyCount,
            &pProperties.front()) == VK_SUCCESS) {
            for (auto ext : pProperties) {
                supportedExtensions.push_back(ext.extensionName);
            }
        }
    }
    
    if (std::find(supportedExtensions.begin(), supportedExtensions.end(), XEG_SPATIAL_UPSCALE_EXTENSION_NAME) ==
        supportedExtensions.end()) {
        LOGE("XEG_spatial_upscale not support");
        isSupportSpatial = false;
    }

    if (std::find(supportedExtensions.begin(), supportedExtensions.end(), XEG_ADAPTIVE_VRS_EXTENSION_NAME) ==
        supportedExtensions.end()) {
        LOGE("XEG_adaptive_vrs not support");
        isSupportVRS = false;
    }
    
    if (std::find(supportedExtensions.begin(), supportedExtensions.end(), XEG_TEMPORAL_UPSCALE_EXTENSION_NAME) ==
        supportedExtensions.end()) {
        LOGE("XEG_temporal_upscale not support");
        isSupportTemporal = false;
    }

    return true;
}

bool VulkanExample::Prepare()
{
    if (prepared) {
        return true;
    }
    VulkanExampleBase::prepare();
    if (!CheckXEngine()) {
        return false;
    }
    camera.setPerspective(60.0f, (float)screenWidth / (float)screenHeight, m_zNear, m_zFar);
    LoadAssets();
    PrepareOffscreenFrameBuffers();
    PrepareUniformBuffers();
    SetupDescriptorPool();
    SetupLayouts();
    SetupDescriptors();
    PreparePipelines();
    InitFSR();
    InitSpatialUpscale();
    InitXegTemporalUpscale();
    InitXEGVRS();
    prepared = true;
    return prepared;
}
