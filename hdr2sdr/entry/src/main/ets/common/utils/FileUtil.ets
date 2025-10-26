/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class FileUtil {
  // Create and open a file.
  static createOrOpen(path: string): fileIo.File | undefined {
    let file: fileIo.File | undefined = undefined;
    try {
      let isExist = fileIo.accessSync(path);
      if (isExist) {
        file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE);
      } else {
        file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      }
    } catch (error) {
      hilog.error(0x0000, 'FileUtil', `open file failed. error code is =${error.code}, message is = ${error.message}`);
    }
    return file;
  }

  // Save the arraybuffer to a file.
  static writeBufferToFile(path: string, arrayBuffer: ArrayBuffer): number {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let value = fileIo.writeSync(file.fd, arrayBuffer);
      fileIo.closeSync(file);
      return value;
    } catch (error) {
      hilog.error(0x0000, 'FileUtil', `writeFile error. code is =${error.code}, message is = ${error.message}`);
      return -1;
    }
  }

  // Save the text content to a file.
  static writeStrToFile(path: string, text: string): number {
    try {
      let file = fileIo.openSync(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let value = fileIo.writeSync(file.fd, text);
      fileIo.closeSync(file);
      return value;
    } catch (error) {
      hilog.error(0x0000, 'FileUtil', `writeFile error code is =${error.code}, message is = ${error.message}`);
      return -1;
    }
  }
}