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
/**
 * 最佳实践：Native侧实现文件访问开发实践
 */
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri, picker } from '@kit.CoreFileKit';
import Logger from '../utils/Logger';
// [Start file_access1]
import FileAccess from 'libfile_access.so';
// [End file_access1]
function CreateFileByPicker(context: common.Context, fileName: string) {
  let documentSaveOptions = new picker.DocumentSaveOptions();
  documentSaveOptions.newFileNames = [fileName];
  let documentPicker = new picker.DocumentViewPicker(context);
  documentPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
    Logger.info('DocumentViewPicker.save successfully, documentSaveResult uri:: ' + JSON.stringify(documentSaveResult));
  }).catch((error: BusinessError) => {
    Logger.error('DocumentViewPicker.save failed with err: ' + JSON.stringify(error));
  });
}
// [Start by_pick]
async function WriteFileByPicker(contents: string): Promise<string> {
  //Configure picker Selection Information
  const documentSelectOptions = new picker.DocumentSelectOptions();
  documentSelectOptions.maxSelectNumber = 1;
  documentSelectOptions.fileSuffixFilters = ['.txt'];

  let uris: Array<string> = [];
  const documentViewPicker = new picker.DocumentViewPicker();
  //Pull up the picker selection file
  return await documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
    uris = documentSelectResult;
    let uri: string = uris[0];
    let path: string = new fileUri.FileUri(uri).path;
    Logger.info(`Open The File path is [${uri}]`);
    let file = fs.openSync(path, fs.OpenMode.WRITE_ONLY);
    //Call the native method to write a file
    let res = FileAccess.writeFileUsingPickerFd(file.fd, contents);
    fs.closeSync(file.fd);
    return res;
  }).catch((error: BusinessError) => {
    Logger.error(`Open The file failed, error code is [${error.code}], error message is [${error.message}]`);
    return 'Write Failed by Picker';
  })
}
// [End by_pick]
// [Start fun_read_pick]
async function ReadFileByPicker(): Promise<string> {
  //Configure picker Selection Information
  const documentSelectOptions = new picker.DocumentSelectOptions();
  documentSelectOptions.maxSelectNumber = 1;
  documentSelectOptions.fileSuffixFilters = ['.txt'];
  //Pull up the picker selection file
  let uris: Array<string> = [];
  const documentViewPicker = new picker.DocumentViewPicker();
  return await documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
    uris = documentSelectResult;
    let uri: string = uris[0];
    let path: string = new fileUri.FileUri(uri).path;
    Logger.info(`The Opened File path is [${uri}]`);
    let file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    //Call the native method to read the file.
    let res = FileAccess.readFileUsingPickerFd(file.fd);
    fs.closeSync(file.fd);
    return res;
  }).catch((error: BusinessError) => {
    Logger.error(`Open The file failed, error code is [${error.code}], error message is [${error.message}]`);
    return 'Read Failed by Picker!';
  })
}
// [End fun_read_pick]
export {
  CreateFileByPicker, WriteFileByPicker, ReadFileByPicker
};