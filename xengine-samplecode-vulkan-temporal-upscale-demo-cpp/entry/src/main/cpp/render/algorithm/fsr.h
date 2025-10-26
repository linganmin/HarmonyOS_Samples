/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

#ifndef RENDER_ALGORITHM_FSR_H
#define RENDER_ALGORITHM_FSR_H

#include <assert.h>
#include <vector>
#include <random>
#include <string>
#include "vulkan/vulkan.h"
#include "VulkanTools.h"
#include "VulkanSwapChain.h"
#include "VulkanBuffer.h"
#include "VulkanDevice.h"
#include "VulkanTexture.h"
#include "file/file_operator.h"

class FSR {
public:
    struct InitParams {
        VkFormat format;
        VkPhysicalDevice physicalDevice;
        VkDevice device;
        VkImageView inputView;
        VkRect2D inputRegion;
        VkImageView outputView;
        VkExtent2D outputSize;
        VkRect2D outputRegion;
        float sharpness;
        vks::VulkanDevice *vulkanDevice;
    };

    FSR() {}
    ~FSR();

    void Init(InitParams &initParams);
    void Render(VkCommandBuffer cmdBuffer);

    struct {
        VkDescriptorSetLayout easu;
        VkDescriptorSetLayout rcas;
    } descriptorSetLayouts;

    struct {
        VkPipelineLayout easu;
        VkPipelineLayout rcas;
    } pipelineLayouts;

    struct {
        const uint32_t count = 2;
        VkDescriptorSet easu;
        VkDescriptorSet rcas;
    } descriptorSets;

    struct FrameBufferAttachment {
        VkImage image;
        VkDeviceMemory mem;
        VkImageView view;
        VkFormat format;
        void Destroy(VkDevice device)
        {
            if (view != VK_NULL_HANDLE) {
                vkDestroyImageView(device, view, nullptr);
                view = VK_NULL_HANDLE;
            }
            if (image != VK_NULL_HANDLE) {
                vkDestroyImage(device, image, nullptr);
                image = VK_NULL_HANDLE;
            }
            if (mem != VK_NULL_HANDLE) {
                vkFreeMemory(device, mem, nullptr);
                mem = VK_NULL_HANDLE;
            }
        }
    };
    struct FrameBuffer {
        int32_t width, height;
        VkFramebuffer frameBuffer = VK_NULL_HANDLE;
        VkRenderPass renderPass = VK_NULL_HANDLE;
        void SetSize(int32_t w, int32_t h)
        {
            this->width = w;
            this->height = h;
        }
        void Destroy(VkDevice device)
        {
            if (frameBuffer != VK_NULL_HANDLE) {
                vkDestroyFramebuffer(device, frameBuffer, nullptr);
                frameBuffer = VK_NULL_HANDLE;
            }
            if (renderPass != VK_NULL_HANDLE) {
                vkDestroyRenderPass(device, renderPass, nullptr);
                renderPass = VK_NULL_HANDLE;
            }
        }
    };

    struct {
        struct FSRBF : public FrameBuffer {
            FrameBufferAttachment color;
        } easu, rcas;
    } frameBuffers;

    struct UBOEASU {
        float sharp;
    } uboEASU;

    struct {
        VkPipeline easu;
        VkPipeline rcas;
    } pipelines;

    struct {
        vks::Buffer rcasParams;
    } uniformBuffers;

    struct PushConstants {
        uint32_t extentwidth;
        uint32_t extentheight;
        uint32_t offsetx;
        uint32_t offsety;
    } easuConstants;

private:
    void PrepareOffscreenFramebuffers();
    void SetupDescriptorPool();
    void SetupLayouts();
    void SetupDescriptors();
    void AddEASUResult();
    void PreparePipelines();
    void PrepareUniformBuffers();
    void CreatePipelineCache();
    void BuildCommandBuffers(VkCommandBuffer cmdBuffer);
    VkPipelineShaderStageCreateInfo LoadShader(std::string fileName, VkShaderStageFlagBits stage);
    std::string GetShadersPath() const;
    VkFormat m_format;
    VkPhysicalDevice m_physicalDevice;
    VkDevice m_device;
    VkImageView m_inputView;
    VkRect2D m_inputRegion;
    VkImageView m_outputView;
    VkExtent2D m_outputSize;
    VkRect2D m_outputRegion;
    VkSampler m_colorSampler;
    VkDescriptorPool m_descriptorPool;
    std::vector<VkShaderModule> m_shaderModules;
    VkPipelineCache m_pipelineCache;
    vks::VulkanDevice *m_vulkanDevice;
};
#endif // RENDER_ALGORITHM_FSR_H