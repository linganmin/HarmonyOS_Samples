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
* FAQ:如何将数据持续写入文件内
*/

// [Start StreamDataToFile]
import { fileIo, WriteOptions } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Component
export struct ContinuousWrite {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext(); // Sandbox Path
    let filePath = context!.filesDir + '/test.txt';
    let file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let arrayBuffer = new ArrayBuffer(4096);
    fileIo.read(file.fd, arrayBuffer).then((readLen: number) => {
      console.info(readLen.toString());
      let str: string = 'hello, world';
      let options: WriteOptions = { offset: readLen };
      let writeLen = fileIo.writeSync(file.fd, str, options);
      console.info('write data to file succeed and size is:' + writeLen);
    }).catch((err: BusinessError) => {
      console.error('read file data failed with error message: ' + err.message + ', error code: ' + err.code);
    }).finally(() => {
      fileIo.closeSync(file);
    });
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('WriteHelloWorld')
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

// [End StreamDataToFile]