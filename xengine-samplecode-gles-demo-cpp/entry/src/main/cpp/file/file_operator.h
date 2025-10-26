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

#ifndef FILE_FILE_OPERATOR_H
#define FILE_FILE_OPERATOR_H

#include <string>
#include <rawfile/raw_file_manager.h>
#include <js_native_api.h>
#include <js_native_api_types.h>
#include "common/common.h"
#include "file.h"

#define RWXRWXRWX 0777

class FileOperator {
public:
    static FileOperator *GetInstance() { return &FileOperator::m_fileOperator; }
    ~FileOperator();
    void InitEnv(napi_env env);
    std::string GetFileAbsolutePath(std::string fileName);
    bool CopyRawFile(const std::string &rawPath, const std::string &targetPath, bool overWrite);
    void CopyRawDir(std::string assetsDirName);

private:
    static FileOperator m_fileOperator;
    std::string UnwrapStringFromJs(napi_env env, napi_value param);
    std::string GetHapFilesDir();
    NativeResourceManager *mgr;
    napi_env m_env;
    napi_value m_stageContext;
    std::string m_defaultDir = "/data/storage/el2/base/haps/entry/files";
    std::string m_sCurrentHapFilesDir;
};

#endif // FILE_FILE_OPERATOR_H
