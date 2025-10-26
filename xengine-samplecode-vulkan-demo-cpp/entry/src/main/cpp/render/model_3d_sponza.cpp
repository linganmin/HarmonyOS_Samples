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

#include "model_3d_sponza.h"
#include <dlfcn.h>

VulkanExample::~VulkanExample()
{
    LOGI("Start VulkanExample Destructor.");
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

    vkDestroyPipeline(device, pipelines.gBufferLight, nullptr);
    vkDestroyPipeline(device, pipelines.light, nullptr);
    vkDestroyPipeline(device, pipelines.swap, nullptr);

    vkDestroyPipeline(device, upscalePipelines.gBufferLight, nullptr);
    vkDestroyPipeline(device, upscalePipelines.light, nullptr);
    vkDestroyPipeline(device, upscalePipelines.swapUpscale, nullptr);

    vkDestroyPipelineLayout(device, pipelineLayouts.gBufferLight, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.light, nullptr);
    vkDestroyPipelineLayout(device, pipelineLayouts.swap, nullptr);

    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.gBufferLight, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.light, nullptr);
    vkDestroyDescriptorSetLayout(device, descriptorSetLayouts.swap, nullptr);

    if (xegSpatialUpscale) {
        HMS_XEG_DestroySpatialUpscale(xegSpatialUpscale);
    }

    if (xeg_adaptiveVRS) {
        HMS_XEG_DestroyAdaptiveVRS(xeg_adaptiveVRS);
    }

    if (xeg_adaptiveVRS4Upscale) {
        HMS_XEG_DestroyAdaptiveVRS(xeg_adaptiveVRS4Upscale);
    }

    m_scene.Destory();

    uniformBuffers.sceneParams.destroy();

    if (fsr != nullptr) {
        delete fsr;
    }
}

void VulkanExample::getEnabledFeatures()
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
    memAllloc.memoryTypeIndex =
        vulkanDevice->getMemoryType(memReqs.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
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

void VulkanExample::PrepareOffscreenFramebuffers()
{
    frameBuffers.gBufferLight.setSize(highResWidth, highResHeight);
    frameBuffers.light.setSize(highResWidth, highResHeight);
    frameBuffers.shadingRate.setSize(highResWidth, highResHeight);

    upscaleFrameBuffers.gBufferLight.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.light.setSize(lowResWidth, lowResHeight);
    upscaleFrameBuffers.upscale.setSize(highResWidth, highResHeight);
    upscaleFrameBuffers.shadingRate.setSize(lowResWidth, lowResHeight);

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

    PrepareShadingRateImage((uint32_t)lowResWidth / VRS_TILE_SIZE, (uint32_t)lowResHeight / VRS_TILE_SIZE,
                            &upscaleFrameBuffers.shadingRate.color);
    PrepareShadingRateImage((uint32_t)highResWidth / VRS_TILE_SIZE, (uint32_t)highResHeight / VRS_TILE_SIZE,
                            &frameBuffers.shadingRate.color);

    LOGI("VulkanExample Before UpScale Size: %{public}d, %{public}d", lowResWidth, lowResHeight);
    LOGI("VulkanExample After UpScale Size: %{public}d, %{public}d", highResWidth, highResHeight);

    // G-Buffer Render Pass
    {
        std::array<VkAttachmentDescription, 5> attachmentDescs = {};
        for (uint32_t i = 0; i < static_cast<uint32_t>(attachmentDescs.size()); i++) {
            attachmentDescs[i].samples = VK_SAMPLE_COUNT_1_BIT;
            attachmentDescs[i].loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
            attachmentDescs[i].storeOp = VK_ATTACHMENT_STORE_OP_STORE;
            attachmentDescs[i].stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
            attachmentDescs[i].stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
            attachmentDescs[i].finalLayout =
                (i == 3) ? VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL : VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;
        }

        attachmentDescs[0].format = frameBuffers.gBufferLight.position.format;
        attachmentDescs[1].format = frameBuffers.gBufferLight.normal.format;
        attachmentDescs[2].format = frameBuffers.gBufferLight.albedo.format;
        attachmentDescs[3].format = frameBuffers.gBufferLight.depth.format;
        attachmentDescs[4].format = frameBuffers.gBufferLight.viewNormal.format;

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

        std::array<VkSubpassDependency, 2> dependencies;

        dependencies[0].srcSubpass = VK_SUBPASS_EXTERNAL;
        dependencies[0].dstSubpass = 0;
        dependencies[0].srcStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
        dependencies[0].dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependencies[0].srcAccessMask = VK_ACCESS_SHADER_READ_BIT;
        dependencies[0].dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        dependencies[0].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

        dependencies[1].srcSubpass = 0;
        dependencies[1].dstSubpass = VK_SUBPASS_EXTERNAL;
        dependencies[1].srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependencies[1].dstStageMask = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT;
        dependencies[1].srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;
        dependencies[1].dstAccessMask = VK_ACCESS_SHADER_READ_BIT;
        dependencies[1].dependencyFlags = VK_DEPENDENCY_BY_REGION_BIT;

        VkRenderPassCreateInfo renderPassInfo = {};
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        renderPassInfo.pAttachments = attachmentDescs.data();
        renderPassInfo.attachmentCount = static_cast<uint32_t>(attachmentDescs.size());
        renderPassInfo.subpassCount = 1;
        renderPassInfo.pSubpasses = &subpass;
        renderPassInfo.dependencyCount = 2;
        renderPassInfo.pDependencies = dependencies.data();
        VK_CHECK_RESULT(vkCreateRenderPass(device, &renderPassInfo, nullptr, &frameBuffers.gBufferLight.renderPass));

        std::array<VkImageView, 5> attachments;
        attachments[0] = frameBuffers.gBufferLight.position.view;
        attachments[1] = frameBuffers.gBufferLight.normal.view;
        attachments[2] = frameBuffers.gBufferLight.albedo.view;
        attachments[3] = frameBuffers.gBufferLight.depth.view;
        attachments[4] = frameBuffers.gBufferLight.viewNormal.view;

        VkFramebufferCreateInfo fbufCreateInfo = vks::initializers::framebufferCreateInfo();
        fbufCreateInfo.renderPass = frameBuffers.gBufferLight.renderPass;
        fbufCreateInfo.pAttachments = attachments.data();
        fbufCreateInfo.attachmentCount = static_cast<uint32_t>(attachments.size());
        fbufCreateInfo.width = frameBuffers.gBufferLight.width;
        fbufCreateInfo.height = frameBuffers.gBufferLight.height;
        fbufCreateInfo.layers = 1;
        VK_CHECK_RESULT(vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &frameBuffers.gBufferLight.frameBuffer));

        attachmentDescs[0].format = upscaleFrameBuffers.gBufferLight.position.format;
        attachmentDescs[1].format = upscaleFrameBuffers.gBufferLight.normal.format;
        attachmentDescs[2].format = upscaleFrameBuffers.gBufferLight.albedo.format;
        attachmentDescs[3].format = upscaleFrameBuffers.gBufferLight.depth.format;
        attachmentDescs[4].format = upscaleFrameBuffers.gBufferLight.viewNormal.format;

        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        renderPassInfo.pAttachments = attachmentDescs.data();
        renderPassInfo.attachmentCount = static_cast<uint32_t>(attachmentDescs.size());
        renderPassInfo.subpassCount = 1;
        renderPassInfo.pSubpasses = &subpass;
        renderPassInfo.dependencyCount = 2;
        renderPassInfo.pDependencies = dependencies.data();
        VK_CHECK_RESULT(
            vkCreateRenderPass(device, &renderPassInfo, nullptr, &upscaleFrameBuffers.gBufferLight.renderPass));

        attachments[0] = upscaleFrameBuffers.gBufferLight.position.view;
        attachments[1] = upscaleFrameBuffers.gBufferLight.normal.view;
        attachments[2] = upscaleFrameBuffers.gBufferLight.albedo.view;
        attachments[3] = upscaleFrameBuffers.gBufferLight.depth.view;
        attachments[4] = upscaleFrameBuffers.gBufferLight.viewNormal.view;

        fbufCreateInfo.renderPass = upscaleFrameBuffers.gBufferLight.renderPass;
        fbufCreateInfo.pAttachments = attachments.data();
        fbufCreateInfo.attachmentCount = static_cast<uint32_t>(attachments.size());
        fbufCreateInfo.width = upscaleFrameBuffers.gBufferLight.width;
        fbufCreateInfo.height = upscaleFrameBuffers.gBufferLight.height;
        fbufCreateInfo.layers = 1;
        VK_CHECK_RESULT(
            vkCreateFramebuffer(device, &fbufCreateInfo, nullptr, &upscaleFrameBuffers.gBufferLight.frameBuffer));
    }

    // Light Render Pass And FrameBuffer, Support VRS
    {
        // need 2 attachment, light and shading rate image
        std::array<VkAttachmentDescription2KHR, 2> attachments = {};
        attachments[0].sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
        attachments[0].format = frameBuffers.light.color.format;
        attachments[0].samples = VK_SAMPLE_COUNT_1_BIT;
        attachments[0].loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        attachments[0].storeOp = VK_ATTACHMENT_STORE_OP_STORE;
        attachments[0].stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
        attachments[0].stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[0].initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        attachments[0].finalLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

        attachments[1].sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
        attachments[1].format = VK_FORMAT_R8_UINT;
        attachments[1].samples = VK_SAMPLE_COUNT_1_BIT;
        attachments[1].loadOp = VK_ATTACHMENT_LOAD_OP_LOAD;
        attachments[1].storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[1].stencilLoadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        attachments[1].stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[1].initialLayout = VK_IMAGE_LAYOUT_GENERAL;
        attachments[1].finalLayout = VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;

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

        VkRenderPassCreateInfo2KHR renderPassCI = {};
        renderPassCI.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2;
        renderPassCI.attachmentCount = static_cast<uint32_t>(attachments.size());
        renderPassCI.pAttachments = attachments.data();
        renderPassCI.subpassCount = 1;
        renderPassCI.pSubpasses = &subpassDescription;
        renderPassCI.dependencyCount = static_cast<uint32_t>(dependencies.size());
        renderPassCI.pDependencies = dependencies.data();
        if (vkCreateRenderPass2KHR == nullptr) {
            LOGE("VulkanExample vkCreateRenderPass2KHR get failed");
        }

        vkCreateRenderPass2KHR(device, &renderPassCI, nullptr, &frameBuffers.shadingRate.renderPass);

        VkImageView attachmentsView[2];
        attachmentsView[0] = frameBuffers.light.color.view;
        attachmentsView[1] = frameBuffers.shadingRate.color.view;

        VkFramebufferCreateInfo frameBufferCreateInfo{};
        frameBufferCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        frameBufferCreateInfo.renderPass = frameBuffers.shadingRate.renderPass;
        frameBufferCreateInfo.attachmentCount = 2;
        frameBufferCreateInfo.pAttachments = attachmentsView;
        frameBufferCreateInfo.width = frameBuffers.light.width;
        frameBufferCreateInfo.height = frameBuffers.light.height;
        frameBufferCreateInfo.layers = 1;
        VK_CHECK_RESULT(
            vkCreateFramebuffer(device, &frameBufferCreateInfo, nullptr, &frameBuffers.shadingRate.frameBuffer));
    }

    {
        std::array<VkAttachmentDescription2KHR, 2> attachments = {};
        attachments[0].sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
        attachments[0].format = upscaleFrameBuffers.light.color.format;
        attachments[0].samples = VK_SAMPLE_COUNT_1_BIT;
        attachments[0].loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        attachments[0].storeOp = VK_ATTACHMENT_STORE_OP_STORE;
        attachments[0].stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
        attachments[0].stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[0].initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        attachments[0].finalLayout = VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL;

        attachments[1].sType = VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2;
        attachments[1].format = VK_FORMAT_R8_UINT;
        attachments[1].samples = VK_SAMPLE_COUNT_1_BIT;
        attachments[1].loadOp = VK_ATTACHMENT_LOAD_OP_LOAD;
        attachments[1].storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[1].stencilLoadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        attachments[1].stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        attachments[1].initialLayout = VK_IMAGE_LAYOUT_GENERAL;
        attachments[1].finalLayout = VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR;

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

        VkRenderPassCreateInfo2KHR renderPassCI = {};
        renderPassCI.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2;
        renderPassCI.attachmentCount = static_cast<uint32_t>(attachments.size());
        renderPassCI.pAttachments = attachments.data();
        renderPassCI.subpassCount = 1;
        renderPassCI.pSubpasses = &subpassDescription;
        renderPassCI.dependencyCount = static_cast<uint32_t>(dependencies.size());
        renderPassCI.pDependencies = dependencies.data();
        VK_CHECK_RESULT(
            vkCreateRenderPass2KHR(device, &renderPassCI, nullptr, &upscaleFrameBuffers.shadingRate.renderPass));

        VkImageView attachmentsView[2];
        attachmentsView[0] = upscaleFrameBuffers.light.color.view;
        attachmentsView[1] = upscaleFrameBuffers.shadingRate.color.view;

        VkFramebufferCreateInfo frameBufferCreateInfo{};
        frameBufferCreateInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        frameBufferCreateInfo.renderPass = upscaleFrameBuffers.shadingRate.renderPass;
        frameBufferCreateInfo.attachmentCount = 2;
        frameBufferCreateInfo.pAttachments = attachmentsView;
        frameBufferCreateInfo.width = upscaleFrameBuffers.light.width;
        frameBufferCreateInfo.height = upscaleFrameBuffers.light.height;
        frameBufferCreateInfo.layers = 1;
        VK_CHECK_RESULT(
            vkCreateFramebuffer(device, &frameBufferCreateInfo, nullptr, &upscaleFrameBuffers.shadingRate.frameBuffer));
    }

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


void VulkanExample::buildCommandBuffers()
{
    if (use_method != 0) {
        BuildUpscaleCommandBuffers();
        return;
    }

    VkCommandBufferBeginInfo cmdBufInfo = vks::initializers::commandBufferBeginInfo();
    VkRenderPassBeginInfo renderPassBeginInfo = vks::initializers::renderPassBeginInfo();
    VkViewport viewport;
    VkRect2D scissor;
    VkExtent2D fragmentSize = {1, 1};
    VkFragmentShadingRateCombinerOpKHR combinerOps[2];

    for (int32_t i = 0; i < drawCmdBuffers.size(); ++i) {
        LOGI("VulkanExample Do not use Upscale.");
        VK_CHECK_RESULT(vkBeginCommandBuffer(drawCmdBuffers[i], &cmdBufInfo));

        // First Pass: GBuffer
        std::vector<VkClearValue> clearValues(5);
        clearValues[0].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[1].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[2].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[3].depthStencil = {1.0f, 0};
        clearValues[4].color = {{0.0f, 0.0f, 0.0f, 1.0f}};

        renderPassBeginInfo.renderPass = frameBuffers.gBufferLight.renderPass;
        renderPassBeginInfo.framebuffer = frameBuffers.gBufferLight.frameBuffer;
        renderPassBeginInfo.renderArea.extent.width = frameBuffers.gBufferLight.width;
        renderPassBeginInfo.renderArea.extent.height = frameBuffers.gBufferLight.height;
        renderPassBeginInfo.clearValueCount = static_cast<uint32_t>(clearValues.size());
        renderPassBeginInfo.pClearValues = clearValues.data();

        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

        viewport = vks::initializers::viewport((float)frameBuffers.gBufferLight.width,
                                               (float)frameBuffers.gBufferLight.height, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(frameBuffers.gBufferLight.width, frameBuffers.gBufferLight.height, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelines.gBufferLight);
        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.gBufferLight, 0, 1,
                                &descriptorSets.gBufferLight, 0, NULL);
        m_scene.Draw(drawCmdBuffers[i], 0x00000001, pipelineLayouts.gBufferLight, 1);

        vkCmdEndRenderPass(drawCmdBuffers[i]);

        // When use vrs, Dispatch vrs to compute sri
        if (use_vrs) {
            DispatchVRS(false, drawCmdBuffers[i]);
        } else {
            LOGI("VulkanExample do not use vrs.");
        }

        // Second Pass: Light Pass, Support VRS
        clearValues[0].color = defaultClearColor;
        clearValues[1].depthStencil = {1.0f, 0};

        renderPassBeginInfo.renderPass = frameBuffers.shadingRate.renderPass;
        renderPassBeginInfo.framebuffer = frameBuffers.shadingRate.frameBuffer;
        renderPassBeginInfo.renderArea.extent.width = frameBuffers.shadingRate.width;
        renderPassBeginInfo.renderArea.extent.height = frameBuffers.shadingRate.height;
        renderPassBeginInfo.clearValueCount = static_cast<uint32_t>(clearValues.size());
        renderPassBeginInfo.pClearValues = clearValues.data();

        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

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
        vkCmdSetFragmentShadingRateKHR(drawCmdBuffers[i], &fragmentSize, combinerOps);

        viewport =
            vks::initializers::viewport((float)frameBuffers.light.width, (float)frameBuffers.light.height, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(frameBuffers.light.width, frameBuffers.light.height, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);
        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.light, 0, 1,
                                &descriptorSets.light, 0, nullptr);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelines.light);
        vkCmdDraw(drawCmdBuffers[i], 3, 1, 0, 0);
        vkCmdEndRenderPass(drawCmdBuffers[i]);

        // Final Pass: To Full Screen
        clearValues[0].color = defaultClearColor;
        clearValues[1].depthStencil = {1.0f, 0};
        VkRenderPassBeginInfo renderPassBeginInfo = vks::initializers::renderPassBeginInfo();
        VkViewport viewport;
        VkRect2D scissor;
        renderPassBeginInfo.renderPass = renderPass;
        renderPassBeginInfo.framebuffer = VulkanExampleBase::frameBuffers[i];
        renderPassBeginInfo.renderArea.extent.width = screenWidth;
        renderPassBeginInfo.renderArea.extent.height = screenHeight;
        renderPassBeginInfo.clearValueCount = 2;
        renderPassBeginInfo.pClearValues = clearValues.data();

        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

        viewport = vks::initializers::viewport((float)screenWidth, (float)screenHeight, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(screenWidth, screenHeight, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);

        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.swap, 0, 1,
                                &descriptorSets.swap, 0, NULL);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelines.swap);
        vkCmdDraw(drawCmdBuffers[i], 3, 1, 0, 0);
        vkCmdEndRenderPass(drawCmdBuffers[i]);

        VK_CHECK_RESULT(vkEndCommandBuffer(drawCmdBuffers[i]));
    }
}

void VulkanExample::BuildUpscaleCommandBuffers()
{
    VkCommandBufferBeginInfo cmdBufInfo = vks::initializers::commandBufferBeginInfo();
    VkRenderPassBeginInfo renderPassBeginInfo = vks::initializers::renderPassBeginInfo();
    VkViewport viewport;
    VkRect2D scissor;
    VkExtent2D fragmentSize = {1, 1};
    VkFragmentShadingRateCombinerOpKHR combinerOps[2];
    for (int32_t i = 0; i < drawCmdBuffers.size(); ++i) {
        VK_CHECK_RESULT(vkBeginCommandBuffer(drawCmdBuffers[i], &cmdBufInfo));

        // First Pass: GBuffer
        std::vector<VkClearValue> clearValues(5);
        clearValues[0].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[1].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[2].color = {{0.0f, 0.0f, 0.0f, 1.0f}};
        clearValues[3].depthStencil = {1.0f, 0};
        clearValues[4].color = {{0.0f, 0.0f, 0.0f, 1.0f}};

        renderPassBeginInfo.renderPass = upscaleFrameBuffers.gBufferLight.renderPass;
        renderPassBeginInfo.framebuffer = upscaleFrameBuffers.gBufferLight.frameBuffer;
        renderPassBeginInfo.renderArea.extent.width = upscaleFrameBuffers.gBufferLight.width;
        renderPassBeginInfo.renderArea.extent.height = upscaleFrameBuffers.gBufferLight.height;
        renderPassBeginInfo.clearValueCount = static_cast<uint32_t>(clearValues.size());
        renderPassBeginInfo.pClearValues = clearValues.data();

        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);

        viewport = vks::initializers::viewport((float)upscaleFrameBuffers.gBufferLight.width,
                                               (float)upscaleFrameBuffers.gBufferLight.height, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(upscaleFrameBuffers.gBufferLight.width,
                                            upscaleFrameBuffers.gBufferLight.height, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, upscalePipelines.gBufferLight);
        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.gBufferLight, 0, 1,
                                &descriptorSets.gBufferLight, 0, NULL);
        m_scene.Draw(drawCmdBuffers[i], 0x00000001, pipelineLayouts.gBufferLight, 1);

        vkCmdEndRenderPass(drawCmdBuffers[i]);

        // when use vrs, dispatchvrs to compute sri
        if (use_vrs) {
            DispatchVRS(true, drawCmdBuffers[i]);
        } else {
            LOGI("VulkanExample not use vrs");
        }
        
        // Second Pass: Light Pass, Support VRS
        clearValues[0].color = defaultClearColor;
        clearValues[1].depthStencil = {1.0f, 0};

        renderPassBeginInfo.renderPass = upscaleFrameBuffers.shadingRate.renderPass;
        renderPassBeginInfo.framebuffer = upscaleFrameBuffers.shadingRate.frameBuffer;
        renderPassBeginInfo.renderArea.extent.width = upscaleFrameBuffers.shadingRate.width;
        renderPassBeginInfo.renderArea.extent.height = upscaleFrameBuffers.shadingRate.height;
        renderPassBeginInfo.clearValueCount = static_cast<uint32_t>(clearValues.size());
        renderPassBeginInfo.pClearValues = clearValues.data();

        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);
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

        vkCmdSetFragmentShadingRateKHR(drawCmdBuffers[i], &fragmentSize, combinerOps);
        viewport = vks::initializers::viewport((float)upscaleFrameBuffers.light.width,
                                               (float)upscaleFrameBuffers.light.height, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(upscaleFrameBuffers.light.width, upscaleFrameBuffers.light.height, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);

        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.light, 0, 1,
                                &upscaleDescriptorSets.light, 0, nullptr);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, upscalePipelines.light);
        vkCmdDraw(drawCmdBuffers[i], 3, 1, 0, 0);
        vkCmdEndRenderPass(drawCmdBuffers[i]);

        if (use_method == 1) {
            LOGI("VulkanExample example use spatial upscale.");
            XEG_SpatialUpscaleDescription xegDescription{0};
            xegDescription.inputImage = upscaleFrameBuffers.light.color.view;
            xegDescription.outputImage = upscaleFrameBuffers.upscale.color.view;
            HMS_XEG_CmdRenderSpatialUpscale(drawCmdBuffers[i], xegSpatialUpscale, &xegDescription);
        } else {
            LOGI("VulkanExample example use fsr upscale.");
            fsr->Render(drawCmdBuffers[i]);
        }

        clearValues[0].color = defaultClearColor;
        clearValues[1].depthStencil = {1.0f, 0};
        renderPassBeginInfo.renderPass = renderPass;
        renderPassBeginInfo.framebuffer = VulkanExampleBase::frameBuffers[i];
        renderPassBeginInfo.renderArea.extent.width = screenWidth;
        renderPassBeginInfo.renderArea.extent.height = screenHeight;
        renderPassBeginInfo.clearValueCount = 2;
        renderPassBeginInfo.pClearValues = clearValues.data();
        vkCmdBeginRenderPass(drawCmdBuffers[i], &renderPassBeginInfo, VK_SUBPASS_CONTENTS_INLINE);
        viewport = vks::initializers::viewport((float)screenWidth, (float)screenHeight, 0.0f, 1.0f);
        vkCmdSetViewport(drawCmdBuffers[i], 0, 1, &viewport);
        scissor = vks::initializers::rect2D(screenWidth, screenHeight, 0, 0);
        vkCmdSetScissor(drawCmdBuffers[i], 0, 1, &scissor);

        vkCmdBindDescriptorSets(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, pipelineLayouts.swap, 0, 1,
                                &upscaleDescriptorSets.swapUpscale, 0, NULL);
        vkCmdBindPipeline(drawCmdBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, upscalePipelines.swapUpscale);
        vkCmdDraw(drawCmdBuffers[i], 3, 1, 0, 0);
        vkCmdEndRenderPass(drawCmdBuffers[i]);
        VK_CHECK_RESULT(vkEndCommandBuffer(drawCmdBuffers[i]));
    }
}

void VulkanExample::SetupDescriptorPool()
{
    std::vector<VkDescriptorPoolSize> poolSizes = {
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 60),
        vks::initializers::descriptorPoolSize(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 60)};
    VkDescriptorPoolCreateInfo descriptorPoolInfo = vks::initializers::descriptorPoolCreateInfo(poolSizes, 120);
    VK_CHECK_RESULT(vkCreateDescriptorPool(device, &descriptorPoolInfo, nullptr, &descriptorPool));
}

void VulkanExample::SetupLayouts()
{
    std::vector<VkDescriptorSetLayoutBinding> setLayoutBindings;
    VkDescriptorSetLayoutCreateInfo setLayoutCreateInfo;
    VkPipelineLayoutCreateInfo pipelineLayoutCreateInfo = vks::initializers::pipelineLayoutCreateInfo();

    // Light G-Buffer creation
    {
        setLayoutBindings = {
            vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
                                                          VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT,
                                                          0),
        };
        setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(
            setLayoutBindings.data(), static_cast<uint32_t>(setLayoutBindings.size()));
        VK_CHECK_RESULT(
            vkCreateDescriptorSetLayout(device, &setLayoutCreateInfo, nullptr, &descriptorSetLayouts.gBufferLight));

        const std::vector<VkDescriptorSetLayout> setLayouts = {descriptorSetLayouts.gBufferLight,
                                                               m_scene.m_descriptorSetLayoutImage};
        pipelineLayoutCreateInfo.pSetLayouts = setLayouts.data();
        pipelineLayoutCreateInfo.setLayoutCount = 2;
        VK_CHECK_RESULT(
            vkCreatePipelineLayout(device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayouts.gBufferLight));
    }

    // Light creation
    {
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
        setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(
            setLayoutBindings.data(), static_cast<uint32_t>(setLayoutBindings.size()));
        VK_CHECK_RESULT(
            vkCreateDescriptorSetLayout(device, &setLayoutCreateInfo, nullptr, &descriptorSetLayouts.light));

        pipelineLayoutCreateInfo.pSetLayouts = &descriptorSetLayouts.light;
        pipelineLayoutCreateInfo.setLayoutCount = 1;
        VK_CHECK_RESULT(vkCreatePipelineLayout(device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayouts.light));
    }

    pipelineLayoutCreateInfo.setLayoutCount = 1;
    {
        setLayoutBindings = {
            vks::initializers::descriptorSetLayoutBinding(VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
                                                          VK_SHADER_STAGE_FRAGMENT_BIT, 0),
        };
        setLayoutCreateInfo = vks::initializers::descriptorSetLayoutCreateInfo(
            setLayoutBindings.data(), static_cast<uint32_t>(setLayoutBindings.size()));
        VK_CHECK_RESULT(vkCreateDescriptorSetLayout(device, &setLayoutCreateInfo, nullptr, &descriptorSetLayouts.swap));
        pipelineLayoutCreateInfo.pSetLayouts = &descriptorSetLayouts.swap;
        VK_CHECK_RESULT(vkCreatePipelineLayout(device, &pipelineLayoutCreateInfo, nullptr, &pipelineLayouts.swap));
    }
}

void VulkanExample::SetupDescriptors()
{
    VkDescriptorSetAllocateInfo descriptorAllocInfo =
        vks::initializers::descriptorSetAllocateInfo(descriptorPool, nullptr, 1);
    std::vector<VkWriteDescriptorSet> writeDescriptorSets;
    std::vector<VkDescriptorImageInfo> imageDescriptors;

    // G-Buffer descriptor
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.gBufferLight;
        if (descriptorSets.gBufferLight == VK_NULL_HANDLE) {
            VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &descriptorSets.gBufferLight));
        }
        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(descriptorSets.gBufferLight, VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 0,
                                                  &uniformBuffers.sceneParams.descriptor),
        };
        vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
                               NULL);
    }

    // Light descriptor
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.light;
        if (descriptorSets.light == VK_NULL_HANDLE) {
            VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &descriptorSets.light));
        }

        imageDescriptors = {
            vks::initializers::descriptorImageInfo(colorSampler, frameBuffers.gBufferLight.position.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
            vks::initializers::descriptorImageInfo(colorSampler, frameBuffers.gBufferLight.normal.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
            vks::initializers::descriptorImageInfo(colorSampler, frameBuffers.gBufferLight.albedo.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };
        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(descriptorSets.light, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 0,
                                                  &imageDescriptors[0]),
            vks::initializers::writeDescriptorSet(descriptorSets.light, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1,
                                                  &imageDescriptors[1]),
            vks::initializers::writeDescriptorSet(descriptorSets.light, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 2,
                                                  &imageDescriptors[2]),
            vks::initializers::writeDescriptorSet(descriptorSets.light, VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 3,
                                                  &uniformBuffers.lightParams.descriptor),
        };
        vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
                               NULL);

        if (upscaleDescriptorSets.light == VK_NULL_HANDLE) {
            VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &upscaleDescriptorSets.light));
        }

        imageDescriptors = {
            vks::initializers::descriptorImageInfo(colorSampler, upscaleFrameBuffers.gBufferLight.position.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
            vks::initializers::descriptorImageInfo(colorSampler, upscaleFrameBuffers.gBufferLight.normal.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
            vks::initializers::descriptorImageInfo(colorSampler, upscaleFrameBuffers.gBufferLight.albedo.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };
        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(upscaleDescriptorSets.light,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 0, &imageDescriptors[0]),
            vks::initializers::writeDescriptorSet(upscaleDescriptorSets.light,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1, &imageDescriptors[1]),
            vks::initializers::writeDescriptorSet(upscaleDescriptorSets.light,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 2, &imageDescriptors[2]),
            vks::initializers::writeDescriptorSet(upscaleDescriptorSets.light, VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER, 3,
                                                  &uniformBuffers.lightParams.descriptor),
        };
        vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
                               NULL);
    }

    // FINAL
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.swap;
        if (descriptorSets.swap == VK_NULL_HANDLE) {
            VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &descriptorSets.swap));
        }

        imageDescriptors = {
            vks::initializers::descriptorImageInfo(colorSampler, frameBuffers.light.color.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };

        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(descriptorSets.swap, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 0,
                                                  &imageDescriptors[0]),
        };
        vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
                               NULL);
    }
    
    {
        descriptorAllocInfo.pSetLayouts = &descriptorSetLayouts.swap;
        if (upscaleDescriptorSets.swapUpscale == VK_NULL_HANDLE) {
            VK_CHECK_RESULT(vkAllocateDescriptorSets(device, &descriptorAllocInfo, &upscaleDescriptorSets.swapUpscale));
        }
        imageDescriptors = {
            vks::initializers::descriptorImageInfo(colorSampler, upscaleFrameBuffers.upscale.color.view,
                                                   VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL),
        };

        writeDescriptorSets = {
            vks::initializers::writeDescriptorSet(upscaleDescriptorSets.swapUpscale,
                                                  VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 0, &imageDescriptors[0]),
        };
        vkUpdateDescriptorSets(device, static_cast<uint32_t>(writeDescriptorSets.size()), writeDescriptorSets.data(), 0,
                               NULL);
    }
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
    VkPipelineVertexInputStateCreateInfo emptyVertexInputState =
        vks::initializers::pipelineVertexInputStateCreateInfo();
    pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
    rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;
    std::string vsShader;
    std::string fsShader;
    // Final TO window pipeline
    {
        vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/fullscreen.vert.spv");
        fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/swapChain.frag.spv");
        shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
        shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
        VK_CHECK_RESULT(
            vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.swap));
        VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
                                                  &upscalePipelines.swapUpscale));
    }

    // light pipeline
    {
        VkPipelineFragmentShadingRateStateCreateInfoKHR shadingRateInfo = {
            VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR};
        shadingRateInfo.fragmentSize = {1, 1};
        shadingRateInfo.combinerOps[0] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR;
        shadingRateInfo.combinerOps[1] = VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR;
        pipelineCreateInfo.pNext = &shadingRateInfo;
        pipelineCreateInfo.pVertexInputState = &emptyVertexInputState;
        pipelineCreateInfo.renderPass =
            frameBuffers.shadingRate.renderPass;
        pipelineCreateInfo.layout = pipelineLayouts.light;
        rasterizationState.cullMode = VK_CULL_MODE_FRONT_BIT;

        blendAttachmentState = vks::initializers::pipelineColorBlendAttachmentState(0xf, VK_FALSE);
        colorBlendState.attachmentCount = 1;
        colorBlendState.pAttachments = &blendAttachmentState;

        vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/fullscreen.vert.spv");
        fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/light.frag.spv");

        shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
        shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
        VK_CHECK_RESULT(
            vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.light));
        
        pipelineCreateInfo.renderPass = upscaleFrameBuffers.shadingRate.renderPass;
        VK_CHECK_RESULT(
            vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &upscalePipelines.light));
        pipelineCreateInfo.pNext = nullptr;
    }

    // Fill G-Buffer pipeline
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

        vsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/gbuffer.vert.spv");
        fsShader = FileOperator::GetInstance()->GetFileAbsolutePath("shader/gbuffer.frag.spv");

        shaderStages[0] = loadShader(vsShader, VK_SHADER_STAGE_VERTEX_BIT, false);
        shaderStages[1] = loadShader(fsShader, VK_SHADER_STAGE_FRAGMENT_BIT, false);
        VK_CHECK_RESULT(
            vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr, &pipelines.gBufferLight));

        pipelineCreateInfo.renderPass = upscaleFrameBuffers.gBufferLight.renderPass;
        VK_CHECK_RESULT(vkCreateGraphicsPipelines(device, pipelineCache, 1, &pipelineCreateInfo, nullptr,
                                                  &upscalePipelines.gBufferLight));
    }
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
    uboSceneParams.projection = camera.matrices.perspective;
    uboSceneParams.view = camera.matrices.view;
    uboSceneParams.model = glm::scale(m_model, glm::vec3(0.01f, 0.01f, 0.01f));
    VK_CHECK_RESULT(uniformBuffers.sceneParams.map());
    uniformBuffers.sceneParams.copyTo(&uboSceneParams, sizeof(uboSceneParams));
    uniformBuffers.sceneParams.unmap();
}

void VulkanExample::Draw()
{
    VulkanExampleBase::prepareFrame();
    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &drawCmdBuffers[currentBuffer];
    VkResult res = vkQueueSubmit(queue, 1, &submitInfo, VK_NULL_HANDLE);
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

void VulkanExample::InitXEGVRS()
{
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

    if (upscale) {
        HMS_XEG_CmdDispatchAdaptiveVRS(commandBuffer, xeg_adaptiveVRS4Upscale, &xeg_description);
    } else {
        HMS_XEG_CmdDispatchAdaptiveVRS(commandBuffer, xeg_adaptiveVRS, &xeg_description);
    }
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
        return false;
    }

    if (std::find(supportedExtensions.begin(), supportedExtensions.end(), XEG_ADAPTIVE_VRS_EXTENSION_NAME) ==
        supportedExtensions.end()) {
        LOGE("XEG_adaptive_vrs not support");
        return false;
    }
    return true;
}

bool VulkanExample::prepare()
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
    PrepareOffscreenFramebuffers();
    PrepareUniformBuffers();
    SetupDescriptorPool();
    SetupLayouts();
    SetupDescriptors();
    PreparePipelines();
    InitFSR();
    InitSpatialUpscale();
    InitXEGVRS();
    buildCommandBuffers();
    prepared = true;
    return prepared;
}
