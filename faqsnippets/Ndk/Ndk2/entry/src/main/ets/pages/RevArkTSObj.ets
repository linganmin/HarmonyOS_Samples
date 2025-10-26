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
 * FAQ: Native侧如何对ArkTS传递的Object类型的数据、属性进行修改
 */
// [Start rev_ark_ts_obj_ets]
import testNapi from 'libentry.so';


interface Obj1 {
  obj: Obj2,
  hello: String,
  arr: number[],
  typedArray: Uint8Array
}


interface Obj2 {
  str: string
}


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
            const typedArr = new Uint8Array(3);
            typedArr[0] = 1;
            typedArr[1] = 2;
            typedArr[2] = 3;
            const obj: Obj1 = {
              obj: { str: 'obj in obj' },
              hello: 'world',
              arr: [94, 32, 43],
              typedArray: typedArr
            }
            console.info(`Test NAPI modifyObject result is ${JSON.stringify(testNapi.modifyObject(obj))}`)
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End rev_ark_ts_obj_ets]