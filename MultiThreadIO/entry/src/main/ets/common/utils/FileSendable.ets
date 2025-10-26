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

import { fileIo } from '@kit.CoreFileKit';
import { collections, taskpool } from '@kit.ArkTS';
import { CommonConstants } from '../constants/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start content]
@Sendable
class Content {
  content: string;

  constructor(content: string) {
    this.content = content;
  }
}
// [End content]

// [Start write_file]
@Concurrent
function writeFile(fd: number[], content: Content, times: number) {
  for (let i: number = 0; i < times; i++) {
    fileIo.write(fd[i], content.content).catch(() => {
      hilog.error(0x0000, 'FileSendable', '%{public}s', 'writeFile error');
    });
  }
}
// [End write_file]

// [Start read_file]
@Concurrent
function readFile(fd: number[], path: string, fileName: string,
  times: number): collections.Array<collections.Array<collections.ArrayBuffer>> {
  let result: collections.Array<collections.Array<collections.ArrayBuffer>> =
    new collections.Array<collections.Array<collections.ArrayBuffer>>();
  for (let i = 0; i < times; i++) {
    let buffSize: number = 4096;
    try {
      let state = fileIo.statSync(path + fileName + JSON.stringify(i) + CommonConstants.FILE_SUFFIX);
      if (state.size === 0) {
        return result;
      }
      let buffer: collections.ArrayBuffer = new collections.ArrayBuffer(Math.min(buffSize, state.size));
      let off: number = 0;
      let len: number = fileIo.readSync(fd[i], buffer as ArrayBuffer, { offset: off, length: buffSize });
      let readLen: number = 0;
      let bufferList: collections.Array<collections.ArrayBuffer> = new collections.Array<collections.ArrayBuffer>();
      while (len > 0) {
        readLen += len;
        bufferList.push(buffer);
        off = off + len;
        if ((state.size - readLen) < buffSize) {
          buffSize = state.size - readLen;
        }
        len = fileIo.readSync(fd[i], buffer as ArrayBuffer, { offset: off, length: buffSize });
      }
      result.push(bufferList);
    } catch (error) {
      hilog.error(0x0000, 'FileSendable', '%{public}s', 'readFile error');
    }
  }
  return result;
}
// [End read_file]

export class FileSendable {
  private path: string = '';
  private content: Content;
  private times: number = 0;
  private fd: number[] = [];
  private fileName: string = CommonConstants.FILE_PREFIX;

  constructor(path: string, content: string, times: number) {
    this.path = path;
    this.content = new Content(content);
    this.times = times;
    for (let i: number = 0; i < times; i++) {
      try {
        let file = fileIo.openSync(path + this.fileName + JSON.stringify(i) + CommonConstants.FILE_SUFFIX,
          fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        this.fd.push(file.fd);
      } catch (error) {
        hilog.error(0x0000, 'FileSendable', '%{public}s', 'init error');
      }
    }
  }

  async closeFile(times: number, fd: number[]): Promise<void> {
    for (let i: number = 0; i < times; i++) {
      fileIo.close(fd[i]).catch(() => {
        hilog.error(0x0000, 'FileSendable', '%{public}s', 'close error');
      });
    }
    return;
  }

  // [Start write]
  async write(): Promise<void> {
    try {
      await taskpool.execute(writeFile, this.fd, this.content, this.times);
    } catch (error) {
      hilog.error(0x0000, 'FileSendable', '%{public}s', 'execute error');
    }
    // [StartExclude write]
    await this.closeFile(this.times, this.fd);
    // [EndExclude write]
    return;
  }

  async read(): Promise<number> {
    try {
      let value = await taskpool.execute(readFile, this.fd, this.path, this.fileName,
        this.times) as collections.Array<collections.Array<collections.ArrayBuffer>>;
      // [StartExclude write]
      await this.closeFile(this.times, this.fd);
      // [EndExclude write]
      return value.length;
    } catch (error) {
      hilog.error(0x0000, 'FileSendable', '%{public}s', 'read error');
      return 0;
    }
  }
  // [End write]
}