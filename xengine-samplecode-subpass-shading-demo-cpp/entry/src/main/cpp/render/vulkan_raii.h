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
 
#ifndef VULKAN_RAII_H
#define VULKAN_RAII_H

#include <vulkan/vulkan.h>
#include <functional>

/**
 * This RAII class is used to hold Vulkan handles; just like a std::unique_ptr, but for Vulkan handles instead of
 * pointers It will call deletef upon destruction It also support move operations, which is implemented by swapping,
 * which will correctly destruct the old resource, since the right value argument get destructed right after the
 * operation It does not support copy operation
 */
template <typename T> class VulkanRaii {
public:
    using obj_t = T;

    VulkanRaii() : object(nullptr), deleter([](T &) {}) {}

    VulkanRaii(T obj, std::function<void(T &)> deleter) : object(obj), deleter(deleter) {}

    ~VulkanRaii() { cleanup(); }

    T &get() { return object; }

    const T &get() const { return object; }

    T *data() { return &object; }

    VulkanRaii(VulkanRaii<T> &&other): object(nullptr), deleter([](T &) {})
    {
        swap(*this, other);
    }
    VulkanRaii<T> &operator=(VulkanRaii<T> &&other)
    {
        swap(*this, other);
        return *this;
    }
    friend void swap(VulkanRaii<T> &first, VulkanRaii<T> &second)
    {
        using std::swap;
        swap(first.object, second.object);
        swap(first.deleter, second.deleter);
    }

    VulkanRaii<T> &operator=(const VulkanRaii<T> &) = delete;
    VulkanRaii(const VulkanRaii<T> &) = delete;

private:
    T object;
    std::function<void(T &)> deleter;

    void cleanup() { deleter(object); }
};
#endif