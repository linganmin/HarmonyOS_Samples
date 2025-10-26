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
* FAQ:如何创建临时文件
*/

// [Start CreateTempFile]
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct CreateFileDemo {
  @State message: string = 'Hello World';
  @State writeStr: string = 'write content';
  @State readStr: string = 'read content';

  build() {
    Column() {
      Text(this.message)
      Button(this.writeStr)
        .margin({ top: 15, bottom: 15 })
        .onClick(() => {
          let context = this.getUIContext().getHostContext();
          let filesDir = context!.tempDir;
          let file = fs.openSync(filesDir + 'test.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
          // Write a paragraph of content to a file
          fs.writeSync(file.fd, 'Try to write str.');
          console.info('str has been written');
          // close file
          fs.closeSync(file);
        })
      Button(this.readStr)
        .onClick(() => {
          let context = this.getUIContext().getHostContext();
          let filesDir = context!.tempDir;
          let file = fs.openSync(filesDir + 'test.txt', fs.OpenMode.READ_WRITE);
          // Read a section of content from a file
          let arrayBuffer = new ArrayBuffer(1024);
          let readOptions: ReadOptions = {
            offset: 0,
            length: arrayBuffer.byteLength
          };
          let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
          let buf = buffer.from(arrayBuffer, 0, readLen);
          this.message = buf.toString();
          // close file
          fs.closeSync(file);
        })
    }
    .height('100%')
    .width('100%')
  }
}
// [End CreateTempFile]