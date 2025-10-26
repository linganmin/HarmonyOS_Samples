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

#ifndef SCENE_H
#define SCENE_H
#define GLM_ENABLE_EXPERIMENTAL
#include <glm/glm.hpp>
#include <glm/gtc/quaternion.hpp>
#include <glm/gtx/quaternion.hpp>
#include <glm/gtc/matrix_transform.hpp>

#include <vector>
#include <string>

struct Camera {
public:
    glm::vec3 position = {1.5f, 1.5f, 1.5f};
    glm::quat rotation = {1.0f, 0.0f, 0.0f, 0.0f};
    float rotationSpeed = glm::pi<float>();
    float moveSpeed = 10.f;

    // float fov;
    // glm::vec2 near;
    // glm::vec2 far;

    glm::mat4 getViewMatrix() const
    {
        float scale = 1.1;
        glm::mat4 view2 = glm::lookAt(glm::vec3(position.x * scale, position.y * scale, position.z * scale),
                                      glm::vec3(0.0f, 1.0f, 0.0f),
                                      glm::vec3(0.0f, 1.0f, 0.0f));
        return view2;
    }
};

// for test use
struct TestSceneConfiguration {
    std::string modelFile;
    float scale;
    glm::vec3 minLightPos;
    glm::vec3 maxLightPos;
    float lightRadius;
    int lightNum;
    glm::vec3 cameraPosition;
    glm::quat cameraRotation;
};

TestSceneConfiguration &GetGlobalTestSceneConfiguration();
#endif