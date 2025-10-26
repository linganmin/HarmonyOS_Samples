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
 * FAQ: 在ArkTS侧如何引用Native侧使用napi_create_buffer接口构造的对象
 */

// [Start ark_ts_call_native_napi_create_buffer_ets]
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
            let arr = testNapi.testBuffer();
            let result = new Uint8Array(arr);
            for (let index = 0; index < result.byteLength; index++) {
              console.info(`res[${index}] = ${result[index]}`)
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End ark_ts_call_native_napi_create_buffer_ets]