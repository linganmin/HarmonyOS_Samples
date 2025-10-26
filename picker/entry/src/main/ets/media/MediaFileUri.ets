/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { fileIo } from '@kit.CoreFileKit';
import Logger from '../common/Logger';
import { bufferToString } from '../common/Common';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'MediaFileUri';
// File read/write buffer size
const BUFFER_SIZE = 4096;
// Default value of file fd
const COMMON_FD = -1;
const MODE_READ_ONLY = 0;
const MODE_WRITE_ONLY = 1;
const MODE_READ_WRITE = 2;

export default class MediaFileUri {
  private commonFd: number = COMMON_FD;
  private fileSizeList: Array<number> = [];
  private fileNameList: Array<string> = [];
  private fileUriList: Array<string> = [];
  content: string = '';

  getMode(openFlag: number): number {
    let mode: number = 0;
    switch (openFlag) {
      case MODE_READ_ONLY:
        mode = fileIo.OpenMode.READ_ONLY; // r
        break;
      case MODE_WRITE_ONLY:
        mode = fileIo.OpenMode.WRITE_ONLY; // w
        break;
      case MODE_READ_WRITE:
        mode = fileIo.OpenMode.READ_WRITE; // rw
        break;
    }
    return mode;
  }

  myWriteSync(fd: number, content: string, isClose: boolean): void {
    try {
      let result = fileIo.writeSync(fd, content);
      Logger.info(TAG, 'myWriteSync: write result = ' + result);
    } catch (err) {
      Logger.error(TAG, 'myWriteSync： write failed with error:' + err);
    }
    if (isClose) {
      this.closeSync(fd);
      this.commonFd = COMMON_FD;
    } else {
      this.commonFd = fd;
    }
  }

  // sync-close
  closeSync(fd: number): void {
    try {
      fileIo.closeSync(fd);
      Logger.info(TAG, 'closeSync file finish.');
    } catch (err) {
      Logger.error(TAG, 'closeSync file error = ' + err);
    }
  }

  readFileContent(uri: string, isRead: boolean = true, isClose: boolean = true): string {
    let content = '';
    Logger.info(TAG, 'open path = ' + uri);
    let file: fileIo.File;
    if (isClose || this.commonFd === COMMON_FD) {
      try {
        file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
        Logger.info(TAG, 'openReadSync: get fd success. fd = ' + file.fd);
        this.commonFd = file.fd;
      } catch (err) {
        Logger.error(TAG, 'openReadSync: open file failed. error = ' + err);
        return content;
      }
      if (file === undefined) {
        Logger.error(TAG, 'openReadSync: open file failed. file = undefined.');
        return content;
      }
    }
    if (isRead) {
      try {
        let buffer = new ArrayBuffer(BUFFER_SIZE);
        let readOut = fileIo.readSync(this.commonFd, buffer, { offset: 0 });
        let newBuffer = new ArrayBuffer(readOut);
        let newReadOut = fileIo.readSync(this.commonFd, newBuffer, { offset: 0 });
        content = bufferToString(newBuffer);
      } catch (err) {
        Logger.error(TAG, 'myReadSync: read error: ' + err);
        return content;
      }

      if (isClose) {
        this.closeSync(this.commonFd);
        this.commonFd = COMMON_FD;
      } else {
        this.commonFd = this.commonFd;
      }
    }
    return content;
  }

  myGetFileSize(uri: string, mode: number): number {
    let size: number = 0;
    try {
      let file = fileIo.openSync(uri, mode); // fs.OpenMode.READ_ONLY
      Logger.info(TAG, 'file fd: ' + file.fd);
      let stat = fileIo.statSync(file.fd);
      Logger.info(TAG, 'get file info succeed, the size of file is ' + stat.size);
      size = stat.size;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `myGetFileSize failed, error code=${err.code}, message=${err.message}`);
    }
    return size;
  }

  writeFileContent(uri: string, content: string): void {
    Logger.info(TAG, 'writeFileContent begin');
    try {
      let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      Logger.info(TAG, 'writeFileContent file fd: ' + file.fd);
      let writeLen = fileIo.writeSync(file.fd, content);
      Logger.info(TAG, 'writeFileContent write data to file succeed and size is:' + writeLen);
      fileIo.closeSync(file);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `writeFileContent failed, error code=${err.code}, message=${err.message}`);
    }
  }

  async getAllFiles(): Promise<void> {
    Logger.info(TAG, 'getAllFiles begin');
    AppStorage.setOrCreate('fileNameList', this.fileNameList);
    AppStorage.setOrCreate('fileSizeList', this.fileSizeList);
    AppStorage.setOrCreate('fileUriList', this.fileUriList);
  }
}