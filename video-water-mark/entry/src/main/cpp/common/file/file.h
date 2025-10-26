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

#ifndef APP_FILE_H
#define APP_FILE_H

#include <cstdint>
#include <string>

enum class FileType {
    File_PCM = 1,
    File_AAC,
};

struct AppFile {
    static AppFile &GetInstance()
    {
        static AppFile file_;
        return file_;
    }

public:
    void InitFile(uint16_t type = 0);
    void WriteFile(uint16_t type, void *buffer, int32_t len);
    void CloseFile(uint16_t type = 0);

private:
    std::string pcmPath_ = "/data/storage/el2/base/haps/entry/files/oh_test_audio.pcm";
    std::string aacPath_ = "/data/storage/el2/base/haps/entry/files/oh_test_audio.aac";

    FILE *pcmFile_ = nullptr;
    FILE *aacFile_ = nullptr;

    void InitPCMFile();
    void InitAACFile();

    void ClosePCMFile();
    void CloseAACFile();
};

#endif  // APP_FILE_H