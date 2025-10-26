/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
 */

#include <asset.hpp>
#include <log.hpp>
#include <rawfile/raw_file_manager.h>

namespace FrameGeneration {
namespace {
NativeResourceManager *g_nativeResourceManager = nullptr;
} // end of anonymous namespace

void Asset::Init(NativeAssetManager assetManager) noexcept
{
    g_nativeResourceManager = static_cast<NativeResourceManager *>(assetManager);
}

Asset::Content Asset::Load(char const * path) noexcept
{
    struct Holder final {
        explicit Holder(char const * path) noexcept
        {
            file_ = OH_ResourceManager_OpenRawFile(g_nativeResourceManager, path);
        }

        ~Holder() noexcept
        {
            if (file_) {
                OH_ResourceManager_CloseRawFile(file_);
            }
        }

        RawFile *file_ = nullptr;
    } const holder(path);

    if (!holder.file_) {
        GOLOGE("Can't open file '%s'", path);
        return std::nullopt;
    }

    long const s = OH_ResourceManager_GetRawFileSize(holder.file_);
    std::vector<uint8_t> content(static_cast<size_t>(s));
    uint8_t *ptr = content.data();
    int left = static_cast<int>(s);

    do {
        int const read = OH_ResourceManager_ReadRawFile(holder.file_, ptr, left);
        if (read == 0) {
            GOLOGE("Internal error during reading file '%s'", path);
            return std::nullopt;
        }

        ptr += static_cast<size_t>(read);
        left -= read;
    } while (left);

    return std::move(content);
}
} // namespace FrameGeneration
