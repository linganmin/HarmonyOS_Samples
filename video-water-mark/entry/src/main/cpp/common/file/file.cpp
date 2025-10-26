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

#include "file.h"
#include <cstdint>

void AppFile::InitFile(uint16_t type)
{
    switch ((FileType)type) {
        case FileType::File_PCM: {
            InitPCMFile();
            break;
        }
        case FileType::File_AAC: {
            InitAACFile();
            break;
        }
        default: {
            InitPCMFile();
            InitAACFile();
            break;
        }
    }
}

void AppFile::WriteFile(uint16_t type, void *buffer, int32_t len)
{
    switch ((FileType)type) {
        case FileType::File_PCM: {
            if (pcmFile_ != nullptr) {
                fwrite(buffer, len, 1, pcmFile_);
            }
            break;
        }
        case FileType::File_AAC: {
            if (aacFile_ != nullptr) {
                fwrite(buffer, len, 1, aacFile_);
            }
            break;
        }
    }
}

void AppFile::CloseFile(uint16_t type)
{
    switch ((FileType)type) {
        case FileType::File_PCM: {
            ClosePCMFile();
            break;
        }
        case FileType::File_AAC: {
            CloseAACFile();
            break;
        }
        default: {
            ClosePCMFile();
            CloseAACFile();
            break;
        }
    }
}

void AppFile::InitPCMFile()
{
    if (pcmFile_ == nullptr) {
        pcmFile_ = fopen(pcmPath_.c_str(), "ab+");
    }
}

void AppFile::InitAACFile()
{
    if (aacFile_ == nullptr) {
        aacFile_ = fopen(aacPath_.c_str(), "ab+");
    }
}

void AppFile::ClosePCMFile()
{
    if (pcmFile_ != nullptr) {
        fclose(pcmFile_);
        pcmFile_ = nullptr;
    }
}

void AppFile::CloseAACFile()
{
    if (aacFile_ != nullptr) {
        fclose(aacFile_);
        aacFile_ = nullptr;
    }
}