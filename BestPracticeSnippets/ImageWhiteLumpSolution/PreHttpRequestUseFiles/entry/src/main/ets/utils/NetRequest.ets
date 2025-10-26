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

// [Start http_request]
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

// Get the application file path
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;
let filesDir = context.filesDir;
let fileUrl = filesDir + '/xxx.png'; // When using the actual network address, the suffix of the actual address must be filled in.

export async function httpRequest() {
  fs.access(fileUrl, fs.AccessModeType.READ).then((res) => { // Check if the file exists
    if (!res) { // If there is no address in the sandbox, re-request the network image resources.
      http.createHttp()
        .request('https://www.example.com/xxx.png', // Please fill in a specific URL of the online image here.
          (error: BusinessError, data: http.HttpResponse) => {
            if (error) {
              // Do not execute subsequent logic when the download fails.
              return;
            }
            // Process the data returned from the network request.
            if (http.ResponseCode.OK === data.responseCode) {
              const imageData: ArrayBuffer = data.result as ArrayBuffer;
              // Save the image to the application sandbox.
              readWriteFileWithStream(imageData);
            }
          }
        )
    }
  })
}

// Write to the sandbox
async function readWriteFileWithStream(imageData: ArrayBuffer): Promise<void> {
  let outputStream = fs.createStreamSync(fileUrl, 'w+');
  await outputStream.write(imageData);
  outputStream.closeSync();
}
// [End http_request]