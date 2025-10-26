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

import { fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';
import { Logger } from './Logger';

export class FileReader {
  public static async readJson(context: Context, fileName: string): Promise<object> {
    try {
      return await FileReader.readContent(context.resourceDir + '/' + fileName).then((content: string) => {
        return Promise.resolve(JSON.parse(content));
      })
    } catch (err) {
      Logger.error('readJson error', err + ' -> Attempting to read the rawfile folder');
      return FileReader.readRawFileContent(context, fileName);
    }
  }

  private static readContent(filePath: string): Promise<string> {
    try {
      return fs.readText(filePath);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`FileReader`, `readContent error.code => ${error.code}, error.message => ${error.message}`);
      return Promise.resolve('');
    }
  }

  private static async readRawFileContent(context: Context, filepath: string): Promise<object> {
    return await context.resourceManager.getRawFileContent(filepath).then((data: Uint8Array) => {
      return JSON.parse(buffer.from(data.buffer).toString()) as object
    }).catch((err: BusinessError) => {
      Logger.error('readJson error', 'rawfile error: ' + err);
      return new Object;
    })
  }
}
