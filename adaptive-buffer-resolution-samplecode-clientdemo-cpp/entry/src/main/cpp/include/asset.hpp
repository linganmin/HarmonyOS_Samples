/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#ifndef ASSET_HPP
#define ASSET_HPP

#include <optional>
#include <vector>

namespace AdaptiveBufferResolution {
class Asset final {
public:
    using NativeAssetManager = void *;

    using Content = std::optional<std::vector<uint8_t>>;

    Asset() = delete;

    Asset(Asset const &) = delete;
    Asset &operator = (Asset const &) = delete;

    Asset(Asset &&) = delete;
    Asset &operator = (Asset &&) = delete;

    ~Asset() = delete;

    static void Init(NativeAssetManager assetManager) noexcept;
    [[nodiscard]] static Content Load(char const * path) noexcept;
};
} // namespace AdaptiveBufferResolution

#endif // ASSET_HPP
