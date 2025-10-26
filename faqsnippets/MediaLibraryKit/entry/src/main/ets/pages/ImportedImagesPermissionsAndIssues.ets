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
* FAQ:关于导入图片的使用权限和问题
*/

// [Start ImportedImagesPermissionsAndIssues]
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

let context = AppStorage.get("context") as UIContext;
let filesDir = context.getHostContext()?.filesDir;
function savePictureToContext(){
  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // Filter and select media file type as IMAGE
  photoSelectOptions.maxSelectNumber = 5; // Select the maximum number of media files
  let uris: Array<string> = [];
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
    uris = photoSelectResult.photoUris;
    console.info('photoViewPicker.select to file succeed and uris are:' + uris);
  }).catch((err: BusinessError) => {
    console.error('Invoke photoViewPicker.select failed, code is'+ err.code+', message is '+err.message);
  })
  let uri: string = uris[0];
  let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
  console.info('file fd: ' + file.fd);
  let fd =file.fd;
  fileIo.copyFileSync(fd, filesDir + '/test2.jpg')
  let file2 = fileIo.openSync(filesDir + '/test2.jpg', fileIo.OpenMode.READ_ONLY );
  let file3 = fileIo.openSync(filesDir + '/test3.jpg', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
  // After passing fd in, the C end can call it
  // ReadFile(file2.fd,file3.fd)
}
// [End ImportedImagesPermissionsAndIssues]