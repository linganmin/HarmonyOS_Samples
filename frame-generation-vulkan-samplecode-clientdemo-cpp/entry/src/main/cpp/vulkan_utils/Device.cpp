/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "Device.h"
#include "log.hpp"
namespace VulkanFG {
void Device::Init(const DeviceDescriptor &descriptor)
{
    m_instance = descriptor.instance;
    m_physicalDevice = descriptor.physicalDevice;
    m_device = descriptor.device;
    m_queueFamilyIndex = descriptor.queueFamilyIndex;
    m_queue = descriptor.queue;

    vkGetPhysicalDeviceProperties(Device::Instance().GetNativePhysicalDevice(), &m_physicalDevicePorperties);
}

VkDevice Device::GetNativeDevice()
{
    return m_device;
}

VkFormat Device::FindSupportedFormat(const std::vector<VkFormat> &candidates, VkImageTiling tiling,
    VkFormatFeatureFlags features)
{
    for (VkFormat format : candidates) {
        VkFormatProperties props;
        vkGetPhysicalDeviceFormatProperties(m_physicalDevice, format, &props);

        if (tiling == VK_IMAGE_TILING_LINEAR && (props.linearTilingFeatures & features) == features) {
            return format;
        } else if (tiling == VK_IMAGE_TILING_OPTIMAL && (props.optimalTilingFeatures & features) == features) {
            return format;
        }
    }

    GOLOGE("Failed to find supported format!");
    return VK_FORMAT_MAX_ENUM;
}

VkFormat Device::FindDepthFormat()
{
    return FindSupportedFormat({ VK_FORMAT_D24_UNORM_S8_UINT, VK_FORMAT_D32_SFLOAT_S8_UINT, VK_FORMAT_D32_SFLOAT },
        VK_IMAGE_TILING_OPTIMAL, VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT);
}

uint32_t Device::FindMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags properties)
{
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(m_physicalDevice, &memProperties);
    for (uint32_t i = 0; i < memProperties.memoryTypeCount; i++) {
        if ((typeFilter & (1 << i)) && ((memProperties.memoryTypes[i].propertyFlags & properties) == properties)) {
            return i;
        }
    }
    return InvalidMemoryType;
}

VkQueue Device::GetNativeQueue()
{
    return m_queue;
}

uint32_t Device::GetQueueFamilyIndex()
{
    return m_queueFamilyIndex;
}

VkPhysicalDevice Device::GetNativePhysicalDevice()
{
    return m_physicalDevice;
}

VkInstance Device::GetNativeInstance()
{
    return m_instance;
}

VkPhysicalDeviceProperties Device::GetPhysicalDeviceProperties()
{
    return m_physicalDevicePorperties;
}
} // namespace VulkanFG
