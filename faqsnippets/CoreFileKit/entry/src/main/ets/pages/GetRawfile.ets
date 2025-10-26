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
* FAQ:如何获取到 resources下rawfile 的文件
*/

// [Start GetRawfile]
import { fileIo } from '@kit.CoreFileKit';

@Component
export struct GetRawfile {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    this.getUIContext().getHostContext()?.resourceManager.getRawFileContent('test.txt', (_err, value) => {
      if (_err) {
        console.error('Failed to get raw file:', _err);
        return;
      }
      let fileBuffer: ArrayBufferLike = value.buffer;
      let context = this.getUIContext()
        .getHostContext(); // Obtain the application sandbox path for storing temporary files, and perform null checking
      let filePath = context!.filesDir + '/test.txt';
      console.info('testTag-filePath:' + filePath);
      let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      let writeLen = fileIo.writeSync(file.fd, fileBuffer);
      console.info('testTag-write data to file succeed and size is:' + writeLen);
      fileIo.closeSync(file);
    });
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('RawfileHelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}

// [End GetRawfile]