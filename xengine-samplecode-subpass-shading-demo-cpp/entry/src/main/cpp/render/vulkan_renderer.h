/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
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
 
#ifndef VULKAN_RENDER_H
#define VULKAN_RENDER_H

#include <glm/glm.hpp>

#include <memory>
#include <native_window/external_window.h>

class VulkanRendererImpl;

class VulkanRenderer {
public:
    VulkanRenderer(OHNativeWindow *window);
    ~VulkanRenderer();

    int getDebugViewIndex() const;

    void resize(int width, int height);
    void changeDebugViewIndex(int target_view);
    void requestDraw(float deltatime);
    void cleanUp();

    void setCamera(const glm::mat4 &view, const glm::vec3 campos);

    VulkanRenderer(const VulkanRenderer &) = delete;
    VulkanRenderer &operator=(const VulkanRenderer &) = delete;
    VulkanRenderer(VulkanRenderer &&) = delete;
    VulkanRenderer &operator=(VulkanRenderer &&) = delete;
#if defined(VK_LINUX_CMODEL)
    void createResultImage();
#endif

private:
    std::unique_ptr<VulkanRendererImpl> p_impl;
};

#endif