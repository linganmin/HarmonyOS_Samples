/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
* FAQ:如何从图库选择图片并上传到服务器
*/

// [Start ImageUpload]
import { request } from '@kit.BasicServicesKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  private openPhotoPicker() {
    // Obtain the application file path 
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    let photoPicker = new photoAccessHelper.PhotoViewPicker();
    photoPicker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    }, (_, result) => {
      if (result) {
        result.photoUris.forEach((uri) => {
          let file = fs.openSync(uri, fs.OpenMode.CREATE);
          // Copy the file to the cache directory
          fs.copyFileSync(file.fd, cacheDir + '/test.jpeg');
          this.uploadImage(['internal://cache/test.jpeg']);
        })
      }
    })
  }

  private uploadImage(paths: string[]) {
    let allFiles = Array<request.File>();
    let header = new Map<Object, string>();
    header.set('Content-Type', 'multipart/form-data');
    header.set('key2', 'value2');
    for (let i = 0; i < paths.length; i++) {
      allFiles[i] = {
        name: 'image' + i + '.jpeg',
        filename: 'image' + i + '.jpeg',
        uri: paths[i],
        type: 'image'
      }
    }
    let data: Array<request.RequestData> = [{ name: 'name', value: 'value' }];
    let uploadConfig: request.UploadConfig = {
      url: 'http://XXX&#34',
      header: header,
      method: 'POST',
      files: allFiles,
      data: data
    }
    try {
      request.uploadFile(this.getUIContext().getHostContext(), uploadConfig, (error, uploadTask) => {
        if (uploadTask) {
          uploadTask.on('progress', (uploadSize: number, totalSize: number) => {
            console.info('progress,uploadedSize:' + uploadSize + ',totalSize:' + totalSize);
          })
        } else {
          console.info('upload failure:' + error);
        }
      })
    } catch (error) {
      console.info('upload failure:' + error);
    }
  }

  build() {
    Column() {
      Button('选择图片上传')
        .width('100%')
        .onClick(() => {
          this.openPhotoPicker();
        })
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .justifyContent(FlexAlign.End)
  }
}

// [End ImageUpload]
