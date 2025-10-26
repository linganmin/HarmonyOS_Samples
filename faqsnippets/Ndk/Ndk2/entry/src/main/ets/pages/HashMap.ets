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
 * FAQ: 如何实现ArkTS与C/C++的HashMap转换
 */
import testNapi from 'libentry.so';
import { HashMap } from '@kit.ArkTS';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  // [Start hash_map_two_ets]
  map2rec(map: HashMap<string, ESObject>): Record<string, ESObject> {
    // Map to Record
    let Rec: Record<string, ESObject> = {}
    map.forEach((value: ESObject, key: string) => {
      if (value instanceof HashMap) {
        //Value may be HashMap
        let vRec: Record<string, ESObject> = this.map2rec(value)
        value = vRec
      }
      Rec[key] = value
    })
    return Rec
  }
  // // [End hash_map_two_ets]

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            // [Start hash_map_one_ets]
            let hashMap: HashMap<string, number> = new HashMap();
            hashMap.set("Abc", 123);
            hashMap.set("Bcd", 234);
            hashMap.set("Cde", 345);

            let keysArray: Array<string> = Array.from(hashMap.keys());
            let valuesArray: Array<number> = Array.from(hashMap.values());
            testNapi.tsPutMap(keysArray, valuesArray, hashMap.length);
            // [End hash_map_one_ets]

            // [Start hash_map_three_ets]
            let myRec: Record<string, ESObject> = this.map2rec(hashMap);
            let str: string = JSON.stringify(myRec);
            testNapi.mapJson(str);
            // [End hash_map_three_ets]
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}