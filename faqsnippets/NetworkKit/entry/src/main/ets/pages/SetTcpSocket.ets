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
* FAQ:在建立好TCPSocket之后，如何将复合类型结构转换为ArrayBuffer
*/

// [Start SetTcpSocket]
interface ObjData {
  A1: string,
  B1: number,
  C1: ObjData2
}
interface ObjData2 {
  key1: string,
  key2: string
}

@Entry
@Component
export  struct ObjectToArrayBuffer {
  @State message: string = 'Object转ArrayBuffer';

  strToArrayBuffer(str: string) {
    let buf = new ArrayBuffer(str.length * 2);
    let bufView = new Uint16Array(buf);
    for (let i = 0,  strLen = str.length; i < strLen; i++) {
      bufView[i] = str.charCodeAt(i);
    }
    return bufView;
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let objData: ObjData = {
              A1:'字符串',
              B1: 1,
              C1:{'key1':'FF','key2':'GG'}
            }
            let buf1 = this.strToArrayBuffer(JSON.stringify(objData));
            console.info(`buf1: ${JSON.stringify(buf1 )}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End SetTcpSocket]

