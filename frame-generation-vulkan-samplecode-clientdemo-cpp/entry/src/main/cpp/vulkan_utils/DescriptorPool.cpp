/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "DescriptorPool.h"
#include "Device.h"
#include "log.hpp"
#include "fif.h"
#include <array>

// This is assumptions mostly. Fragile code.
#define MAX_DESCRIPTOR_SET_NUM 40
#define UNIFORM_BUFFER_NUM 40
#define TEXTURE_NUM 40
#define MAX_DYNAMIC_UNIFORM_BUFFER_NUM 5
namespace VulkanFG {
void DescriptorPool::Init()
{
    constexpr static VkDescriptorPoolSize const poolSizes[] = {
        {
            .type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            .descriptorCount = static_cast<uint32_t>(VulkanFG::FRAMES_IN_FLIGHT * UNIFORM_BUFFER_NUM)
        },
        {
            .type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER,
            .descriptorCount = static_cast<uint32_t>(VulkanFG::FRAMES_IN_FLIGHT * UNIFORM_BUFFER_NUM)
        },
        {
            .type = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
            .descriptorCount = static_cast<uint32_t>(VulkanFG::FRAMES_IN_FLIGHT * TEXTURE_NUM)
        },
        {
            .type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC,
            .descriptorCount = static_cast<uint32_t>(VulkanFG::FRAMES_IN_FLIGHT * MAX_DYNAMIC_UNIFORM_BUFFER_NUM)
        }
    };

    constexpr VkDescriptorPoolCreateInfo poolInfo {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
        .pNext = nullptr,
        .flags = VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT,
        .maxSets = static_cast<uint32_t>(VulkanFG::FRAMES_IN_FLIGHT * MAX_DESCRIPTOR_SET_NUM),
        .poolSizeCount = static_cast<uint32_t>(std::size(poolSizes)),
        .pPoolSizes = poolSizes
    };

    if (vkCreateDescriptorPool(Device::Instance().GetNativeDevice(), &poolInfo, nullptr, &m_descriptorPool) !=
        VK_SUCCESS) {
        GOLOGE("Create descriptor pool failed.");
    }
}

VkDescriptorPool DescriptorPool::GetNativeDescriptorPool()
{
    return m_descriptorPool;
}
} // namespace VulkanFG