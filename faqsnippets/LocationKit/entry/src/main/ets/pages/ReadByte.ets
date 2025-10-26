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
* FAQ:如何从一个二进制文件中读取其字节数组？通过fs.createStreamSync只能获取到ArrayBuffer，如何转成number[]
 */

// [Start ArrayBufferConversionArray]
@Component
export struct ArrayBufferConversionArray {
  @State fileLength: number = 10;
  private tempData: number[] = [];

  aboutToAppear(): void {
    // Convert ArrayBuffer to a number array
    let arrayBuffer: ArrayBuffer = new ArrayBuffer(this.fileLength);
    let dataView: DataView = new DataView(arrayBuffer);
    for (let index = 0; index < this.fileLength; index++) {
      this.tempData[index] = dataView.getInt8(index);
    }
    console.info(this.tempData.toString());
  }

  build() {
    RelativeContainer() {
      Text(this.tempData.toString())
        .id('ArrayBufferHelloWorld')
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

// [End ArrayBufferConversionArray]