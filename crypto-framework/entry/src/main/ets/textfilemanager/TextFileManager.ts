/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import Logger from '../util/Logger';

const TAG: string = '[Crypto_Framework]';
const FILE_SLEEP_TIME: number = 100;
const TEXT_MAX_READ_LEN: number = 8192;

/**
 * filePicker and file management, in OH 4.0.8.2 mirror version, after reading the uri, can not directly read,
   write file content, need to sleep tens of ms, here sleep100 milliseconds.
 * @param time
 * @returns
 */
function sleep(time: number): Promise<number> {
  return new Promise((resolve) => setTimeout(resolve, time));
}

class TextFileManager {
  public static readString: string = '';
  public static readResult: number = 0;
  public static readName: string = '';
  public static writeResult: number = 0;

  async readTextFile(textFileUri: string): Promise<void> {
    await sleep(FILE_SLEEP_TIME);
    try {
      // read.
      let file = fileIo.openSync(textFileUri, fileIo.OpenMode.READ_ONLY);
      Logger.info(TAG, 'success, read only file ' + file.fd);
      // Read a section of content from a file with a maximum length of 8192.
      let buf = new ArrayBuffer(TEXT_MAX_READ_LEN);
      try {
        let readLen: number = fileIo.readSync(file.fd, buf, { offset: 0 });
        TextFileManager.readString = String.fromCharCode.apply(null, new Uint8Array(buf.slice(0, readLen)));
        TextFileManager.readResult = readLen;
        TextFileManager.readName = file.name;
      } catch (error1) {
        Logger.error(TAG, `file read failed, ${error1.code}, ${error1.message}`);
      }
      fileIo.closeSync(file);
    } catch (error) {
      Logger.error(TAG, `file open failed, ${error.code}, ${error.message}`);
      return;
    }
  }

  async writeTextFile(textFileUri: string, textString: string): Promise<void> {
    await sleep(FILE_SLEEP_TIME);
    try {
      // read.
      let file = fileIo.openSync(textFileUri, fileIo.OpenMode.READ_WRITE);
      Logger.info(TAG, 'success, read write file' + file.fd);
      try {
        // Write in.
        let writeLen = fileIo.writeSync(file.fd, textString);
        Logger.info(TAG, 'success, The length of str is: ' + writeLen);
        TextFileManager.writeResult = writeLen;
      } catch (error1) {
        Logger.error(TAG, `file write failed, ${error1.code}, ${error1.message}`);
      }
      fileIo.closeSync(file);
    } catch (error) {
      Logger.error(TAG, `file open failed, ${error.code}, ${error.message}`);
      return;
    }
  }

  getString(): string {
    return TextFileManager.readString;
  }

  getName(): string {
    return TextFileManager.readName;
  }
}

export default new TextFileManager();