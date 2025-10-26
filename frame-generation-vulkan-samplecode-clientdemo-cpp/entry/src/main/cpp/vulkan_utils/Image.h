/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_IMAGE_H
#define HELLO_VULKAN_IMAGE_H
#include <vulkan/vulkan.h>
#include <string>

namespace VulkanFG {
class Image {
public:
    typedef struct ImageDescriptor {
        std::string name;
        uint32_t width;
        uint32_t height;
        VkFormat format;
        VkImageTiling tiling;
        VkImageUsageFlags usage;
        VkMemoryPropertyFlags properties;
        VkImageLayout initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;

        ImageDescriptor &Name(const std::string &s)
        {
            name = s;
            return *this;
        }
        ImageDescriptor &Width(uint32_t w)
        {
            width = w;
            return *this;
        }
        ImageDescriptor &Height(uint32_t h)
        {
            height = h;
            return *this;
        }
        ImageDescriptor &Format(VkFormat f)
        {
            format = f;
            return *this;
        }
        ImageDescriptor &Tile(VkImageTiling t)
        {
            tiling = t;
            return *this;
        }
        ImageDescriptor &Usage(VkImageUsageFlags u)
        {
            usage = u;
            return *this;
        }
        ImageDescriptor &MemProperties(VkMemoryPropertyFlags flags)
        {
            properties = flags;
            return *this;
        }
        ImageDescriptor &InitialLayout(VkImageLayout l)
        {
            initialLayout = l;
            return *this;
        }
    } ImageDescriptor;

    Image() = default;
    bool Init(const ImageDescriptor &descriptor) noexcept;
    [[nodiscard]] VkImage GetNativeImage() noexcept;
    VkImageView GetNativeImageView() noexcept;
    VkImageView GetNativeImageView(VkFormat format, VkImageAspectFlags aspectFlags) noexcept;
    [[nodiscard]] VkSampler GetNativeSampler() noexcept;
    [[nodiscard]] VkFormat GetFormat() noexcept;
    void Destroy() noexcept;
    ~Image() = default;

private:
    VkImage m_image = VK_NULL_HANDLE;
    VkDeviceMemory m_imageMemory = VK_NULL_HANDLE;
    VkImageView m_imageView = VK_NULL_HANDLE;
    VkSampler m_sampler = VK_NULL_HANDLE;
    ImageDescriptor m_descriptor;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_IMAGE_H
