/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common, StartupTask } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';

@Sendable
export default class FileTask extends StartupTask {
  private BUFFER_SIZE: number = 4096;

  constructor() {
    super();
  }

  async init(context: common.AbilityStageContext) {
    let filesDir = context.filesDir;
    this.createFile(filesDir);
  }

  createFile(filesDir: string) {
    try {
      let srcFile = fileIo.openSync(filesDir + '/test.txt', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.writeSync(srcFile.fd, 'Show FileTask init data: write test data');
      let destFile = fileIo.openSync(filesDir + '/destFile.txt', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      // Read the content of the source file and write it to the destination file
      let bufSize = this.BUFFER_SIZE;
      let readSize = 0;
      let buf = new ArrayBuffer(bufSize);

      class Option {
        public offset: number = 0;
        public length: number = bufSize;
      }

      let option = new Option();
      option.offset = readSize;
      let readLen = fileIo.readSync(srcFile.fd, buf, option);
      while (readLen > 0) {
        readSize += readLen;
        fileIo.writeSync(destFile.fd, buf, { length: readLen });
        option.offset = readSize;
        readLen = fileIo.readSync(srcFile.fd, buf, option);
      }
      // close file
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
    } catch (err) {
      hilog.error(0x0000, 'FileTask', `Failed hanlde file, errorCode:${err.code}`);
    }
  }
}