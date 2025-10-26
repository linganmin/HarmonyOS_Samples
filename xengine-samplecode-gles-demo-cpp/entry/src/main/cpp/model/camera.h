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

#ifndef MODEL_CAMERA_H
#define MODEL_CAMERA_H

#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>
#include <glm/gtc/matrix_transform.hpp>

class Camera {
public:
glm::vec3 rotation = glm::vec3();
glm::vec3 position = glm::vec3();
glm::vec4 viewPos = glm::vec4();
struct {
    glm::mat4 perspective;
    glm::mat4 view;
} matrices;

struct VPMatrix {
    glm::mat4 perspective = glm::mat4(0);
    glm::mat4 view = glm::mat4(0);
} curVP, preVP;

void SetMovement(float speed, int distance)
{
    m_moveSpeed = speed;
    m_maxDistance = distance;
}

void SetPerspective(float fov, float aspect, float znear, float zfar)
{
    this->m_fov = fov;
    this->m_znear = znear;
    this->m_zfar = zfar;
    matrices.perspective = glm::perspective(glm::radians(fov), aspect, znear, zfar);
    if (m_flipY) {
        matrices.perspective[1][1] *= -1.0f;
    }
};

void SetRotation(glm::vec3 rotation)
{
    this->rotation = rotation;
    UpdateViewMatrix();
}
    
void Update()
{
    m_updated = false;
    preVP = curVP;
    if (m_forwad) {
        position.x+= m_moveSpeed;
        if (position.x >= m_maxDistance) {
            m_forwad = !m_forwad;
        }
    } else {
        position.x-= m_moveSpeed;
        if (position.x <= -m_maxDistance) {
            m_forwad = !m_forwad;
        }
    }
    UpdateViewMatrix();
    curVP.perspective = matrices.perspective;
    curVP.view = matrices.view;
};
private:
float m_fov;
float m_znear, m_zfar;
bool m_forwad;
bool m_updated = false;
bool m_flipY = false;
float m_moveSpeed;
float m_maxDistance;

void UpdateViewMatrix()
{
    glm::mat4 rotM = glm::mat4(1.0f);
    glm::mat4 transM;

    rotM = glm::rotate(rotM, glm::radians(rotation.x * (m_flipY ? -1.0f : 1.0f)), glm::vec3(1.0f, 0.0f, 0.0f));
    rotM = glm::rotate(rotM, glm::radians(rotation.y), glm::vec3(0.0f, 1.0f, 0.0f));
    rotM = glm::rotate(rotM, glm::radians(rotation.z), glm::vec3(0.0f, 0.0f, 1.0f));

    glm::vec3 translation = position;
    if (m_flipY) {
        translation.y *= -1.0f;
    }
    transM = glm::translate(glm::mat4(1.0f), translation);
    matrices.view = rotM * transM;
    viewPos = glm::vec4(position, 0.0f) * glm::vec4(-1.0f, 1.0f, -1.0f, 1.0f);
    m_updated = true;
};
};
#endif // MODEL_CAMERA_H