/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "CommandPool.h"
#include "log.hpp"
namespace VulkanFG {
bool CommandPool::Init(const CommandPoolDescriptor &descriptor)
{
    m_descriptor = descriptor;
    m_device = descriptor.device;
    m_queue = descriptor.queue;

    VkCommandPoolCreateInfo poolInfo{};
    poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    poolInfo.flags = descriptor.flags;
    poolInfo.queueFamilyIndex = descriptor.queueFamilyIndex;

    if (vkCreateCommandPool(m_device, &poolInfo, nullptr, &m_commandPool) != VK_SUCCESS) {
        GOLOGE("Create command pool %s failed.", m_descriptor.name.c_str());
        return false;
    }

    return true;
}

void CommandPool::Destroy()
{
    vkDestroyCommandPool(m_device, m_commandPool, nullptr);
}

CommandPool::~CommandPool()
{
    Destroy();
}

VkCommandBuffer CommandPool::AllocateSingleTimeCommandBuffer()
{
    VkCommandBufferAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandPool = m_commandPool;
    allocInfo.commandBufferCount = 1;

    VkCommandBuffer commandBuffer = VK_NULL_HANDLE;
    vkAllocateCommandBuffers(m_device, &allocInfo, &commandBuffer);
    return commandBuffer;
}

void CommandPool::DeallocateSingleTimeCommandBuffer(VkCommandBuffer commandBuffer)
{
    vkFreeCommandBuffers(m_device, m_commandPool, 1, &commandBuffer);
}

VkQueue CommandPool::GetQueue()
{
    return m_queue;
}

uint32_t CommandPool::GetQueueIndex()
{
    return m_descriptor.queueFamilyIndex;
}

void CommandPool::AllocateCommandBuffers(VkCommandBuffer *cmdBuffers, uint32_t num)
{
    VkCommandBufferAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandPool = m_commandPool;
    allocInfo.commandBufferCount = num;

    VkCommandBuffer commandBuffer = VK_NULL_HANDLE;
    vkAllocateCommandBuffers(m_device, &allocInfo, cmdBuffers);
    return;
}

void CommandPool::DeaocateCommandBuffers(VkCommandBuffer *cmdBuffers, uint32_t num)
{
    vkFreeCommandBuffers(m_device, m_commandPool, num, cmdBuffers);
}
} // namespace VulkanFG
