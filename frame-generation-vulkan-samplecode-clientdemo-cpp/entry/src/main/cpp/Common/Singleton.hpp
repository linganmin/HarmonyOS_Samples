/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef HELLO_VULKAN_SINGLETON_HPP
#define HELLO_VULKAN_SINGLETON_HPP

namespace VulkanFG {
template <typename T> class Singleton {
public:
    static T &Instance()
    {
        static T s_instance;
        return s_instance;
    }

    Singleton(const Singleton &rhs) = delete;
    Singleton(Singleton &&rhs) = delete;
    Singleton &operator = (const Singleton &rhs) = delete;

protected:
    Singleton() = default;
    virtual ~Singleton() = default;
};
} // namespace VulkanFG


#endif // HELLO_VULKAN_SINGLETON_HPP
