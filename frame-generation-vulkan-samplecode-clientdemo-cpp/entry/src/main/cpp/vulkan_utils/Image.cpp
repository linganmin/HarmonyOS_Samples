/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "log.hpp"
#include "Utils.h"
#include "Image.h"
#include "Device.h"
namespace VulkanFG {
bool Image::Init(const Image::ImageDescriptor &descriptor) noexcept
{
    VkDevice device = Device::Instance().GetNativeDevice();
    char const * name = descriptor.name.c_str();

    VkImageCreateInfo imageInfo{};
    imageInfo.sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    imageInfo.imageType = VK_IMAGE_TYPE_2D;
    imageInfo.extent.width = descriptor.width;
    imageInfo.extent.height = descriptor.height;
    imageInfo.extent.depth = 1;
    imageInfo.mipLevels = 1;
    imageInfo.arrayLayers = 1;
    imageInfo.format = descriptor.format;
    imageInfo.tiling = descriptor.tiling;
    imageInfo.initialLayout = descriptor.initialLayout;
    imageInfo.usage = descriptor.usage;
    imageInfo.samples = VK_SAMPLE_COUNT_1_BIT;
    imageInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

    if (vkCreateImage(device, &imageInfo, nullptr, &m_image) != VK_SUCCESS) {
        GOLOGE("Create vulkan image %s failed!", name);
        return false;
    }

    VulkanFG::SetLabel(device, m_image, VK_OBJECT_TYPE_IMAGE, name);

    VkMemoryRequirements memRequirements;
    vkGetImageMemoryRequirements(device, m_image, &memRequirements);
    VkMemoryAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocInfo.allocationSize = memRequirements.size;
    allocInfo.memoryTypeIndex =
        Device::Instance().FindMemoryType(memRequirements.memoryTypeBits, descriptor.properties);

    if (vkAllocateMemory(device, &allocInfo, nullptr, &m_imageMemory) != VK_SUCCESS) {
        GOLOGE("Create allocate vulkan image memory %s failed!", name);
        return false;
    }

    VK_CHECK(vkBindImageMemory(device, m_image, m_imageMemory, 0U));
    m_descriptor = descriptor;
    return true;
}

VkImage Image::GetNativeImage() noexcept
{
    return m_image;
}

VkImageView Image::GetNativeImageView() noexcept
{
    if (m_imageView != VK_NULL_HANDLE) {
        return m_imageView;
    }

    VkDevice device = Device::Instance().GetNativeDevice();
    char const * name = m_descriptor.name.c_str();

    VkImageViewCreateInfo viewInfo{};
    viewInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    viewInfo.image = m_image;
    viewInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
    viewInfo.format = m_descriptor.format;
    viewInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
    viewInfo.subresourceRange.baseMipLevel = 0;
    viewInfo.subresourceRange.levelCount = 1;
    viewInfo.subresourceRange.baseArrayLayer = 0;
    viewInfo.subresourceRange.layerCount = 1;

    if (vkCreateImageView(device, &viewInfo, nullptr, &m_imageView) != VK_SUCCESS) {
        GOLOGE("Create image view %s failed!", name);
    } else {
        VulkanFG::SetLabel(device, m_imageView, VK_OBJECT_TYPE_IMAGE_VIEW, name);
    }

    return m_imageView;
}

VkImageView Image::GetNativeImageView(VkFormat format, VkImageAspectFlags aspectFlags) noexcept
{
    if (m_imageView != VK_NULL_HANDLE) {
        return m_imageView;
    }

    VkDevice device = Device::Instance().GetNativeDevice();
    char const * name = m_descriptor.name.c_str();

    VkImageViewCreateInfo viewInfo{};
    viewInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    viewInfo.image = m_image;
    viewInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
    viewInfo.format = format;
    viewInfo.subresourceRange.aspectMask = aspectFlags;
    viewInfo.subresourceRange.baseMipLevel = 0;
    viewInfo.subresourceRange.levelCount = 1;
    viewInfo.subresourceRange.baseArrayLayer = 0;
    viewInfo.subresourceRange.layerCount = 1;

    if (vkCreateImageView(device, &viewInfo, nullptr, &m_imageView) != VK_SUCCESS) {
        GOLOGE("Create image view %s failed!", name);
    } else {
        VulkanFG::SetLabel(device, m_imageView, VK_OBJECT_TYPE_IMAGE_VIEW, name);
    }

    return m_imageView;
}

VkSampler Image::GetNativeSampler() noexcept
{
    if (m_sampler != VK_NULL_HANDLE) {
        return m_sampler;
    }

    VkDevice device = Device::Instance().GetNativeDevice();
    char const * name = m_descriptor.name.c_str();

    VkSamplerCreateInfo samplerInfo{};
    samplerInfo.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
    samplerInfo.magFilter = VK_FILTER_LINEAR;
    samplerInfo.minFilter = VK_FILTER_LINEAR;
    samplerInfo.addressModeU = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    samplerInfo.addressModeV = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    samplerInfo.addressModeW = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    samplerInfo.anisotropyEnable = VK_FALSE;

    VkPhysicalDeviceProperties properties{};
    vkGetPhysicalDeviceProperties(Device::Instance().GetNativePhysicalDevice(), &properties);
    samplerInfo.maxAnisotropy = properties.limits.maxSamplerAnisotropy;
    samplerInfo.borderColor = VK_BORDER_COLOR_INT_OPAQUE_BLACK;
    samplerInfo.unnormalizedCoordinates = VK_FALSE;
    samplerInfo.compareEnable = VK_FALSE;
    samplerInfo.compareOp = VK_COMPARE_OP_ALWAYS;

    samplerInfo.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR;
    samplerInfo.minLod = 0.0F; // Optional
    samplerInfo.maxLod = VK_LOD_CLAMP_NONE;
    samplerInfo.mipLodBias = 0.0F; // Optional

    if (vkCreateSampler(device, &samplerInfo, nullptr, &m_sampler) != VK_SUCCESS) {
        GOLOGE("Create image sampler %s failed!", name);
    } else {
        VulkanFG::SetLabel(device, m_sampler, VK_OBJECT_TYPE_SAMPLER, name);
    }

    return m_sampler;
}

void Image::Destroy() noexcept
{
    if (m_sampler != VK_NULL_HANDLE) {
        vkDestroySampler(Device::Instance().GetNativeDevice(), m_sampler, nullptr);
        m_sampler = VK_NULL_HANDLE;
    }

    if (m_imageView != VK_NULL_HANDLE) {
        vkDestroyImageView(Device::Instance().GetNativeDevice(), m_imageView, nullptr);
        m_imageView = VK_NULL_HANDLE;
    }

    if (m_image != VK_NULL_HANDLE) {
        vkDestroyImage(Device::Instance().GetNativeDevice(), m_image, nullptr);
        m_image = VK_NULL_HANDLE;
    }

    if (m_imageMemory != VK_NULL_HANDLE) {
        vkFreeMemory(Device::Instance().GetNativeDevice(), m_imageMemory, nullptr);
        m_imageMemory = VK_NULL_HANDLE;
    }
}

VkFormat Image::GetFormat() noexcept
{
    return m_descriptor.format;
}
} // namespace VulkanFG