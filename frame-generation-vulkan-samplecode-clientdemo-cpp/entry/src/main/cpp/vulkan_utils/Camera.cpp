/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include "Camera.h"
#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/gtc/matrix_transform.hpp>

namespace VulkanFG {
void Camera::LookAt(const glm::vec3 &eye, const glm::vec3 &center, const glm::vec3 &up)
{
    m_viewMatrix = glm::lookAt(eye, center, up);
    m_vpMatrix = m_perspectiveMatrix * m_viewMatrix;
}

void Camera::SetViewMatrix(const glm::mat4 &viewMatrix)
{
    m_viewMatrix = viewMatrix;
    m_vpMatrix = m_perspectiveMatrix * m_viewMatrix;
}

void Camera::MakePerspective(float fovY, float aspectRatio, float near, float far)
{
    m_perspectiveMatrix = glm::perspective(glm::radians(fovY), aspectRatio, near, far);
    m_perspectiveMatrix[1][1] *= -1;
    m_vpMatrix = m_perspectiveMatrix * m_viewMatrix;
}
} // namespace VulkanFG
