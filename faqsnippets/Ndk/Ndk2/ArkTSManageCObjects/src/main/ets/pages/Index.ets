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
 * FAQ: 如何在ArkTS侧管理Native侧的C++对象
 */
// [Start ark_ts_manage_native_ets]
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  @State message: string = 'DefineObject';
  @State message2: string = 'CallObject';
  addr: number = 0;

  build() {
    Column() {
      Button(this.message)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.addr = testNapi.defineObject();
          console.log('testTag:' + this.addr.toString());
        })
      Button(this.message2)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          if (this.addr != 0) {
            testNapi.callObject(this.addr);
            this.message2 = 'CallObject';
          } else {
            this.message2 = 'want define Object';
          }
        })
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}
// [End ark_ts_manage_native_ets]