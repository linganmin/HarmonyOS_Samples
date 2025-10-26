/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_UTILS_H
#define HELLO_VULKAN_UTILS_H
#include <vulkan/vulkan.h>
#include <vector>
#include "Buffer.h"
#include "Image.h"

namespace VulkanFG {
[[nodiscard]] void *AlignedAlloc(size_t size, size_t alignment);
void AlignedFree(void *data);
[[nodiscard]] VkCommandBuffer BeginSingleTimeCommands();
void EndSingleTimeCommands(VkCommandBuffer commandBuffer);
void Copy(Buffer &src, Buffer &dst, size_t size);
void Copy(Buffer &src, Image &dst, uint32_t width, uint32_t height);

void TransitionImageLayout(Image &image, VkImageLayout oldLayout, VkImageLayout newLayout,
    VkImageAspectFlags aspectMask = VK_IMAGE_ASPECT_COLOR_BIT);

[[nodiscard]] VkShaderModule CreateShaderModule(const std::vector<uint8_t> &code);
void BuildVertexBuffer(Buffer *buffer, void *vertexData, size_t size);
void BuildTexture(Image *image, void *imageData, uint32_t width, uint32_t height, uint32_t eleSize);
void BeginCommandBuffer(VkCommandBuffer commandBuffer);
void EndCommandBuffer(VkCommandBuffer commandBuffer);

void RecordImageLayoutTransitionCommands(VkCommandBuffer commandBuffer, VkImage image, VkImageAspectFlags aspectMask,
    VkImageLayout oldLayout, VkAccessFlags srcAccessMask, VkPipelineStageFlags sourceStage, VkImageLayout newLayout,
    VkAccessFlags dstAccessMask, VkPipelineStageFlags destinationStage);

void SetupDebugLabels(VkInstance instance);
void SetLabelInternal(VkDevice device, uint64_t handle, VkObjectType type, char const * name) noexcept;

template <class T>[[nodiscard]] uint64_t ToHandle(T handle) noexcept
{
    return reinterpret_cast<uint64_t>(handle);
}

template <class T> void SetLabel(VkDevice device, T handle, VkObjectType type, char const * name) noexcept
{
    SetLabelInternal(device, ToHandle(handle), type, name);
}

class DebugGroup final {
public:
    DebugGroup() = delete;
    DebugGroup(DebugGroup const &) = delete;
    DebugGroup &operator = (DebugGroup const &) = delete;
    DebugGroup(DebugGroup &&) = delete;
    DebugGroup &operator = (DebugGroup &&) = delete;
    explicit DebugGroup(VkCommandBuffer commandBuffer, char const * name) noexcept;
    ~DebugGroup() noexcept;

private:
    VkCommandBuffer commandBuffer_ = VK_NULL_HANDLE;
};
} // namespace VulkanFG
#endif // HELLO_VULKAN_UTILS_H
