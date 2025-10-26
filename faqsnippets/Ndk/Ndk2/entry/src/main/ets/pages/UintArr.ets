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
 * FAQ: Native侧如何获取ArkTS侧的Uint8Array实例
 */
// [Start uint_arr_ets]
// ArkTS passes Uint8Array parameter
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let temp = new Uint8Array(2);
            temp[0] = 1;
            temp[1] = 2;
            console.info(`Pure inputBuffer length: ${temp.length}`);
            let res = testNapi.uintArr(temp);
            console.info(`Pure outputBuffer: ${res}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End uint_arr_ets]