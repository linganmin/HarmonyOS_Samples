/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef HMOS_LIVESTREAM_APICOMPATIBILITY_H
#define HMOS_LIVESTREAM_APICOMPATIBILITY_H


#include <dlfcn.h>
#include <string>
#include <functional>
#include <mutex>
#include <unordered_map>
#include "deviceinfo.h"

namespace ohos {
namespace compatibility {

// Get the current system API version
inline int GetSystemApiVersion()
{
    static int apiVersion = OH_GetSdkApiVersion();
    return apiVersion;
}
// Cached function pointers for performance optimization
class ApiFunctionCache {
public:
    static ApiFunctionCache& GetInstance()
    {
        static ApiFunctionCache instance;
        return instance;
    }

    ApiFunctionCache(const ApiFunctionCache&) = delete;
    ApiFunctionCache& operator=(const ApiFunctionCache&) = delete;

    void* GetFunction(const std::string& library, const std::string& function)
    {
        std::lock_guard<std::mutex> lock(mutex_);
        std::string key = library + "|" + function;

        if (cache_.find(key) != cache_.end()) {
            return cache_[key];
        }

        void* handle = dlopen(library.c_str(), RTLD_LAZY);
        if (!handle) {
            cache_[key] = nullptr;
            return nullptr;
        }

        void* func = dlsym(handle, function.c_str());
        cache_[key] = func;
        handles_.push_back(handle);

        return func;
    }

private:
    ApiFunctionCache() = default;
    ~ApiFunctionCache()
    {
        for (void* handle : handles_) {
            if (handle) dlclose(handle);
        }
    }

    std::mutex mutex_;
    std::unordered_map<std::string, void*> cache_;
    std::vector<void*> handles_;
};

// Core template class - Functions
template<typename FuncPtr>
class ApiFunction {
public:
    ApiFunction(int requiredApiVersion, const std::string& library, const std::string& functionName)
        : requiredApiVersion_(requiredApiVersion)
    {
        void* func = ApiFunctionCache::GetInstance().GetFunction(library, functionName);
        functionPtr_ = reinterpret_cast<FuncPtr>(func);
    }

    bool IsAvailable() const
    {
        return (GetSystemApiVersion() >= requiredApiVersion_) && (functionPtr_ != nullptr);
    }

    FuncPtr Get() const
    {
        return functionPtr_;
    }

    template<typename... Args>
    auto operator()(Args&&... args) const -> decltype(std::declval<FuncPtr>()(std::forward<Args>(args)...))
    {
        if (IsAvailable()) {
            return functionPtr_(std::forward<Args>(args)...);
        }
        return decltype(std::declval<FuncPtr>()(std::forward<Args>(args)...))();
    }

private:
    int requiredApiVersion_;
    FuncPtr functionPtr_ = nullptr;
};

// New: Constant lookup template class
template<typename ConstType>
class ApiConstant {
public:
    ApiConstant(int requiredApiVersion, const std::string& library, const std::string& constantName)
        : requiredApiVersion_(requiredApiVersion)
    {
        void* constant = ApiFunctionCache::GetInstance().GetFunction(library, constantName);
        constantPtr_ = reinterpret_cast<ConstType*>(constant);
    }

    bool IsAvailable() const
    {
        return (GetSystemApiVersion() >= requiredApiVersion_) && (constantPtr_ != nullptr);
    }

    const ConstType& Get() const
    {
        static const ConstType defaultValue{};
        return IsAvailable() ? *constantPtr_ : defaultValue;
    }

    operator const ConstType&() const
    {
        return Get();
    }

private:
    int requiredApiVersion_;
    ConstType* constantPtr_ = nullptr;
};

} // namespace compatibility
} // namespace ohos

// Add prefix to avoid naming conflicts while keeping the macro concise
#define DECLARE_API(name, func_ptr_type, required_api, library) \
    static ohos::compatibility::ApiFunction<func_ptr_type> ApiCompat_##name(required_api, library, #name)

// New: Constant declaration macro
#define DECLARE_API_CONSTANT(name, const_type, required_api, library) \
    static ohos::compatibility::ApiConstant<const_type> ApiCompat_##name(required_api, library, #name)

// New: Declare OH_MD_KEY_VIDEO_ENCODER_ROI_PARAMS constant
// Note: Please adjust the required_api version number and library name according to actual requirements
DECLARE_API_CONSTANT(OH_MD_KEY_VIDEO_ENCODER_ROI_PARAMS, const char*, 20, "libnative_media_venc.so");

#endif // HMOS_LIVESTREAM_APICOMPATIBILITY_H
