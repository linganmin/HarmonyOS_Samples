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
* FAQ:HarmonyOS Next系统属于大端还是小端
 */

// [Start little_endian]
@Entry
@Component
struct IndexTest {
  @State message: string = 'Hello World';

  isLittleEndian(): boolean {
    const buffer = new ArrayBuffer(2);
    const uint8Array = new Uint8Array(buffer);
    const uint16Array = new Uint16Array(buffer);
    // Write 0xAA and 0xBB into the buffer
    uint8Array[0] = 0xAA;
    uint8Array[1] = 0xBB;
    // If read in small order, 0xBBAA will be interpreted as 48042
    // If read in big endian order, 0xAABB will be interpreted as 43707
    return uint16Array[0] === 0xBBAA;
  }


  aboutToAppear() {
    if (this.isLittleEndian()) {
      console.log('Small end');
    } else {
      console.log('Big end');
    }
  }


  build() {
    RelativeContainer() {
      Text(this.message)
        .id('IndexTest')
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
// [End little_endian]