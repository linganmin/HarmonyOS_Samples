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

import { fileIo as fs, picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = 'CsvFileUtil';

export class CsvFileUtil {
  private filename: string | undefined = undefined;
  private path: string | undefined = undefined;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private csvFd: number | undefined = undefined;

  constructor(filename: string) {
    this.filename = filename;
  }

  async getCsvPath() {
    if (!this.context) {
      Logger.error(TAG, 'context is undefined');
      return;
    }
    this.path = this.context.cacheDir + '/' + this.filename;
    let file: fs.File = fs.openSync(this.path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    this.csvFd = file.fd;
  }

  async writeDataToCsv(arr: Array<Array<string | Resource>>) {
    let str: string = '';
    arr.forEach((strArr: Array<string | Resource>, index, arr) => {
      Logger.info(TAG, 'Index:' + index + 'strArr:' + strArr.join(','));
      let tempArr = strArr.map((item) => `"${item}"`);
      if (index === arr.length - 1) {
        str += tempArr.join(',');
      } else {
        str += tempArr.join(',') + '\n';
      }
    });
    str = '\ufeff' + str;
    await fs.write(this.csvFd, str, { encoding: 'utf-8' });
  }

  async closeWriteData() {
    await fs.close(this.csvFd);
    Logger.info(TAG, 'close success');
    if (!this.context) {
      Logger.error(TAG, 'context is undefined');
      return;
    }
    let path = this.context.cacheDir + '/' + this.filename;
    await fs.unlink(path);
  }

  getCsvSavePath() {
    if (!this.path) {
      Logger.error(TAG, 'path is undefined');
      return;
    }
    if (!this.filename) {
      Logger.error(TAG, 'filename is undefined');
      return;
    }
    let result = this.path + '/' + this.filename;
    return result;
  }

  async exportCsvFile() {
    let uris: Array<string> = [];
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.newFileNames = ['audio-check.csv'];
    documentSaveOptions.fileSuffixChoices = ['.csv'];
    const documentViewPicker = new picker.DocumentViewPicker(this.context!);
    await documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      uris = documentSaveResult;
      Logger.info(TAG, 'documentViewPicker.save to file succeed and uris are:' + uris);
    }).catch((err: BusinessError) => {
      Logger.error(TAG, `Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
    });
    const uri = uris[0];
    Logger.info(TAG, 'documentViewPicker:' + uri);
    let file = await fs.open(uri, fs.OpenMode.READ_WRITE);
    Logger.info(TAG, 'open file success fd: ' + file.fd);
    try {
      await fs.copyFile(this.csvFd, file.fd);
      Logger.info(TAG, 'copyFile success');
    } catch (error) {
      Logger.error(TAG, 'documentViewPicker:copy failed:' + JSON.stringify(error));
    }
    Logger.info(TAG, 'documentViewPicker:copy success');
  }
}
