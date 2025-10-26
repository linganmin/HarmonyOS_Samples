/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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
* FAQ:C侧如何打开文件。
*/

// [Start c_side_open_file_ets]
import { fileIo} from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import testNapi from 'libentry.so';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Open File';

  async open() {
    const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
    photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // Filter and select media file type as IMAGE
    photoSelectOptions.maxSelectNumber = 5; // Select the maximum number of media files
    let uris: Array<string> = [];
    const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
    await photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      uris = photoSelectResult.photoUris;
      console.info('photoViewPicker.select to file succeed and uris are:' + uris);
    }).catch((err: BusinessError) => {
      console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
    })
    try {
      let uri: string = uris[0];
      let file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      console.info('file fd: ' + file.fd);
      let fd = file.fd
      let context = this.getUIContext().getHostContext() as common.UIAbilityContext
      let filesDir = context.filesDir;
      fileIo.copyFileSync(fd, filesDir + '/test2.jpg')
      let file2 = fileIo.openSync(filesDir + '/test2.jpg', fileIo.OpenMode.READ_ONLY);
      let file3 = fileIo.openSync(filesDir + '/test3.jpg', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      testNapi.ReadFile(file2.fd, file3.fd)
    } catch (err) {
      hilog.error(0x0000, 'testTag', `openSync failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .onClick(() => {
        this.open();
      })
      .width('100%')
    }
    .height('100%')
  }
}
// [End c_side_open_file_ets]