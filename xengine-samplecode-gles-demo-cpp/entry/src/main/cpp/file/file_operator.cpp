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

#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "file_operator.h"

FileOperator FileOperator::m_fileOperator;

FileOperator::~FileOperator() { OH_ResourceManager_ReleaseNativeResourceManager(mgr); }

std::string FileOperator::UnwrapStringFromJs(napi_env env, napi_value param)
{
    std::string defaultValue("");
    size_t size = 0;
    if (napi_get_value_string_utf8(env, param, nullptr, 0, &size) != napi_ok) {
        return defaultValue;
    }
    if (size == 0) {
        return defaultValue;
    }
    std::string value("");
    char *buf = new (std::nothrow) char[size + 1];
    if (buf == nullptr) {
        return value;
    }
    memset(buf, 0, size + 1);
    bool rev = napi_get_value_string_utf8(env, param, buf, size + 1, &size) == napi_ok;
    if (rev) {
        value = buf;
    } else {
        value = defaultValue;
    }
    delete[] buf;
    buf = nullptr;
    return value;
}

std::string FileOperator::GetHapFilesDir()
{
    if (m_stageContext == nullptr) {
        LOGE("FileOperator get application context failed");
        return m_defaultDir;
    }
    napi_value hapFilesDir;
    napi_status status = napi_get_named_property(m_env, m_stageContext, "filesDir", &hapFilesDir);
    if (status != napi_ok) {
        LOGE("FileOperator get filesDir failed, status=%{public}d", status);
        return m_defaultDir;
    }
    auto res = UnwrapStringFromJs(m_env, hapFilesDir);
    m_sCurrentHapFilesDir = (res.empty() ? m_defaultDir : res);
    return m_sCurrentHapFilesDir;
}

void FileOperator::InitEnv(napi_env env)
{
    napi_value resMgr;
    napi_value global;
    napi_status status = napi_get_global(env, &global);
    if (status != napi_ok) {
        LOGE("FileOperator get global context failed");
        return;
    }
    napi_value globalThis;
    status = napi_get_named_property(env, global, "globalThis", &globalThis);
    if (status != napi_ok) {
        LOGE("FileOperator get globalThis failed");
        return;
    }

    status = napi_get_named_property(env, globalThis, "abilityContext", &m_stageContext);
    if (status != napi_ok) {
        LOGE("FileOperator get abilityContext failed");
        return;
    }

    status = napi_get_named_property(env, m_stageContext, "resourceManager", &resMgr);
    if (status != napi_ok) {
        LOGE("FileOperator get resourceManager failed");
        return;
    }
    mgr = OH_ResourceManager_InitNativeResourceManager(env, resMgr);
    if (mgr == nullptr) {
        LOGE("FileOperator init native resource manager failed");
    }
    m_env = env;
    GetHapFilesDir();
}

bool FileOperator::CopyRawFile(const std::string &rawPath, const std::string  &targetPath,
    bool overWrite)
{
    if ((access(targetPath.c_str(), F_OK) == 0) && !overWrite) {
        return true;
    }
    
    auto srcFile = OH_ResourceManager_OpenRawFile(mgr, rawPath.c_str());
    if (srcFile == nullptr) {
        LOGE("FileOperator open src dir %{public}s failed", rawPath.c_str());
        return false;
    }

    File dstFile;
    if (!dstFile.Open(targetPath, File::FILE_CREATE)) {
        LOGE("FileOperator open dst dir %{public}s failed", targetPath.c_str());
        OH_ResourceManager_CloseRawFile(srcFile);
        return false;
    }

    bool result = false;
    int srcFileSize = OH_ResourceManager_GetRawFileSize(srcFile);
    int realReadBytes = 0;
    unsigned char *buffer = nullptr;

    do {
        buffer = new (std::nothrow) unsigned char[srcFileSize];
        if (buffer == nullptr) {
            LOGE("FileOperator alloc mem for read rawfile %s failed, file size: %d", rawPath.c_str(), srcFileSize);
            break;
        }

        realReadBytes = OH_ResourceManager_ReadRawFile(srcFile, buffer, srcFileSize);
        if (srcFileSize != realReadBytes) {
            LOGE("FileOperator read raw file %s failed, file size: %d, real read: %d", rawPath.c_str(),
                 srcFileSize, realReadBytes);
            break;
        }

        if (dstFile.Write(buffer, realReadBytes) != realReadBytes) {
            LOGE("FileOperator write %s failed, realBytes: %d", targetPath.c_str(), realReadBytes);
            break;
        }
        result = true;
    } while (false);

    delete[] buffer;
    OH_ResourceManager_CloseRawFile(srcFile);
    dstFile.Close();

    return result;
}

std::string FileOperator::GetFileAbsolutePath(std::string fileName)
{
    return m_sCurrentHapFilesDir + "/" + fileName;
}

void FileOperator::CopyRawDir(std::string assetsDirName)
{
    RawDir *rawDir = OH_ResourceManager_OpenRawDir(mgr, assetsDirName.c_str());
    int count = OH_ResourceManager_GetRawFileCount(rawDir);

    if (count == 0) {
        return;
    }

    std::string filename;
    for (int i = 0; i < count; i++) {
        if (assetsDirName != "") {
            filename = assetsDirName + "/" + OH_ResourceManager_GetRawFileName(rawDir, i);
        } else {
            filename = assetsDirName  + OH_ResourceManager_GetRawFileName(rawDir, i);
        }
        RawDir *subDir = OH_ResourceManager_OpenRawDir(mgr, filename.c_str());
        int subDirFileCount = OH_ResourceManager_GetRawFileCount(subDir);
        std::string dstDirName = m_sCurrentHapFilesDir + "/" + filename;
        if (subDirFileCount == 0) {
            CopyRawFile(filename, dstDirName, false);
        } else {
            if (access(dstDirName.c_str(), F_OK) == -1) {
                mkdir(dstDirName.c_str(), RWXRWXRWX);
            }
            CopyRawDir(filename);
        }
    }
    OH_ResourceManager_CloseRawDir(rawDir);
}