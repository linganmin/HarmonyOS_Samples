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

import { fileIo, picker } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import pako from 'pako';
import Logger from './Logger';
import commonUtils from './CommonUtils';
import { CommonConstants } from '../constants/CommonConstants';

let uri: string = '';
let message: string = '';
let context = AppStorage.get('UIAbilityContext') as common.UIAbilityContext;
let filesDir = context.filesDir;

export class PakoUtils {
  /**
   * Save content to the sandbox path.
   */
  saveToPath(content: string): boolean {
    if (content === '') {
      return false;
    }
    let filePath = filesDir + '/hello.txt';
    try {
      let fileStream = fileIo.createStreamSync(filePath, "w+");
      fileStream.writeSync(content);
      fileStream.closeSync();
      return true;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('file operate failed,code is' + ` ${err.code}, message is ${err.message}`);
    }
    return false;
  }

  /**
   * Generate a compressed file and write the contents to the compressed file.
   */
  zipFiles(content: string) {
    if (this.saveToPath(content)) {
      try {
        let stat = fileIo.statSync(filesDir + '/hello.txt');
        const buf = new ArrayBuffer(stat.size);
        const reader = fileIo.openSync(filesDir + '/hello.txt', fileIo.OpenMode.READ_WRITE);
        fileIo.readSync(reader.fd, buf);
        let DocumentSaveOptions = new picker.DocumentSaveOptions();
        DocumentSaveOptions.newFileNames = ['hello.gz'];
        let documentPicker = new picker.DocumentViewPicker();
        documentPicker.save(DocumentSaveOptions).then((DocumentSaveResult: Array<string>) => {
          Logger.info('DocumentViewPicker.save successfully, uri: ' + JSON.stringify(DocumentSaveResult));
          uri = DocumentSaveResult[0];
          let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
          let options: pako.InflateFunctionOptions =
            { gzip: true, level: CommonConstants.ZIP_LEVEL } as pako.InflateFunctionOptions;
          fileIo.writeSync(file.fd, pako.gzip(new Uint8Array(buf), options).buffer);
          fileIo.closeSync(reader);
          fileIo.closeSync(file);
        }).catch((err: BusinessError) => {
          Logger.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
        });
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        Logger.error('DocumentViewPicker failed with err: ' + err.message);
      }
    } else {
      commonUtils.showToast($r('app.string.can_not_compress'));
    }

  }

  /**
   * Decompress and read the string and return it.
   */
  async unZipFiles(): Promise<string> {
    try {
      let DocumentSelectOptions = new picker.DocumentSelectOptions();
      let documentPicker = new picker.DocumentViewPicker();
      await documentPicker.select(DocumentSelectOptions).then((DocumentSelectResult: Array<string>) => {
        Logger.info('DocumentViewPicker.select successfully, uri: ' + JSON.stringify(DocumentSelectResult));
        uri = DocumentSelectResult[0];
        let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
        let stat = fileIo.statSync(file.fd);
        let size = stat.size;
        let buf = new ArrayBuffer(size);
        fileIo.readSync(file.fd, buf);
        const options: pako.InflateFunctionOptions =
          { gzip: true, level: CommonConstants.ZIP_LEVEL } as pako.InflateFunctionOptions;
        const data: Uint8Array = pako.inflate(new Uint8Array(buf), options);
        let textDecoder: util.TextDecoder = util.TextDecoder.create();
        message = textDecoder.decodeToString(data);
        fileIo.closeSync(file);
        Logger.info('DocumentViewPicker.select successfully, message: ' + message);
        return message;
      }).catch((err: BusinessError) => {
        Logger.error('DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
      });
    } catch (error) {
      let err = error as BusinessError;
      Logger.error('DocumentViewPicker.select failed with err: ' + err.message);
    }
    return message;
  }
}

let utils: PakoUtils = new PakoUtils();

export default utils as PakoUtils;