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
* FAQ:如何指定对象某些属性参与序列化
*/

// [Start SpecifyCertainProperties]
import { JSON } from '@kit.ArkTS';

interface Person {
  name: string;
  age: number;
  city: string;
}

let obj: Person = { name: 'John', age: 30, city: 'ChongQing' };

@Entry
@Component
struct JSONDemo {
  @State str: string = 'to json';

  build() {
    Row() {
      Column() {
        Button(this.str)
          .onClick(() => {
            let jsonStr1 = JSON.stringify(obj); // All attributes are serialized
            console.info('jsonStr1：', jsonStr1); // jsonStr1： {"name":"John","age":30,"city":"ChongQing"}
            let jsonStr2 = JSON.stringify(obj, ['name']); // Specify the name attribute and serialize it
            console.info('jsonStr2：', jsonStr2); // jsonStr2： {"name":"John"}
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End SpecifyCertainProperties]
