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

#ifndef UTIL_H
#define UTIL_H

#include "file/file_operator.h"

#define GLM_ENABLE_EXPERIMENTAL
#include <glm/glm.hpp>
#include <glm/gtx/hash.hpp>

#include <string>
#include <vector>
#include <tuple>
#include <memory>

const int SEEDNUM1 = 6;
const int SEEDNUM2 = 2;

namespace util {
    template <class T> void HashCombine(std::size_t &seed, const T &v)
    {
        std::hash<T> hasher;
        seed ^= hasher(v) + 0x9e3779b9 + (seed << SEEDNUM1) + (seed >> SEEDNUM2);
    }

    struct Vertex {
        glm::vec3 pos;
        glm::vec3 color;
        glm::vec2 tex_coord;
        glm::vec3 normal;

        using index_t = uint32_t;

        bool operator==(const Vertex &other) const noexcept
        {
            return pos == other.pos && color == other.color && tex_coord == other.tex_coord && normal == other.normal;
        }

        size_t hash() const
        {
            size_t seed = 0;
            HashCombine(seed, pos);
            HashCombine(seed, color);
            HashCombine(seed, tex_coord);
            HashCombine(seed, normal);
            return seed;
        }
    };

    template <typename str_t> std::string getContentPath(str_t &&filename)
    {
        static std::string content_folder{FileOperator::GetInstance()->GetAssetPath()};
        return content_folder + "/" + std::forward<str_t>(filename);
    }

    std::vector<char> readFile(const std::string &filename);

    constexpr glm::vec3 vec_up = glm::vec3(0.0f, 1.0f, 0.0f);
    constexpr glm::vec3 vec_right = glm::vec3(1.0f, 0.0f, 0.0f);
    constexpr glm::vec3 vec_forward = glm::vec3(0.0f, 0.0f, -1.0f);

    constexpr float SMALL_NUMBER = 1e-8f;

    inline bool isNearlyEqual(float a, float b, float tolerance = SMALL_NUMBER)
    {
        return glm::abs(a - b) <= SMALL_NUMBER;
    }

    inline std::string findFolderName(const std::string &str) { return str.substr(0, str.find_last_of("/\\")); }

} // namespace util

#endif