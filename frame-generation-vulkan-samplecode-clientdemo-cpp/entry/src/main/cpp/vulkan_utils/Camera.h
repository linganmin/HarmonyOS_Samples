/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_CAMERA_H
#define HELLO_VULKAN_CAMERA_H

#include "glm/vec3.hpp"
#include "glm/mat4x4.hpp"

namespace VulkanFG {
class Camera {
public:
    static constexpr float s_defaultFoV = 60.0f;
    void LookAt(const glm::vec3 &eye, const glm::vec3 &center, const glm::vec3 &up);
    void SetViewMatrix(const glm::mat4 &viewMatrix);
    void MakePerspective(float fovY, float aspectRatio, float near, float far);
    glm::mat4 GetViewMatrix()
    {
        return m_viewMatrix;
    }
    glm::mat4 GetPerspectiveMatrix()
    {
        return m_perspectiveMatrix;
    }
    glm::mat4 GetViewPerspectiveMatrix()
    {
        return m_vpMatrix;
    }

private:
    glm::mat4 m_viewMatrix;
    glm::mat4 m_perspectiveMatrix;
    glm::mat4 m_vpMatrix;
};
} // namespace VulkanFG

#endif // HELLO_VULKAN_CAMERA_H
