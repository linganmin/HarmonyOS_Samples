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

#ifndef FILE_FILE_H
#define FILE_FILE_H

#include <string>
#define FILE_INVALID_FD (-1)

class File {
public:
    typedef enum {
        FILE_READ,
        FILE_WRITE,
        FILE_CREATE
    } Mode;

public:
    File();

    ~File();

public:
    bool Open(const std::string &filePath, Mode mode = FILE_READ);

    size_t Read(void *buffer, size_t size);

    size_t Write(const void *buffer, size_t size);

    int Sync();

    bool Seek(int64_t offset);

    bool Tell(int64_t &offset);

    bool Truncate(int64_t size);

    int64_t GetSize();

    void Close();

    int FileNo();

public:
    static bool IsFileExist(const std::string &filePath);

    static int Remove(const std::string &filePath);

    static int Move(const std::string &src, const std::string &dst);

    static int64_t GetSize(const std::string &filePath);

private:
    int m_fd;
    std::string m_filePath;
};
#endif // FILE_FILE_H
