/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

#include "world_file_manager.h"
#include "app_file.h"
#include "app_util.h"
#include "world_file_manager.h"
#include <string>
#include <sys/stat.h>

using namespace std;
using namespace std::chrono;

namespace ARWorld {

bool WorldFileManager::IsFolderExist(const std::string &path)
{
    struct stat info;
    char pathC[120];
    sprintf(pathC, "%s", path.c_str());
    if (stat(pathC, &info) != 0) {
        return false;
    } else if (info.st_mode & S_IFDIR) {
        return true;
    } else {
        return false;
    }
}

bool WorldFileManager::InitImageDataBaseFile()
{
    if (!IsFolderExist(mRootPath)) {
        LOGI("WorldFileManager::InitImageDataBaseFile Folder is not exist, %{public}s.", mRootPath);
        return false;
    }
    sprintf(mImageDataBasePath, "%s/ImageDatabase", mRootPath);
    if (strlen(mImageDataBasePath) == 0) {
        LOGI("WorldFileManager::InitImageDataBaseFile path is empty.");
        return false;
    }
    LOGI("WorldFileManager::InitImageDataBaseFile path: %s.", mImageDataBasePath);
    if (!IsFolderExist(mImageDataBasePath)) {
        LOGI("WorldFileManager::InitImageDataBaseFile Folder is not exist.");
        int status = mkdir(mImageDataBasePath, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
        if (status != 0) {
            LOGI("WorldFileManager::InitImageDataBaseFile Folder created failed.");
            sprintf(mImageDataBasePath, "");
            return false;
        }
        LOGI("WorldFileManager::InitImageDataBaseFile Folder created successfully.");
    }

    LOGI("WorldFileManager::InitImageDataBaseFile path: %s.", mImageDataBasePath);
    char databaseFileName[32] = "";
    LOGI("WorldFileManager::ReadImageDataBase path: %s.", mImageDataBasePath);
    sprintf(databaseFileName, "ImageDataBase_%s.bin", mImageDataBaseName);

    sprintf(mImageDataBaseFilePath, "%s/%s", mImageDataBasePath, databaseFileName);
    LOGI("WorldFileManager::InitImageDataBaseFile file path: %s.", mImageDataBaseFilePath);

    return true;
}

void WorldFileManager::SaveImageDataBase(AREngine_ARSession *arSession, AREngine_ARAugmentedImageDatabase *mDataBase)
{
    LOGI("WorldFileManager::SaveImageDataBase");

    if (strlen(mImageDataBasePath) == 0) {
        InitImageDataBaseFile();
    }
    if (strlen(mImageDataBasePath) == 0) {
        LOGI("WorldFileManager::mImageDataBasePath is null.");
        return;
    }
    mImageDataBaseFileObj = fopen(mImageDataBaseFilePath, "w+");
    if (mImageDataBaseFileObj == nullptr) {
        int errNum = 0;
        errNum = errno;
        LOGI("WorldFileManager::InitImageDataBaseFile FILE obj is nullptr, path:%{public}s, reason=%s.",
             mImageDataBaseFilePath, strerror(errNum));
        return;
    }

    uint8_t *buffer;
    uint64_t bufLen;
    if (arSession == nullptr || mDataBase == nullptr) {
        LOGW("The mDataBase or arSession is null.");
        return;
    }
    // Serialized feature library
    CHECK(HMS_AREngine_ARAugmentedImageDatabase_Serialize(mDataBase, &buffer, &bufLen));
    LOGD("ArImageApp::HMS_AREngine_ARAugmentedImageDatabase_Serialize mDataBufferSize:%{public}ld.", bufLen);
    if (fwrite(buffer, sizeof(char), bufLen, mImageDataBaseFileObj) != bufLen) {
        LOGE("Failed to write buffer to file.");
        delete[] buffer;
        return;
    }
    delete[] buffer;
    fclose(mImageDataBaseFileObj);
}

bool WorldFileManager::ReadImageDataBase(AREngine_ARAugmentedImageDatabase *mDataBase)
{
    LOGI("WorldFileManager::ReadImageDataBase");
    if (!IsFolderExist(mRootPath)) {
        LOGI("WorldFileManager::ReadImageDataBase Folder is not exist, %{public}s.", mRootPath);
        return false;
    }
    sprintf(mImageDataBasePath, "%s/ImageDatabase", mRootPath);
    if (strlen(mImageDataBasePath) == 0) {
        LOGI("WorldFileManager::ReadImageDataBase path is empty.");
        return false;
    }
    LOGI("WorldFileManager::ReadImageDataBase path: %s.", mImageDataBasePath);
    if (!IsFolderExist(mImageDataBasePath)) {
        LOGI("WorldFileManager::ReadImageDataBase Folder is not exist.");
        return false;
    }
    char databaseFileName[32] = "";
    LOGI("WorldFileManager::ReadImageDataBase path: %s.", mImageDataBasePath);
    sprintf(databaseFileName, "ImageDataBase_%s.bin", mImageDataBaseName);

    char imageDataBasePath[160];
    sprintf(imageDataBasePath, "%s/%s", mImageDataBasePath, databaseFileName);
    LOGI("WorldFileManager::ReadImageDataBase file path: %{public}s.", imageDataBasePath);

    // Open file
    app_file file;
    if (file.Open(imageDataBasePath) != 0) {
        LOGW("WorldFileManager::Failed to open file.");
        return false;
    }
    int64_t lengthFile = file.GetSize();
    char *buffer = new char[lengthFile];
    LOGW("WorldFileManager::lengthFile:%{public}ld.", lengthFile);
    file.Read(buffer, lengthFile);
    const uint8_t *ptr = reinterpret_cast<const uint8_t *>(buffer);
    uint64_t buflen = static_cast<uint64_t>(lengthFile);
    // Serialized feature library
    CHECK(HMS_AREngine_ARAugmentedImageDatabase_Deserialize(ptr, buflen, &mDataBase));
    delete[] buffer;
    file.Close();
    LOGI("WorldFileManager::HMS_AREngine_ARAugmentedImageDatabase_Serialize mDataBufferSize:%{public}ld.", buflen);
    return true;
}

} // namespace ARWorld
