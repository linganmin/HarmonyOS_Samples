/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_BUFFER_H
#define HELLO_VULKAN_BUFFER_H

#include "Device.h"
#include <string>

namespace VulkanFG {
class Buffer {
public:
    typedef struct BufferDescriptor {
        std::string name;
        size_t bufferSize;
        VkBufferUsageFlags usage;
        VkMemoryPropertyFlags properties;
        size_t elementNum;
        uint32_t elementSize;

        BufferDescriptor &Name(const std::string &s)
        {
            name = s;
            return *this;
        }
        BufferDescriptor &Size(size_t size)
        {
            bufferSize = size;
            return *this;
        }
        BufferDescriptor &Usage(VkImageUsageFlags u)
        {
            usage = u;
            return *this;
        }
        BufferDescriptor &MemProperties(VkMemoryPropertyFlags flags)
        {
            properties = flags;
            return *this;
        }
        BufferDescriptor &ElementNum(size_t num)
        {
            elementNum = num;
            return *this;
        }
        BufferDescriptor &ElementSize(uint32_t eleSize)
        {
            elementSize = eleSize;
            return *this;
        }
    } BufferDescriptor;

    Buffer() = default;
    bool Init(const BufferDescriptor &descriptor);
    void *Map(size_t size, size_t offset);
    void Unmap(void *data);
    void UpdateData(void *data, size_t size);
    VkBuffer GetNativeBuffer();
    size_t GetSize();
    void Destroy();
    ~Buffer() = default;
    static Buffer CreateUniform(size_t size);

private:
    VkBuffer m_buffer = VK_NULL_HANDLE;
    VkDeviceMemory m_bufferMemory = VK_NULL_HANDLE;
    BufferDescriptor m_descriptor;
    void *m_mappedAddr = nullptr;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_BUFFER_H
