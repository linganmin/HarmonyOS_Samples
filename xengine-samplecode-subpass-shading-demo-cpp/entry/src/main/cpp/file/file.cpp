/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024. All rights reserved.
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

#include <bits/alltypes.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "common/common.h"
#include "fcntl.h"
#include "napi/native_api.h"
#include "file.h"

File::File() : m_fd(FILE_INVALID_FD)
{}

File::~File()
{
    Close();
}

bool File::Open(const std::string &filePath, Mode mode)
{
    int flag;
    const char *openFileMode;
    switch (mode) {
        case FILE_READ:
            flag = O_RDONLY;
            openFileMode = "r";
            break;
        case FILE_WRITE:
            flag = O_WRONLY;
            openFileMode = "w";
            break;
        case FILE_CREATE:
            flag = O_WRONLY | O_CREAT | O_TRUNC;
            openFileMode = "w";
            break;
        default:
            return false;
    }

    mode_t oldUmask = umask(0);
    m_fd = open(filePath.c_str(), flag, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

    umask(oldUmask);

    if (m_fd == FILE_INVALID_FD) {
        LOGW("Failed to open file %{public}s, error %{public}d (%{public}s).", filePath.c_str(), errno,
             strerror(errno));
        return false;
    }

    m_filePath = filePath;
    return true;
}

size_t File::Read(void *buffer, size_t size)
{
    if (m_fd == FILE_INVALID_FD) {
        return -1;
    }

    size_t len = read(m_fd, buffer, size);
    return len;
}

size_t File::Write(const void *buffer, size_t size)
{
    if (m_fd == FILE_INVALID_FD) {
        return -1;
    }

    size_t writeSize = 0;
    while (writeSize < size) {
        auto len = write(m_fd, buffer, size);
        if (len < 0) {
            return -1;
        }
        writeSize += len;
    }
    return writeSize;
}

int File::Sync()
{
    if (m_fd == FILE_INVALID_FD) {
        return -1;
    }
    return fsync(m_fd);
}

bool File::Seek(int64_t offset)
{
    if (m_fd == FILE_INVALID_FD) {
        return false;
    }

    int from = SEEK_SET;

    if (offset < 0) {
        offset = 0;
        from = SEEK_END;
    }
    if (lseek(m_fd, static_cast<off_t>(offset), from) < 0) {
        return false;
    }
    return true;
}

bool File::Tell(int64_t &offset)
{
    if (m_fd == FILE_INVALID_FD) {
        return false;
    }
    int64_t ret = lseek(m_fd, 0, SEEK_CUR);
    if (ret < 0) {
        return false;
    }

    offset = ret;
    return true;
}

bool File::Truncate(int64_t size)
{
    if (m_fd == FILE_INVALID_FD) {
        return false;
    }
    if (ftruncate(m_fd, static_cast<off_t>(size)) < 0) {
        return false;
    }
    return true;
}

int64_t File::GetSize()
{
    if (m_fd == FILE_INVALID_FD) {
        LOGE("invalid fd.");
        return -1;
    }

    struct stat st;
    int err = fstat(m_fd, &st);
    if (err) {
        LOGE("Failed to stat file, error %d (%s).", errno, strerror(errno));
        return -1;
    }
    return static_cast<int64_t>(st.st_size);
}

int64_t File::GetSize(const std::string &strFilePath)
{
    struct stat st;
    int result = stat(strFilePath.c_str(), &st);
    if (result != 0) {
        return -1;
    }

    return static_cast<int64_t>(st.st_size);
}

void File::Close()
{
    if (m_fd != FILE_INVALID_FD) {
        close(m_fd);
        m_fd = FILE_INVALID_FD;
        m_filePath.clear();
    }
}

int File::FileNo() { return m_fd; }

bool File::IsFileExist(const std::string &filePath)
{
    struct stat st;
    int result = stat(filePath.c_str(), &st);
    if (result != 0) {
        return false;
    }
    return true;
}

int File::Remove(const std::string &filePath)
{
    if (remove(filePath.c_str())) {
        return false;
    }

    return true;
}

int File::Move(const std::string &src, const std::string &dst)
{
    if (rename(src.c_str(), dst.c_str())) {
        return false;
    }

    return true;
}
