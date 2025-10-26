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
 * FAQ: 传入自定义类型对象到Native侧时，index.d.ts文件如何声明
 */
import testNapi from 'libentry.so';
import {testCa} from "./interface/CustomObject"
// [Start test_c_b_ets]
class testCb {
  testNum: number = 0;
  testString: string = "";
}
// [End test_c_b_ets]
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
            let tacb = new testCb();
            testNapi.test(tacb);
            console.info(`tacb.testNum : ${tacb.testNum}, tacb.testString : ${tacb.testString}`);
            let taca = new testCa();
            testNapi.test1(taca);
            console.info(`taca.testNum : ${tacb.testNum}, taca.testString : ${tacb.testString}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
