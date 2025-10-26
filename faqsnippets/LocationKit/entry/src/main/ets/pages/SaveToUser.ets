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

/*
* FAQ:如何存储文件才不会跟随app卸载而删除
 */

// [Start saveToUser]
import { BusinessError } from '@kit.BasicServicesKit';
import { picker, fileIo } from '@kit.CoreFileKit';

let uri: string = '';

// Save content to the public directory
export async function saveToUser(content: string) {
  try {
    let DocumentSaveOptions = new picker.DocumentSaveOptions();
    // New file name
    DocumentSaveOptions.newFileNames = ['test.txt'];
    let documentPicker = new picker.DocumentViewPicker();
    documentPicker.save(DocumentSaveOptions).then((DocumentSaveResult: Array<string>) => {
      console.info('DocumentViewPicker.save successfully, uri: ' + JSON.stringify(DocumentSaveResult));
      uri = DocumentSaveResult[0];
      // Write the content into the newly created file
      let file = fileIo.openSync(uri, fileIo.OpenMode.READ_WRITE);
      fileIo.writeSync(file.fd, content);
    }).catch((err: BusinessError) => {
      console.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(err));
    });
  } catch (error) {
    let err: BusinessError = error as BusinessError;
    console.error('DocumentViewPicker failed with err: ' + err.message);
  }
}
// [End saveToUser]