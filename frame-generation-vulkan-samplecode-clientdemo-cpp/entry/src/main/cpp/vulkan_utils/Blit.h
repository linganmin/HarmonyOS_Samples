/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_BLIT_H
#define HELLO_VULKAN_BLIT_H

#include <cstdint>
#include "Singleton.hpp"
#include <vulkan/vulkan_core.h>

namespace VulkanFG {
class Blit final : public Singleton<Blit> {
public:
    struct BlitDescriptor final {
        VkExtent2D dstResolution{};
        VkRenderPass renderPass = VK_NULL_HANDLE;
        uint32_t subpass = 0U;
    };

    Blit() = default;
    Blit(Blit const &) = delete;
    Blit &operator = (Blit const &) = delete;
    Blit(Blit &&) = delete;
    Blit &operator = (Blit &&) = delete;
    ~Blit() override = default;

    void Init(BlitDescriptor &&desc);
    void Destroy();
    void Run(VkCommandBuffer commandBuffer, VkDescriptorSet scrImage);
    [[nodiscard]] VkDescriptorSetLayout GetDescriptorSetLayout();

    [[nodiscard]] constexpr static uint32_t GetSourceImageBinding()
    {
        return 1U;
    }

private:
    [[nodiscard]] bool CreateDSLayout(VkDevice device);
    [[nodiscard]] bool CreatePipelineLayout(VkDevice device);
    [[nodiscard]] bool CreatePipeline(VkDevice device, BlitDescriptor const & desc);

    VkPipeline m_pipeline = VK_NULL_HANDLE;
    VkPipelineLayout m_pipelineLayout = VK_NULL_HANDLE;
    VkDescriptorSetLayout m_dsLayout = VK_NULL_HANDLE;
};
}; // namespace VulkanFG

#endif // HELLO_VULKAN_BLIT_H
