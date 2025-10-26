/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "log.hpp"
#include "Buffer.h"
#include "Utils.h"
#include <securec.h>

namespace VulkanFG {
bool Buffer::Init(const BufferDescriptor &descriptor)
{
    VkDevice device = Device::Instance().GetNativeDevice();
    VkBufferCreateInfo bufferInfo{};
    bufferInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;
    bufferInfo.size = descriptor.bufferSize;
    bufferInfo.usage = descriptor.usage;
    bufferInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE;

    if (vkCreateBuffer(device, &bufferInfo, nullptr, &m_buffer) != VK_SUCCESS) {
        GOLOGE("Create vulkan buffer %s failed!", descriptor.name.c_str());
        return false;
    }

    VkMemoryRequirements memRequirements;
    vkGetBufferMemoryRequirements(device, m_buffer, &memRequirements);

    VkMemoryAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocInfo.allocationSize = memRequirements.size;
    allocInfo.memoryTypeIndex =
        Device::Instance().FindMemoryType(memRequirements.memoryTypeBits, descriptor.properties);

    if (vkAllocateMemory(device, &allocInfo, nullptr, &m_bufferMemory) != VK_SUCCESS) {
        GOLOGE("Create allocate vulkan buffer memory %s failed!", descriptor.name.c_str());
        return false;
    }

    vkBindBufferMemory(device, m_buffer, m_bufferMemory, 0);

    m_descriptor = descriptor;
    return true;
}

void *Buffer::Map(size_t size, size_t offset)
{
    if (m_mappedAddr) {
        return m_mappedAddr;
    }
    vkMapMemory(Device::Instance().GetNativeDevice(), m_bufferMemory, 0, size, 0, &m_mappedAddr);
    return m_mappedAddr;
}

void Buffer::Unmap(void *data)
{
    vkUnmapMemory(Device::Instance().GetNativeDevice(), m_bufferMemory);
}

void Buffer::Destroy()
{
    if (m_mappedAddr) {
        Unmap(m_mappedAddr);
        m_mappedAddr = nullptr;
    }
    if (m_buffer != VK_NULL_HANDLE) {
        vkDestroyBuffer(Device::Instance().GetNativeDevice(), m_buffer, nullptr);
        m_buffer = VK_NULL_HANDLE;
    }
    if (m_bufferMemory != VK_NULL_HANDLE) {
        vkFreeMemory(Device::Instance().GetNativeDevice(), m_bufferMemory, nullptr);
        m_bufferMemory = VK_NULL_HANDLE;
    }
}

void Buffer::UpdateData(void *data, size_t size)
{
    if (size > m_descriptor.bufferSize) {
        GOLOGE("Data size overflow. Buffer size %zu less than data size %zu needed to be updated!",
            m_descriptor.bufferSize, size);
        return;
    }

    void *mappedAddr = Map(size, 0);
    if (!mappedAddr) {
        GOLOGE("Map buffer failed when updating buffer %s data.", m_descriptor.name.c_str());
        return;
    }
    errno_t rc = memcpy_s(mappedAddr, size, data, size);
    if (rc != EOK) {
        GOLOGE("Buffer::UpdateData memcpy_s = %d, %s\n", rc, mappedAddr);
    }
}

VkBuffer Buffer::GetNativeBuffer()
{
    return m_buffer;
}

Buffer Buffer::CreateUniform(size_t size)
{
    Buffer buffer;
    BufferDescriptor bufferDesc;
    bufferDesc.name = "UniformBuffer";
    bufferDesc.bufferSize = size;
    bufferDesc.usage = VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT;
    bufferDesc.properties = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    buffer.Init(bufferDesc);
    return buffer;
}

size_t Buffer::GetSize()
{
    return m_descriptor.bufferSize;
}
}
// namespace VulkanFG