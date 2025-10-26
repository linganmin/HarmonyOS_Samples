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
import { BusinessError, request } from "@kit.BasicServicesKit";
import { fileUri } from "@kit.CoreFileKit";

/*
* FAQ:报错“the parameters check fails this is fail path”如何解决？
 */
let context: null = null;

export class ParametersCheck {
  // [Start ParametersCheck]
  public static timelineReceivedResult(path: string): void {
    if (!path) {
      console.error('Invoke empty file path')
      return;
    }
    let filename = path.substring(path.lastIndexOf("/") + 1);
    let uri = fileUri.getUriFromPath(path);
    let header = new Map<Object, string>();
    let files: Array<request.File> = [
      {
        filename: filename,
        name: 'test',
        uri: uri,
        type: 'txt'
      }
    ]
    let data: Array<request.RequestData> = []; // { name: 'name', value: 'value' }
    let uploadConfig: request.UploadConfig = {
      url: 'http://30.7.242.25:8800',
      header: header,
      method: 'POST',
      files: files,
      data: data
    }

    // Upload the local application file to the web server.
    try {
      request.uploadFile(context, uploadConfig)
        .then((uploadTask: request.UploadTask) => {
          uploadTask.on('complete', (taskStates: Array<request.TaskState>) => {
            for (let i = 0; i < taskStates.length; i++) {
              console.info(`upload complete taskState: ${JSON.stringify(taskStates[i])}`);
            }
          });
        })
        .catch((err: BusinessError) => {
          console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
        })
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      console.error(`Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  // [End ParametersCheck]
}
